// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethServerProcess.h
 *
 *
 **/                                   
#ifndef ETHSERVERPROCESS_H_
#define ETHSERVERPROCESS_H_

#include "ethPkt.h"
#include "getmac.h"

// initAddresses
// Initialise the addresses structure with the default MAC address and IP address
#ifdef __XC__
void initAddresses(s_addresses &addresses, struct otp_ports &otp_ports);
#else
void initAddresses(s_addresses *addresses, struct otp_ports *otp_ports);
#endif

// ethServerProcess
// Process ethernet packets. Supports ICMP, ARP, TFTP
// Also supports user-definable protocols with two user defined channels
#ifdef __XC__
void ethServerProcess(s_packet &packet, chanend cTx, chanend cOther0, chanend cOther1, chanend cFlash, s_addresses &addresses, int direction);
#else
void ethServerProcess(s_packet *packet, unsigned cTx, unsigned cOther0, unsigned cOther1, unsigned cFlash, s_addresses *addresses, int direction)
#endif

#endif /*ETHSERVERPROCESS_H_*/
