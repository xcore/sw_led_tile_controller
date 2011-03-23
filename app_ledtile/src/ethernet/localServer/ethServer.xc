// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
 * File:    ethServer.xc
 *
 *
 **/                                   
#include <platform.h>
#include <xs1.h>
#include "ethPkt.h"
#include "ethSwitch.h"
#include "ethServerProcess.h"
#include "flashmanager.h"
#include "ledprocess.h"
#include "watchdog.h"

#define TIMEOUT 100000000


void read_spi_gamma(int offset, char val, chanend cLedCmd, chanend cFlash)
{
  unsigned short gbuf[256];
  int i;
  int allFF;
  unsigned retval;
  cFlash <: SPI_FLASH_READGAMMA;
  master
  {
    cFlash <: offset;
    cFlash <: 256;
    for (i=0; i<256; i++)
    {
      unsigned val;
      cFlash :> val;
      gbuf[i] = (unsigned short)val;
    }
  }

  // If read all FFs from flash, use some sensible default
  for (i=0; i<256; i++)
  {
    if (gbuf[i] != 0xFF)
      break;
  }
  allFF = (i == 256);
  
  do
  {
    // Store in command buffer
    // Response indicates if buffer is full 
    master
    {

      cLedCmd <: 256+2;
      cLedCmd :> retval;
      if (retval == 0)
      {
        cLedCmd <: (unsigned int)XMOS_GAMMAADJ;
        cLedCmd <: (unsigned int)val;
        for (i=0; i<256; i++)
          cLedCmd <: (unsigned int)gbuf[i];        
      }
    }
    {
      timer t;
      int now;
      t :> now;
      t when timerafter (now + 10000) :> now;
    }
  } while (retval != 0);
}

struct otp_ports otp_ports = {
  on stdcore[3] : OTP_DATA_PORT,
  on stdcore[3] : OTP_ADDR_PORT,
  on stdcore[3] : OTP_CTRL_PORT,
};

// Standard local ethernet server
// Supports ICMP, ARP, TFTP
// Also supports user-definable protocols with two user defined channels
#pragma unsafe arrays
void ethServer(streaming chanend cRx, chanend cTx, chanend cLedData, chanend cLedCmd, chanend cSpiFlash, chanend cWdog)
{
  s_packet packet;
  s_addresses addresses;
  timer t;
  int time, direction;
  unsigned num_words, packet_received;
  
  // Initialise addresses
  initAddresses(addresses, otp_ports);
  
  t :> time;
    
#ifdef LOADGAMMAFROMSPI
  // Read gamma tables from SPI Flash
  read_spi_gamma(0, 'R', cLedCmd, cSpiFlash);
  read_spi_gamma(1, 'G', cLedCmd, cSpiFlash);
  read_spi_gamma(2, 'B', cLedCmd, cSpiFlash);
#endif
  
  // Request data from buffer
  cRx <: 0;
  while (1)
  {

    select
    {
      case t when timerafter (time + SERV_WAIT) :> time:
        cWdog <: (int)1;
        break;
      case cRx :> packet_received:
        if (packet_received == 0)
        {
          cRx :> num_words;
          num_words--;
          
          cRx :> packet.plen_b;
    	  
          // Receive ethernet packet from switch
          while (num_words)
          {
            num_words--;
            cRx :> packet.pdata[num_words];
          }
#ifdef MII_TX_TIMESTAMPS
          cRx :> int;
#endif

          // Process the packet in the server
          ethServerProcess(packet, cTx, cLedData, cLedCmd, cSpiFlash, addresses, direction);
        }
        cRx <: 0;
        break;
    }
  }
}
