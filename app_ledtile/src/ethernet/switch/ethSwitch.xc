// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethSwitch.xc
 *
 *
 **/                                   

#include <xs1.h>
#include "xclib.h"
#include "ethSwitch.h" 
#include "miimain.h"
#include "watchdog.h"
#include "print.h"

#define getMiiData(var, c) { c <: 0; c :> var; }

// ethPhyRx
// Receive packet over channel and place in s_packet structure
// Returns 1 for success, 0 for invalid packet
#pragma unsafe arrays
int ethPhyRx(streaming chanend c, s_packet &pkt, unsigned numbytes)
{
//  int null;
  int numwords = (numbytes >> 2) + 1;
  int bufindex = 0;

  pkt.plen_b = numbytes - 4;
  while (numwords)
  {
	  numwords--;
	  getMiiData(pkt.pdata[bufindex], c);
	  bufindex++;
  }
  // Receive Timestamp
  getMiiData(pkt.timestamp, c);
  pkt.timestamp = byterev(pkt.timestamp);

#if 0
  printstr("Packet length:");
  printhexln(pkt.plen_b);
  for (int i=0; i<pkt.plen_b; i++)
  {
    printhexln((pkt.pdata,unsigned char[])[i]);
  }
#endif
  
  return 1;
}

#pragma unsafe arrays
void localTx(chanend cTx, s_packet &pkt, int &tstamp)
{
  int numwords = (pkt.plen_b + 3)>>2;
  int retval;
  master
  {
    cTx <: numwords + 1;
    cTx :> retval;
    if (!retval)
    {
      cTx <: pkt.plen_b;
      while (numwords)
      {
        numwords--;
        cTx <: pkt.pdata[numwords];
      }
    }
  }
}


// ethPhyTx
// Send packet over channel from s_packet structure
#pragma unsafe arrays
void ethPhyTx(chanend cTx, s_packet &pkt, int &tstamp)
{
  int numwords = (pkt.plen_b + 3)>>2;
  
  master
  {
    cTx <: pkt.plen_b;
    while (numwords)
    {
      numwords--;
      cTx <: pkt.pdata[numwords];
    }
#ifdef MII_TX_TIMESTAMPS
    cTx :> tstamp;
#else
    tstamp = 0;
#endif
  }
}

#pragma unsafe arrays
void ethTx(streaming chanend cTx, s_packet &pkt)
{
  int numwords = (pkt.plen_b + 3)>>2;
   
  cTx <: pkt.plen_b;
  cTx <: pkt.ptpcorrect;
  cTx <: pkt.timestamp;

  while (numwords)
  {
    numwords--;
    cTx <: pkt.pdata[numwords];
  }
}

#define getSecondShort(a) (byterev(a) & 0xFFFF)
#define getFirstShort(a)  (byterev(a) >> 16 )
#define getArrayByte(data, ptr) (unsigned char[], data)[ptr])
#define getArrayShort(data, ptr) (((unsigned char[], data)[ptr] << 8) | ((unsigned char[], data)[ptr+1]))
#define getArrayWord(data, ptr) (((unsigned char[], data)[ptr] << 24) | ((unsigned char[], data)[ptr+1]  << 16) \
                            ((unsigned char[], data)[ptr+2] << 8) | ((unsigned char[], data)[ptr+3]))

int adjustTTL(s_packet &pkt)
{
  if ((pkt.pdata[3] & 0xFFFF) == 0x0008)
  {
    int ttl = (pkt.pdata[5] >> 16) & 0xFF;
    if (ttl)
    {
      unsigned ipchecksum;
      
      ttl--;
      pkt.pdata[5] &= 0xFF00FFFF;
      pkt.pdata[5] |= ttl << 16;
      
      pkt.pdata[6] &= 0xFFFF0000;
      
      ipchecksum = getSecondShort(pkt.pdata[3]);
      
      for (int j=0; j<4; j++)
        ipchecksum += getSecondShort(pkt.pdata[4+j]) + getFirstShort(pkt.pdata[4+j]);
      
      ipchecksum += getFirstShort(pkt.pdata[8]);      

      ipchecksum = ~((ipchecksum & 0xFFFF) + (ipchecksum >> 16));

      pkt.pdata[6] |= ((ipchecksum >> 8) & 0xFF) | ((ipchecksum & 0xFF) << 8);
    }
    else
    {
      return 0;
    }
  }
  return 1;
}

