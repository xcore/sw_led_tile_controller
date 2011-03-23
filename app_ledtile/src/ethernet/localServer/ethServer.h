// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethServer.h
 *
 *
 **/                                   
#ifndef ETHSERVER_H_
#define ETHSERVER_H_

// Standard local ethernet server
// Supports ICMP, ARP, TFTP
// Also supports user-definable protocols with two user defined channels
void ethServer(streaming chanend cRx, chanend cTx, chanend cLedData, chanend cLedCmd, chanend cSpiFlash, chanend cWdog);

#endif /*ETHSERVER_H_*/
