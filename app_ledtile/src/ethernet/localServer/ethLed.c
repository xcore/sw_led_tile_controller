// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethLed.c
 *
 *
 **/                                   

#include <xs1.h>
#include "misc.h"
#include "ethOther.h"
#include "ethPkt.h"
#include "ethSwitch.h"
#include "ethIp.h"
#include "xmosAC.h"
#include "ledprocess.h"
#include "string.h"
#include <xclib.h>
#include "led.h"
#include "flashmanager.h"
#include "flashclient.h"
#include "chanabs.h"
#include "math.h"
#include "ledbufferwriter.h"
#include "pktbufferclient.h"


s_xmosAC xmosACdata;

void sendACforwardPackets(s_packet *packet, s_addresses *addresses, unsigned cTx)
{
  s_packetMac *m;
  s_packetIp *i; 
  s_packetUdp *u;
  s_packetXmos *x;
  int null;
  
  m = (s_packetMac *)packet->pdata;
  i = (s_packetIp *)m->payload;
  u = (s_packetUdp *)i->payload;
  x = (s_packetXmos *)u->payload;
  
  x->identifier = getShort(XMOS_AC_4);
  setUdpSize(packet, XMOS_SIZE+8);
  packet->plen_b = 60;

  // If there's another node after us
  if (xmosACdata.XendFlag == 0)
  {
    i->ttl = 0;
    memcpy(x->payload, xmosACdata.nextXNodeMac, 6);
    x->payload[7]++;
    udpChecksum(u);
    ipChecksum(i);
    ethPhyTx(cTx, packet, &null);
    x->payload[7]--;
  }
  
  if (xmosACdata.YendFlag == 0)
  {
    memcpy(x->payload, xmosACdata.nextYNodeMac, 6);
    x->payload[6]++;
    i->ttl = 255;
    udpChecksum(u);
    ipChecksum(i);
    ethPhyTx(cTx, packet, &null);
    x->payload[6]--;
  }  
}