#ifdef PTPAWARE
int correctPTPcheck(s_packet &pkt)
{
  unsigned ptr = 12;
  // Check for IP protocol
  pkt.ptpcorrect = 0;
  if (getArrayShort(pkt.pdata, ptr) == 0x0800)
  {
    ptr += 2;
    // Check for UDP protocol
    if (getArrayByte(pkt.pdata, ptr + 9) == 0x11)
    {
      ptr += (getArrayByte(pkt.pdata, ptr) & 0xF) << 2;
      // Check for PTP port
      if (getArrayShort(pkt.pdata, ptr+2) == 319 || getArrayShort(pkt.pdata, ptr+2) == 320)
      {
        ptr += 8; // Add UDP
        ptr += 10; // PTP header + 2 bytes
        pkt.ptpcorrect = ptr >> 2; // Guaranteed to be word aligned
      }
    }
  }
  
}
#endif

#define ENABLE_ETH_0
#define ENABLE_ETH_1
// ethSwitch
// Layer 2 ethernet switch framework
// Supports two external interfaces, and one local
#pragma unsafe arrays
void ethSwitch(streaming chanend cExtRx0, streaming chanend cExtRx1, chanend cLocRx,
                 streaming chanend cExtTx0, streaming chanend cExtTx1, chanend cLocTx,
                 chanend cWdog)
{
  timer t;
  int time;
  unsigned mymacaddress[2] = {0x0, 0x0};
  unsigned macset = 0;
  unsigned broadcastaddress[2] = {0xFFFFFFFF, 0xFFFF0000};
  s_packet packet;
  unsigned numbytes;
  int timestamp;
  
  set_thread_fast_mode_on();

  // Initially request data from external receivers
  cExtRx0 <: 0;
  cExtRx1 <: 0;
  
  t:> time;
  while(1)
  {
#pragma ordered
    select
    {
      case t when timerafter (time + SWITCH_WAIT) :> time:
        cWdog <: (int)1;
        break;
      // Received data from external receiver 0
      case cExtRx0 :> numbytes:
        // Retrieve and validate packet
        if (ethPhyRx(cExtRx0, packet, numbytes))
        {
          // Do MAC comparison
          if ((getWord(packet.pdata[0]) == mymacaddress[0]) && ((getWord(packet.pdata[1]) & 0xFFFF0000) == mymacaddress[1]))
          {
            // Packet is destined for local node
            localTx(cLocTx, packet, timestamp);
          }
          else if (((getWord(packet.pdata[0]) == broadcastaddress[0]) && ((getWord(packet.pdata[1]) & 0xFFFF0000) == broadcastaddress[1]))  || macset == 0 )
          {
            // Packet is broadcast
            localTx(cLocTx, packet, timestamp);
#ifdef ENABLE_ETH_0
            if (adjustTTL(packet))
              ethTx(cExtTx1, packet);
#endif
          }
          else
          {
            // Packet is neither broadcast or local, forward onwards
#ifdef ENABLE_ETH_1
            if (adjustTTL(packet))
              ethTx(cExtTx1, packet);
#endif
          }
        }
        // Request more data
        cExtRx0 <: 0;
        break;
      // Received data from external receiver 1
      case cExtRx1 :> numbytes:
      // Retrieve and validate packet
        if (ethPhyRx(cExtRx1, packet, numbytes))
        {
          // Do MAC comparison
          if ((getWord(packet.pdata[0]) == mymacaddress[0]) && ((getWord(packet.pdata[1]) & 0xFFFF0000) == mymacaddress[1]))
          {
          // Packet is destined for local node
            localTx(cLocTx, packet, timestamp);
          }
          else if (((getWord(packet.pdata[0]) == broadcastaddress[0]) && ((getWord(packet.pdata[1]) & 0xFFFF0000) == broadcastaddress[1]))  || macset == 0 )
          {
            // Packet is broadcast
            localTx(cLocTx, packet, timestamp);
#ifdef ENABLE_ETH_0
            if (adjustTTL(packet))
              ethTx(cExtTx0, packet);
#endif
          }
          else
          {
            // Packet is neither broadcast or local, forward onwards
#ifdef ENABLE_ETH_0
            if (adjustTTL(packet))
              ethTx(cExtTx0, packet);
#endif
          }
        }
        // Request more data
        cExtRx1 <: 0;
        break;
      // Received data from local node
      case slave {
                    cLocRx :> numbytes;
                    // Receive data into packet structure
                    packet.plen_b = numbytes;
                    {
                      int numwords = (numbytes + 3) >> 2;
                      while (numwords)
                      {
                        numwords--;
                        cLocRx :> packet.pdata[numwords];
                      }
                    }
#ifdef MII_TX_TIMESTAMPS
                    cLocRx :> int _;
#endif
                 }:
        // Update local MAC
        mymacaddress[0] = ((getWord(packet.pdata[1]) & 0x0000FFFF) << 16) | ((getWord(packet.pdata[2]) & 0xFFFF0000) >> 16);
        mymacaddress[1] = ((getWord(packet.pdata[2]) & 0x0000FFFF) << 16);
        macset=1;
        
#ifdef ENABLE_ETH_1
        ethTx(cExtTx1, packet);
#endif
#ifdef ENABLE_ETH_0
        ethTx(cExtTx0, packet);
#endif
        break;   
    }

  }
  

  
}

