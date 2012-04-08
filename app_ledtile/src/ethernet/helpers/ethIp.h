// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethIp.h
 *
 *
 **/                                   
#ifndef __ETHIP_H__
#define __ETHIP_H__

#include "ethPkt.h"

// Ethernet IP / UDP Functions

// (Re:)Calculate UDP checksum
void udpChecksum(s_packetUdp *u);

// Set UDP datagram size
void setUdpSize(s_packetMac *m, int size);

// (Re:)Calculate IP checksum
void ipChecksum(s_packetIp *i);

// Initialise standard UDP / IP packet
void ipInit(s_packetIp *i);

#endif
