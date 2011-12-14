// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
 *
 * ICMP library.
 * Some simple functions to handle ICMP packages
 *
 *************************************************************************
 *
 * Documentation & functional analysis still needed
 *
 *************************************************************************/
#ifndef ICMP_H_
#define ICMP_H_

void handle_icmp_package(unsigned char rxbuf[], unsigned char txbuf[],unsigned int src_port,
		unsigned int nbytes, const unsigned char own_ip_addr[4], const int own_mac_addr[6]);
int build_icmp_response(unsigned char rxbuf[], unsigned char txbuf[], const unsigned char own_ip_addr[4], const int own_mac_addr[6]);
int is_valid_icmp_packet(const unsigned char rxbuf[], int nbytes, const unsigned char own_ip_addr[4]);

#endif /* ICMP_H_ */
