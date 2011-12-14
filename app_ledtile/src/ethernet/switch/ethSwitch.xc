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
#include "print.h"
#include "ethernet_server.h"
#include "ethernet_tx_client.h"
#include "ethernet_rx_client.h"
#include "get_mac_addr.h"
#include "getmac.h"
#include "arp.h"
#include "icmp.h"
#include "otp_data.h"
#include "smi.h"
#include "mii.h"

#include "ethSwitch.h"
#include "ethernet_conf.h"

//local prototypes
void initAddresses(int macAddr[], unsigned char ip_addr[4], struct otp_ports& otp_ports);
void ethSwitch(chanend cExtRx, chanend cLocRx, chanend cExtTx, chanend cLocTx, const unsigned char own_ip_addr[4], const int own_mac_addr[6]);

void startEthServer(chanend c_local_tx, chanend c_local_rx, clock clk_smi, out port ?p_mii_resetn,
		smi_interface_t &smi0, smi_interface_t &smi1, mii_interface_t &mii0,
		mii_interface_t &mii1, struct otp_ports& otp_ports) {

	//who are we
	int mac_addr[6];
	//for parallel usage we need two separate representations of the mac address
	int ethSwitch_mac_addr[6];
	unsigned char ip_address[4];
	//and we need some channels to talk to the local server
	chan rx[1], tx[1];

	//initialize the networking interfaces
	phy_init_two_port(clk_smi, p_mii_resetn, smi0, smi1, mii0, mii1);
	//initialize the mac & ip addresses
	initAddresses(mac_addr,ip_address,otp_ports);
#ifdef ETHERNET_DEBUG_OUTPUT
  printstr("Adresses initialized:\n");
  printstr("MAC ");
  for (int i=0; i<6;i++) {
	  printhex((unsigned int)mac_addr[i]);
	  printstr(" ");
  }
  printstr("\n");
  printstr("IP ");
  for (int i=0;i<4;i++) {
	  printint(ip_address[i]);
	  if (i<3) {
		  printstr(".");
	  }
  }
  printstr("\n");
#endif
	//copy over the mac address
	for (int i=0; i <6; i++) {
		ethSwitch_mac_addr[i] = mac_addr[i];
	}

	//let's really start the servers
	par
	{
		//the ethernet server
		ethernet_server_two_port(mii0, mii1, mac_addr, rx, 1, tx, 1,
				smi0, smi1, null);
		//and the local stuff
		ethSwitch(rx[0], c_local_rx, tx[0], c_local_tx, ip_address, ethSwitch_mac_addr);
	}
}



// ethSwitch
// Layer 2 ethernet switch framework
// Supports two external interfaces, and one local
#pragma unsafe arrays
void ethSwitch(chanend cExtRx, chanend cLocRx, chanend cExtTx, chanend cLocTx, const unsigned char own_ip_addr[4], const int own_mac_addr[6]) {
	unsigned int rxbuffer[1600 / 4];
	unsigned int txbuffer[1600 / 4];
	unsigned int src_port;
	unsigned int nbytes;

	mac_set_custom_filter(cExtRx, 0x1);

	while (1) {
		mac_rx(cExtRx, (rxbuffer, unsigned char[]), nbytes, src_port);
		handle_arp_package(cExtTx,(rxbuffer, unsigned char[]), (txbuffer, unsigned char[]),src_port, nbytes, own_ip_addr, own_mac_addr);
		handle_icmp_package(cExtTx, (rxbuffer, unsigned char[]), (txbuffer, unsigned char[]),src_port, nbytes, own_ip_addr, own_mac_addr);
	}
}


// Reset the addresses structure with default mac address and IP address
void initAddresses(int macAddr[], unsigned char ip_addr[4], struct otp_ports& otp_ports)
{
#ifndef SIMULATION

  //retrieve the mac address
	ethernet_getmac_otp(otp_ports.data, otp_ports.addr, otp_ports.ctrl, macAddr);
#endif

  //self assign an IP address
  //TODO this is easier to find if it is defined in some header file
  ip_addr[0] = INITIAL_IP_0;
  ip_addr[1] = INITIAL_IP_1;
  ip_addr[2] = INITIAL_IP_2;
  ip_addr[3] = INITIAL_IP_3;
}
