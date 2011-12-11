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

// ethSwitch
// Layer 2 ethernet switch framework
// Supports two external interfaces, and one local
#ifdef __XC__
void ethSwitch( chanend cExtRx,  chanend cLocRx,
        chanend cExtTx,  chanend cLocTx);
#else
void ethSwitch( unsigned cExtRx,  unsigned cLocRx,
        unsigned cExtTx,  unsigned cLocTx);
#endif

#endif /*__ETHPHY_H__*/



