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

#include <xs1.h>
#include <xclib.h>
#include <print.h>
#include <platform.h>
#include <stdlib.h>
#include "icmp.h"
#include "ethernet_conf.h"
#include "ethernet_tx_client.h"
#include "checksum.h"

void handle_icmp_package(unsigned char rxbuf[], unsigned char txbuf[],unsigned int src_port,
		unsigned int nbytes, const unsigned char own_ip_addr[4], const int own_mac_addr[6]) {
	if (is_valid_icmp_packet(rxbuf, nbytes, own_ip_addr))
	      {
	        build_icmp_response(rxbuf, txbuf, own_ip_addr, own_mac_addr);
	        mac_tx(tx, txbuf, nbytes, ETH_BROADCAST);
#ifdef ETHERNET_DEBUG_OUTPUT
	        printstr("ICMP response sent\n");
#endif
	      }
}

int build_icmp_response(unsigned char rxbuf[], unsigned char txbuf[], const unsigned char own_ip_addr[4], const int own_mac_addr[6])
{
  unsigned icmp_checksum;
  int datalen;
  int totallen;
  const int ttl = 0x40;
  int pad;

  // Precomputed empty IP header checksum (inverted, bytereversed and shifted right)
  unsigned ip_checksum = 0x0185;

  for (int i = 0; i < 6; i++)
    {
      txbuf[i] = rxbuf[6 + i];
    }
  for (int i = 0; i < 4; i++)
    {
      txbuf[30 + i] = rxbuf[26 + i];
    }
  icmp_checksum = byterev((rxbuf, const unsigned[])[9]) >> 16;
  for (int i = 0; i < 4; i++)
    {
      txbuf[38 + i] = rxbuf[38 + i];
    }
  totallen = byterev((rxbuf, const unsigned[])[4]) >> 16;
  datalen = totallen - 28;
  for (int i = 0; i < datalen; i++)
    {
      txbuf[42 + i] = rxbuf[42+i];
    }

  for (int i = 0; i < 6; i++)
  {
    txbuf[6 + i] = own_mac_addr[i];
  }
  (txbuf, unsigned[])[3] = 0x00450008;
  totallen = byterev(28 + datalen) >> 16;
  (txbuf, unsigned[])[4] = totallen;
  ip_checksum += totallen;
  (txbuf, unsigned[])[5] = 0x01000000 | (ttl << 16);
  (txbuf, unsigned[])[6] = 0;
  for (int i = 0; i < 4; i++)
  {
    txbuf[26 + i] = own_ip_addr[i];
  }
  ip_checksum += (own_ip_addr[0] | own_ip_addr[1] << 8);
  ip_checksum += (own_ip_addr[2] | own_ip_addr[3] << 8);
  ip_checksum += txbuf[30] | (txbuf[31] << 8);
  ip_checksum += txbuf[32] | (txbuf[33] << 8);

  txbuf[34] = 0x00;
  txbuf[35] = 0x00;

  icmp_checksum = (icmp_checksum + 0x0800);
  icmp_checksum += icmp_checksum >> 16;
  txbuf[36] = icmp_checksum >> 8;
  txbuf[37] = icmp_checksum & 0xFF;

  while (ip_checksum >> 16)
  {
    ip_checksum = (ip_checksum & 0xFFFF) + (ip_checksum >> 16);
  }
  ip_checksum = byterev(~ip_checksum) >> 16;
  txbuf[24] = ip_checksum >> 8;
  txbuf[25] = ip_checksum & 0xFF;

  for (pad = 42 + datalen; pad < 64; pad++)
  {
    txbuf[pad] = 0x00;
  }
  return pad;
}


int is_valid_icmp_packet(const unsigned char rxbuf[], int nbytes, const unsigned char own_ip_addr[4])
{
  unsigned totallen;


  if (rxbuf[23] != 0x01)
    return 0;

#ifdef ETHERNET_DEBUG_OUTPUT
  printstr("ICMP packet received\n");
#endif
  if ((rxbuf, const unsigned[])[3] != 0x00450008)
  {
#ifdef ETHERNET_DEBUG_OUTPUT
    printstr("Invalid et_ver_hdrl_tos\n");
#endif
    return 0;
  }
  if (((rxbuf, const unsigned[])[8] >> 16) != 0x0008)
  {
#ifdef ETHERNET_DEBUG_OUTPUT
    printstr("Invalid type_code\n");
#endif
    return 0;
  }
  for (int i = 0; i < 4; i++)
  {
    if (rxbuf[30 + i] != own_ip_addr[i])
    {
#ifdef ETHERNET_DEBUG_OUTPUT
      printstr("Not for us\n");
#endif
      return 0;
    }
  }

  totallen = byterev((rxbuf, const unsigned[])[4]) >> 16;
  if (nbytes > 60 && nbytes != totallen + 14)
  {
#ifdef ETHERNET_DEBUG_OUTPUT
    printstr("Invalid size\n");
    printintln(nbytes);
    printintln(totallen+14);
#endif
    return 0;
  }
  if (checksum_ip(rxbuf) != 0)
  {
#ifdef ETHERNET_DEBUG_OUTPUT
    printstr("Bad checksum\n");
#endif
    return 0;
  }

  return 1;
}