void ethernetSwitch3Port(clock clk_mii_rx_0 , in port p_mii_rxclk_0 , buffered in port:32 p_mii_rxd_0 , in port p_mii_rxdv_0 , in port p_mii_rxer_0,
             clock clk_mii_tx_0 , in port p_mii_txclk_0 , buffered out port:32 p_mii_txd_0 , out port p_mii_txen_0 ,
             clock clk_mii_rx_1 , in port p_mii_rxclk_1 , buffered in port:32 p_mii_rxd_1 , in port p_mii_rxdv_1 , in port p_mii_rxer_1,
             clock clk_mii_tx_1 , in port p_mii_txclk_1 , buffered out port:32 p_mii_txd_1 , out port p_mii_txen_1 ,
             clock clk_mii_ref, clock clk_smi, out port p_smi_mdc_0, out port p_smi_mdc_1,
             port p_smi_mdio_0,    port p_smi_mdio_1, out port p_mii_resetn,
             chanend cRx, chanend cTx, chanend cWdog)
{
  streaming chan c_mii_client_0, c_mii_tx_0, c_mii_client_1, c_mii_tx_1;
  par
  {
    // Threads constrained by I/O or latency requirements
    miimain(c_mii_client_0, c_mii_client_1, c_mii_tx_0, c_mii_tx_1,
        clk_mii_rx_0, p_mii_rxclk_0, p_mii_rxd_0, p_mii_rxdv_0, p_mii_rxer_0,
        clk_mii_tx_0, p_mii_txclk_0, p_mii_txd_0, p_mii_txen_0,
        clk_mii_rx_1, p_mii_rxclk_1, p_mii_rxd_1, p_mii_rxdv_1, p_mii_rxer_1,
        clk_mii_tx_1, p_mii_txclk_1, p_mii_txd_1, p_mii_txen_1,
        clk_mii_ref, clk_smi, p_smi_mdc_0, p_smi_mdc_1, p_smi_mdio_0, p_smi_mdio_1, p_mii_resetn
        );
    ethSwitch(c_mii_client_0, c_mii_client_1, cTx,
        c_mii_tx_0, c_mii_tx_1, cRx, cWdog);
  }
}

