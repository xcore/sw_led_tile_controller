// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethTftp.c
 *
 *
 **/                                   
                         
#include "ethPkt.h"
#include "ethSwitch.h"
#include "ethIp.h"
#include "string.h"
#include "stdlib.h"
#include <xclib.h>
#include "ethTftp.h"
#include "flashmanager.h"
#include "flashclient.h"
#include "flashphy.h"
#include "chanabs.h"
#include "misc.h"
#include "math.h"

#define MAX_FILE_SIZE (64*1024)

// 0 = no activity
// x = ready for block number (x - 1)
int tftpstate = 0;
int spiaddress = 0;


// Transmit a Tftp PACKET
void transmitTftp(s_packet *p, s_packetTftp *t, unsigned cTx, unsigned blocknum, unsigned opcode, char msg[])
{
  int null;
  unsigned short *ptr;
  s_packetMac *m;
   s_packetIp *i; 
   s_packetUdp *u;

   m = (s_packetMac *)p->pdata;
   i = (s_packetIp *)m->payload;
   u = (s_packetUdp *)i->payload;
  
  t->opcode = getShort(opcode);
  ptr = (unsigned short*)t->data;
  *ptr = getShort(blocknum);
  ptr++;
  strcpy((char *)ptr, msg);
  
  p->plen_b = MAC_SIZE + IP_SIZE + UDP_SIZE + TFTP_SIZE + strlen(msg) + 1;
  i->length = getShort(IP_SIZE + UDP_SIZE + TFTP_SIZE + strlen(msg) + 1);
  u->length = getShort(UDP_SIZE + TFTP_SIZE + strlen(msg) + 1);
  
  memswap((void*)m->destmac, (void*)m->sourcemac, 6);
  memswap((void*)i->dest, (void*)i->source , 4);
  memswap((void*)&u->sourceport, (void*)&u->destport, 2);
  
  udpChecksum((s_packetUdp *)i->payload);
  ipChecksum(i);

  //TODO this is deprecated & has to be change
  //  ethPhyTx(cTx, p, &null);
}

// processTftp
void processTftp(s_packet *p, s_packetTftp *t, unsigned cTx, unsigned cFlash)
{
  s_packetMac *m;
  s_packetIp *i; 
   s_packetUdp *u;

   m = (s_packetMac *)p->pdata;
   i = (s_packetIp *)m->payload;
   u = (s_packetUdp *)i->payload;

  if (t->opcode == getShort(TFTP_OPCODE_WRQ))
  {
    char *filename;
    char *datatype;
    
    filename = (char *)t->data;
    datatype = filename + strlen(filename) + 1;

    if (strncmp(datatype, "octet",5) == 0)
    {
      if (strncmp(filename, "firmware",8) == 0)
      {
        char retstr[25] = "Firmware   Updating.";
        int retvalue;
        tftpstate = 1;
        spiaddress = 0;
        
        out(cFlash, SPI_FLASH_NEWFIRMWARE);
        retvalue = in(cFlash);
        retstr[9] = '0' + (retvalue & 0xF);
        transmitTftp(p, t, cTx, 0, TFTP_OPCODE_ACK, retstr);
      }
      else if (strncmp(filename, "reset",5) == 0)
      { 
        // Ack with a nack
        transmitTftp(p, t, cTx,0, TFTP_OPCODE_ERROR, "Resetting Device.");
        sleep(10000);
        chipReset();
      }
      else
      {
        // NACK
        transmitTftp(p, t, cTx,0, TFTP_OPCODE_ERROR, "Filename not recognised.");
      }
    }
    else
    {
      transmitTftp(p, t, cTx,0, TFTP_OPCODE_ERROR, "Transfer mode not binary.");
    }
  }
  else if (t->opcode == getShort(TFTP_OPCODE_DATA) &&
      tftpstate != 0)
  {
    unsigned short *blocknum = (unsigned short *)t->data;
    if (*blocknum == getShort(tftpstate))
    {
      if (tftpstate < (MAX_FILE_SIZE >> 9)) // 512 byte blocks
      {
        int j, datalen = getShort(u->length)-UDP_SIZE-TFTP_SIZE;
        unsigned char *dataptr = (unsigned char *)t->data + 2;
  
        flash_write_firmware(cFlash, spiaddress, datalen, dataptr);
        transmitTftp(p, t, cTx, tftpstate, TFTP_OPCODE_ACK, "Firmware Updating.");
        
        tftpstate++;
        if (datalen < 512)
          tftpstate = 0;
        spiaddress += datalen;
      }
      else
      {
        transmitTftp(p, t, cTx,0, TFTP_OPCODE_ERROR, "File too large.");
        tftpstate = 0;
      }
    }
    else
    {
      transmitTftp(p, t, cTx,0, TFTP_OPCODE_ERROR, "Error.");
      tftpstate = 0;
    }
  }
  
  return;
}
