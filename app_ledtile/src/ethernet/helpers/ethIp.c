// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethIp.c
 *
 *
 **/                                   
#include "ethIp.h"

// Ethernet IP / UDP Functions

// udpChecksum
// (Re:)Calculate UDP checksum
void udpChecksum(s_packetUdp *u)
{
  u->checksum=0; //TODO this is plain wrong - we should integrate something like http://www.netfor2.com/udpsum.htm
}

void setUdpSize(s_packet *p, int size)
{
  s_packetMac *m;
  s_packetIp *i; 
  s_packetUdp *u;
  
  m = (s_packetMac *)p->pdata;
  i = (s_packetIp *)m->payload;
  u = (s_packetUdp *)i->payload;
  
  p->plen_b = MAC_SIZE + IP_SIZE + UDP_SIZE + size;
  i->length = getShort(IP_SIZE + UDP_SIZE + size);
  u->length = getShort(UDP_SIZE + size);
}

// ipInit
// Initialise standard UDP / IP packet
void ipInit(s_packetIp *i)
{
  i->version = 0x45;
  i->ToS = 0x10;
  i->id  = 0;
  i->flags_fragoffset = 0;
  i->ttl = getChar(99);
  i->proto = getChar(PROTO_UDP); //udp
}

// ipChecksum
// (Re:)Calculate IP checksum
void ipChecksum(s_packetIp *i)
{
  int ipchecksum = 0, j;
  unsigned short *ipptr = (unsigned short *)i;

  i->headercheck = getWord(0);

  for (j=0; j<10; j++)
    ipchecksum += getShort(ipptr[j]);
  
  i->headercheck = ~getShort((ipchecksum & 0xFFFF) + (ipchecksum >> 16));
}
