// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethServerProcess.c
 *
 *
 **/                                   
#include "get_mac_addr.h"
#include "ethPkt.h"
#include "ethSwitch.h"
#include "ethIp.h"
#include "string.h"
#include "stdlib.h"
#include <xclib.h>
#include "ethOther.h"
#include "led.h"
#include "math.h"

#ifdef DHCP
#include "ethDhcp.h"
#endif

#ifdef TFTP
#include "ethTftp.h"
#endif

// Reset the addresses structure with default mac address and IP address
void initAddresses(s_addresses *addresses, struct otp_ports *otp_ports)
{
#ifndef SIMULATION
  
  unsigned mac[2];

  //retrieve the mac address
  getMacAddr(0, mac, otp_ports);
#endif

  //self assign an IP address
  //TODO this is easier to find if it is defined in some header file
  addresses->ipAddress[0] = 192;
  addresses->ipAddress[1] = 168;
  addresses->ipAddress[2] = 0;
  addresses->ipAddress[3] = 254;
}

// Process a packet received from the ethernet switch
// Supports user-defined protocols with two other channends
void ethServerProcess(s_packet *packet, unsigned cTx, unsigned cOther0, unsigned cOther1, unsigned cFlash, s_addresses *addresses, int direction)
{
  int null;
  s_packetMac *m;
  s_packetIp *i; 
  
  m = (s_packetMac *)packet->pdata;
  i = (s_packetIp *)m->payload;

  
#ifdef ICMP
  // ICMP Packets
  if (getShort(m->ethertype) == ETHERTYPE_IP && getChar(i->proto) == PROTO_ICMP)
  {
    s_packetIp *i; 
    s_packetIcmp *icmp;
    
    i = (s_packetIp *)m->payload;
    icmp = (s_packetIcmp *)i->payload;
    
    // Check if targetting our IP address
    if (memcmp(i->dest, addresses->ipAddress, 4) == 0)
    {
      // Check if valid IP echo request
      if (icmp->type == ICMP_ECHOREQUEST
          && icmp->code == ICMP_CODE)
      {
        unsigned short *ptr;
        unsigned icmpchecksum=0;
        int j;
        // Create reply
        icmp->type = ICMP_ECHOREPLY;
        
        // Recalculate ICMP checksum
        icmp->checksum = 0;
        ptr = (unsigned short *)&icmp->type;
        for (j=0; j < (getShort(i->length) - IP_SIZE) >> 1; j++)
        {
        	icmpchecksum += getShort(ptr[j]);
        }
        icmp->checksum = ~getShort((icmpchecksum & 0xFFFF) + (icmpchecksum >> 16));
        
        // Reverse destination and source MAC addresses
        memswap(m->destmac, m->sourcemac, 6);
        
        // Reverse destination and source IP addresses
        memswap(i->dest, i->source , 4);
        
        // Transmit packet in direction it came from
        ethPhyTx(cTx, packet, &null);
      }
    }
  }
#endif
  
#ifdef ARP
  // ARP Packets
  if (getShort(m->ethertype) == ETHERTYPE_ARP)
  {
    s_packetArp *a = (s_packetArp *)m->payload;
    
    if (getShort(a->htype)     == ARP_ETHERNET
        && getShort(a->ptype)  == ARP_PROTO_IP
        && getChar(a->hlen)    == ARP_ETHERNET_HLEN
        && getChar(a->plen)    == ARP_IP_PROTOLEN)
    {
      // Valid ARP packet
      // Look for requests
      if (getShort(a->oper) == ARP_REQUEST)
      {
    	// Check if asked for location of my IP address
        if (memcmp(a->tpa, addresses->ipAddress, 4) == 0)
        {
          // Requested me
          a->oper = getShort(ARP_REPLY);
          memcpy((void*)a->tha, (void*)a->sha, 6);
          memcpy((void*)a->tpa, (void*)a->spa, 4);
          memcpy((void*)a->sha, (void*)addresses->macAddress, 6);
          memcpy((void*)a->spa, (void*)addresses->ipAddress, 4);
          
          // Reverse destination and source MAC addresses
          memcpy((void*)m->destmac, (void*)m->sourcemac, 6);
          memcpy((void*)m->sourcemac, (void*)addresses->macAddress, 6);
          
          // Tranmit packet in direction it came from
          ethPhyTx(cTx, packet, &null);
        }
      }
    }
  }
#endif
  
#ifdef DHCP
  // TODO: DHCP. Replace with BOOTP?
#endif

#ifdef TFTP
  if (getShort(m->ethertype) == ETHERTYPE_IP && getChar(i->proto) == PROTO_UDP)
  {
    s_packetUdp *u;
    u = (s_packetUdp *)i->payload;
    
       
    if(getShort(u->destport) == PORT_TFTP)
    {
      processTftp(packet, (s_packetTftp *)u->payload, cTx, cFlash);
    }
  }
#endif
  
#ifdef OTHER
  // Process other packet types
  ethOtherProcess(packet, cTx, cOther0, cOther1, cFlash, addresses, direction);
#endif
  
  return;
}
