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

int build_icmp_response(unsigned char rxbuf[], unsigned char txbuf[], const unsigned char own_mac_addr[6]);
int is_valid_icmp_packet(const unsigned char rxbuf[], int nbytes);

#endif /* ICMP_H_ */
