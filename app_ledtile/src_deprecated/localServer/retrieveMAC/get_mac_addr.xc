// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Bridge to the MAC retrieval functions in the ethernet stack (needed to bridge XC & C)
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    getmac.xc
 *
 *
 **/                                   
#include <xs1.h>
#include "print.h"
#include "get_mac_addr.h"
#include "getmac.h"

void getMacAddr(unsigned MACAddrNum, int macAddr[6], struct otp_ports &ports)
{
	ethernet_getmac_otp_indexed(ports.data, ports.addr, ports.ctrl, macAddr, MACAddrNum);
}