// Local Ethernet server for receiving XMOS-Specific packets (i.e., not ICMP etc)
void ethOtherProcess(s_packet *packet, unsigned cTx, unsigned cLedData, unsigned cLedCmd, unsigned cFlash, s_addresses *addresses, int direction)
{
  int null;
  const char magicNumber[4] = {'X', 'M', 'O', 'S' };
  s_packetMac *m;
  s_packetIp *i; 
  m = (s_packetMac *)packet->pdata;
  i = (s_packetIp *)m->payload;
  // Check we are targeting the correct IP
  if (memcmp(i->dest, addresses->ipAddress, 4) && i->dest[3] != 0xFF)
    return;
  
  // Ipv4 UDP packets
  if (getShort(m->ethertype) == ETHERTYPE_IP && getChar(i->proto) == PROTO_UDP)
  {
    if (memcmp(i->dest, addresses->ipAddress, 4) == 0 ||
        (i->dest[2] == 0xFF && i->dest[3] == 0xFF))
    {
      s_packetUdp *u;
      u = (s_packetUdp *)i->payload;
        
      if(getShort(u->destport) == PORT_XMOS)
      {
        s_packetXmos *x = (s_packetXmos *)u->payload;
        
        // Verify magic word
        if (memcmp( (void*)x->magicNumber , (void*)magicNumber, 4) == 0)
        {
      	// Check the XMOS identifier
          switch (getShort(x->identifier))
          {
            case (XMOS_VERSION):
            {
              while (1);
            }
            break;
            case (XMOS_DATA):
            {
          	// This is a LED data packet
              unsigned char *ptr;
              unsigned iptr;
              
              // if not our IP, exit
              if (memcmp(i->dest, addresses->ipAddress, 4))
                return;
              
              s_packetData *d = (s_packetData *)x->payload;
              ptr = d->data;
              
              // Check packet
              if (d->datalen + 3*d->pixptr <= 3*FRAME_SIZE)
              {
                // Send to LED frame buffer
                sendLedData(cLedData, (unsigned)d->pixptr, d->datalen, ptr);
              }
            }
            break;
            case (XMOS_LATCH):
            {
            	// This is a "New Frame" latch signal
              sendLedLatch(cLedData);
            }
            break;
            case (XMOS_GAMMAADJ):
            {
          	// This is a "adjust gamma table" packet
              int i;

              s_packetGammaTable *gt = (s_packetGammaTable *)x->payload;
              
              {
                unsigned data[258] = {XMOS_GAMMAADJ, gt->colchan[0]};
                for (i=0; i<256; i++)
                {
                  data[i+2] = (unsigned int)gt->gammaTable[i];
                }
                sendPktData(cLedCmd, 258, data);
              }
              
              // Write to flash
              if (gt->colchan[0] == 'A')
              {
                flash_write_gamma(0, gt->gammaTable, cFlash);
                flash_write_gamma(1, gt->gammaTable, cFlash);
                flash_write_gamma(2, gt->gammaTable, cFlash);
              }
              else if (gt->colchan[0] == 'R')
              {
                flash_write_gamma(0, gt->gammaTable, cFlash);
              }
              else if (gt->colchan[0] == 'G')
              {
                flash_write_gamma(1, gt->gammaTable, cFlash);
              }
              else if (gt->colchan[0] == 'B')
              {
                flash_write_gamma(2, gt->gammaTable, cFlash);
              }

            }
            break;
            case (XMOS_INTENSITYADJ):
            case (XMOS_SINTENSITYADJ):
            {
          	// This is an intentsity adjustment packet
              int i;
              s_packetIntensity *inte = (s_packetIntensity *)x->payload;
              
              {
                unsigned data[3] = {getShort(x->identifier), inte->colchan[0], inte->intensity};
                sendPktData(cLedCmd, 3, data);
              }
            }
            break;
            case (XMOS_SINTENSITYADJ_PIX):
            {
            // This is an intentsity adjustment packet for a single pixel
              int i;
              s_packetIntensityPix *inte = (s_packetIntensityPix *)x->payload;
              
              {
                 unsigned data[5] = {getShort(x->identifier), inte->colchan, 
                     inte->y, inte->x, inte->intensity};
                 sendPktData(cLedCmd, 5, data);
              }
            }
            break;
            case (XMOS_RESET):
              chipReset();
            break;
            case (XMOS_CHANGEDRIVER):
            {
              s_packetDriverType *dt = (s_packetDriverType *)x->payload;
              
              // Store a command to change the LED Driver
              {
                 unsigned data[2] = {getShort(x->identifier), dt->drivertype};
                 sendPktData(cLedCmd, 2, data);
              }
            }
            break;
            case (XMOS_AC_1):
              // Broadcast AC_2 message, include our TTL of AC_1 message
              x->identifier = getShort(XMOS_AC_2);
              x->payload[0] = i->ttl;
              
              xmosACdata.myCommandTTL = i->ttl;
              xmosACdata.XstartFlag = 1;
              xmosACdata.XendFlag = 1;
              xmosACdata.YstartFlag = 1;
              xmosACdata.YendFlag = 1;
              
              memcpy( (void*)m->sourcemac, (void*)addresses->macAddress, 6);

              i->ttl = 255;
              setUdpSize(packet, XMOS_SIZE+1);
              packet->plen_b = 60;
              udpChecksum(u);
              ipChecksum(i);
              ethPhyTx(cTx, packet, &null);
            break;
            case (XMOS_AC_2):
              // If we think we are at the beginning of this chain
              if (xmosACdata.XstartFlag && x->payload[0] == xmosACdata.myCommandTTL)
              {
                // Look to see if they are before us in the list
                if (memcmp(m->sourcemac, addresses->macAddress, 6) < 0)
                {
                  // We are not at the beginning of the Y chain
                  xmosACdata.YstartFlag = 0;
                }
                else if ((xmosACdata.YendFlag == 0) && (memcmp(m->sourcemac, xmosACdata.nextYNodeMac, 6) < 0))
                {
                  memcpy(xmosACdata.nextYNodeMac, m->sourcemac, 6);
                }
                else
                {
                  xmosACdata.YendFlag = 0;
                  memcpy(xmosACdata.nextYNodeMac, m->sourcemac, 6);
                }
              }
            
              if (i->ttl == 255)
              {
                // Are they on the same chain but before us?
                if (x->payload[0] > xmosACdata.myCommandTTL)
                {
                  xmosACdata.XstartFlag = 0;
                }
                // Are they the next node on our chain?
                else if (x->payload[0] < xmosACdata.myCommandTTL)
                {
                  memcpy(xmosACdata.nextXNodeMac, m->sourcemac, 6);
                  xmosACdata.XendFlag = 0;
                }
              }
              break;
            case (XMOS_AC_3):
              memcpy( (void*)m->sourcemac, (void*)addresses->macAddress, 6);
              if (xmosACdata.XstartFlag && xmosACdata.YstartFlag)
              {
                x->payload[6] = START_IP_Y;
                x->payload[7] = START_IP_X;
                addresses->ipAddress[2] = START_IP_Y;
                addresses->ipAddress[3] = START_IP_X;                                
                sendACforwardPackets(packet, addresses, cTx);
              }
            break;
            case (XMOS_AC_4):
              memcpy( (void*)m->sourcemac, (void*)addresses->macAddress, 6);
              if (memcmp(x->payload, addresses->macAddress, 6) == 0)
              {
                addresses->ipAddress[2] = x->payload[6];
                addresses->ipAddress[3] = x->payload[7];
                sendACforwardPackets(packet, addresses, cTx);
              }
            break;
          }
        }
      }
    }
  }
}

