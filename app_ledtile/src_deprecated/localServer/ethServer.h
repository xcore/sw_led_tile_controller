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

/*
 *
 * LOCAL SERVER
 * Local Ethernet server. This thread deals with sorting and parsing of all local Ethernet frames.
 * It responds to ICMP, ARP, parses LED video data and latch commands sent over UDP.
 * LED specific data is forwarded to the next thread. Future implementations will include BOOTP/DHCP
 * and TFTP for boot-from-Ethernet.
 * Also supports user-definable protocols with two user defined channels
 *
 * Channels
 * cRx - streaming bidirectional Data receive
 * cTx - streaming bidirectional Data receive
 * cLedData - Streaming bidirectional Pixel data output
 * cLedCmd - Streaming bidirectional Command output
 */
void ethServer(streaming chanend cRx, chanend cTx, chanend cLedData, chanend cLedCmd, chanend cSpiFlash, chanend cWdog);

#endif /*ETHSERVER_H_*/
