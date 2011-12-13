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

#include <xs1.h>
#include <xclib.h>
#include <print.h>
#include <platform.h>
#include <stdlib.h>
#include "arp.h"
#include "ethernet_conf.h"
#include "ethernet_tx_client.h"

void handle_arp_package(unsigned char rxbuf[], unsigned char txbuf[],unsigned int src_port,
unsigned int nbytes, const unsigned char own_ip_addr[4], const unsigned char own_mac_addr[6]) {
    if (is_valid_arp_packet(rxbuf, nbytes, own_ip_addr))
      {
        build_arp_response(rxbuf, txbuf, own_ip_addr, own_mac_addr);
        //TODO is that a good idea to have it here or should we rely on the fact that those functions just prepare the responses
        //mac_tx(tx, txbuf, nbytes, ETH_BROADCAST);
#ifdef ETHERNET_DEBUG_OUTPUT
        printstr("ARP response sent\n");
#endif
      }
}
int build_arp_response(unsigned char rxbuf[], unsigned char txbuf[], const unsigned char own_ip_addr[4], const unsigned char own_mac_addr[6])
{
  unsigned word;
  unsigned char byte;

  for (int i = 0; i < 6; i++)
    {
      byte = rxbuf[22+i];
      txbuf[i] = byte;
      txbuf[32 + i] = byte;
    }
  word = (rxbuf, const unsigned[])[7];
  for (int i = 0; i < 4; i++)
    {
      (txbuf, unsigned char[])[38 + i] = word & 0xFF;
      word >>= 8;
    }

  txbuf[28] = own_ip_addr[0];
  txbuf[29] = own_ip_addr[1];
  txbuf[30] = own_ip_addr[2];
  txbuf[31] = own_ip_addr[3];

  for (int i = 0; i < 6; i++)
  {
    txbuf[22 + i] = own_mac_addr[i];
    txbuf[6 + i] = own_mac_addr[i];
  }
  (txbuf, unsigned int[])[3] = 0x01000608;
  (txbuf, unsigned int[])[4] = 0x04060008;
  txbuf[20] = 0x00;
  txbuf[21] = 0x02;

  // Typically 48 bytes (94 for IPv6)
  for (int i = 42; i < 64; i++)
  {
    txbuf[i] = 0x00;
  }

  return 64;
}


int is_valid_arp_packet(const unsigned char rxbuf[], int nbytes, const unsigned char own_ip_addr[4])
{

  if (rxbuf[12] != 0x08 || rxbuf[13] != 0x06)
    return 0;

#ifdef ETHERNET_DEBUG_OUTPUT
  printstr("ARP packet received\n");
#endif

  if ((rxbuf, const unsigned[])[3] != 0x01000608)
  {
#ifdef ETHERNET_DEBUG_OUTPUT
    printstr("Invalid et_htype\n");
#endif
    return 0;
  }
  if ((rxbuf, const unsigned[])[4] != 0x04060008)
  {
#ifdef ETHERNET_DEBUG_OUTPUT
    printstr("Invalid ptype_hlen\n");
#endif
    return 0;
  }
  if (((rxbuf, const unsigned[])[5] & 0xFFFF) != 0x0100)
  {
#ifdef ETHERNET_DEBUG_OUTPUT
    printstr("Not a request\n");
#endif
    return 0;
  }
  for (int i = 0; i < 4; i++)
  {
    if (rxbuf[38 + i] != own_ip_addr[i])
    {
#ifdef ETHERNET_DEBUG_OUTPUT
     printstr("Not for us\n");
#endif
     return 0;
    }
  }

  return 1;
}
