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
#include "print.h"
#include "ethernet_server.h"
#include "ethernet_tx_client.h"
#include "ethernet_rx_client.h"
#include "getmac.h"
#include "arp.h"
#include "icmp.h"

// ethSwitch
// Layer 2 ethernet switch framework
// Supports two external interfaces, and one local
#pragma unsafe arrays
void ethSwitch(chanend cExtRx, chanend cLocRx,
		chanend cExtTx, chanend cLocTx) {
	unsigned int rxbuffer[1600 / 4];
	unsigned int src_port;
	unsigned int nbytes;

	mac_set_custom_filter(cExtRx, 0x1);

	while (1) {
		mac_rx(cExtRx, (rxbuffer, unsigned char[]), nbytes, src_port);
		handle_arp_package(rxbuffer, txbuffer,src_port, nbytes);
		handle_icmp_package(rxbuffer, txbuffer,src_port, nbytes);
	}
}
