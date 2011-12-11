// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethSwitch.h
 *
 *
 **/                                   

#ifndef __ETHPHY_H__
#define __ETHPHY_H__

#include "ethPkt.h"

// ethPhyRx
// Receive packet over channel and place in s_packet structure

#ifdef __XC__
int ethPhyRx( chanend c,   s_packet &pkt,  unsigned numbytes);
#else
int ethPhyRx(unsigned c,   s_packet *pkt,  unsigned numbytes);
#endif

// ethPhyTx
// Send packet over channel from s_packet structure
#ifdef __XC__
void ethPhyTx(chanend cTx, s_packet &pkt, int &tstamp);
#else
void ethPhyTx(unsigned c,  s_packet *pkt,  int *tstamp);
#endif

// ethSwitch
// Layer 2 ethernet switch framework
// Supports two external interfaces, and one local
#ifdef __XC__
void ethSwitch( chanend cExtRx0,  chanend cExtRx1, chanend cLocRx,
        chanend cExtTx0,  chanend cExtTx1, chanend cLocTx,
       chanend cWdog);
#else
void ethSwitch( unsigned cExtRx0,  unsigned cExtRx1, unsigned cLocRx,
        unsigned cExtTx0,  unsigned cExtTx1, unsigned cLocTx,
       unsigned cWdog);
#endif

#endif /*__ETHPHY_H__*/



