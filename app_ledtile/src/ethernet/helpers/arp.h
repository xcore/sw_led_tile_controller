// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
 *
 * ARP library.
 * Some simple functions to handle ARP packages
 *
 *************************************************************************
 *
 * Documentation & functional analysis still needed
 *
 *************************************************************************/
#ifndef ARP_H
#define ARP_H

void handle_arp_package(chanend tx, unsigned char rxbuf[], unsigned char txbuf[],unsigned int src_port,
unsigned int nbytes, const unsigned char own_ip_addr[4], const int own_mac_addr[6]);
int build_arp_response(unsigned char rxbuf[], unsigned char txbuf[], const unsigned char own_ip_addr[4], const int own_mac_addr[6]);
int is_valid_arp_packet(const unsigned char rxbuf[], int nbytes, const unsigned char own_ip_addr[4]);

#endif
