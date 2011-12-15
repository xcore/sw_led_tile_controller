// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethPkt.h
 *
 * This file contains packet and value definitions for most of the
 *
 **/                                   
#ifndef __ETHPKT_H__
#define __ETHPKT_H__

// -------- A bunch of ethernet defines and typedefed structures -------

#define SWITCH_LOCAL_BUFFER

#define NEW_MAC_ADDRESS     01


// ICMP Defines
#define ICMP_ECHOREQUEST     8
#define ICMP_CODE            0
#define ICMP_ECHOREPLY       0

// ARP Defines
#define ARP_REQUEST     0x0001
#define ARP_REPLY       0x0002
#define ARP_ETHERNET    0x0001
#define ARP_PROTO_IP    0x0800
#define ARP_ETHERNET_HLEN    6
#define ARP_IP_PROTOLEN      4

// ETHERTYPE Defines
#define ETHERTYPE_IP    0x0800
#define ETHERTYPE_ARP   0x0806

// IP Protocol Defines
#define PROTO_ICMP           1
#define PROTO_UDP           17

// Ethernet Defines
#define ETH_FRAME_SIZE    1600
#define MAC_SIZE            14
#define IP_SIZE             20
#define UDP_SIZE             8
#define DHCP_SIZE          236
#define ICMP_SIZE            8

#if defined __XS1A__ || defined __XS1B__
#include <xclib.h>
#endif

// Ethernet is MSB first, so all data retrieval must be reversed for XCore
#define getChar(a)  a
#define getShort(a) ((((a) & 0xFF) << 8) | (((a) & 0xFF00) >> 8))
#define getWord(a) (byterev(a))

#ifndef __XC__

typedef struct
{
  unsigned short sourceport;
  unsigned short destport;
  unsigned short length;
  unsigned short checksum;
  unsigned char payload[ETH_FRAME_SIZE - MAC_SIZE - IP_SIZE - UDP_SIZE];
} s_packetUdp;

typedef struct
{
  unsigned char type;
  unsigned char code;
  unsigned short checksum;
  unsigned short id;
  unsigned short sequence;
  unsigned char data[ETH_FRAME_SIZE - MAC_SIZE - IP_SIZE - ICMP_SIZE];
} s_packetIcmp;
  
typedef struct
{
  unsigned char version;
  unsigned char ToS;
  unsigned short length;
  unsigned short id;
  unsigned short flags_fragoffset;
  unsigned char ttl;
  unsigned char proto;
  unsigned short headercheck;
  unsigned char source[4];
  unsigned char dest[4];
  unsigned char payload[ETH_FRAME_SIZE - MAC_SIZE - IP_SIZE];
} s_packetIp;

typedef struct
{
  unsigned short htype;
  unsigned short ptype;
  unsigned char hlen;
  unsigned char plen;
  unsigned short oper;
  unsigned char sha[6];
  unsigned char spa[4];
  unsigned char tha[6];
  unsigned char tpa[4];
} s_packetArp;

typedef struct
{
  // MAC Header
  unsigned char destmac[6];
  unsigned char sourcemac[6];
  unsigned short ethertype;
  unsigned char payload[ETH_FRAME_SIZE - MAC_SIZE];
} s_packetMac;

#endif

typedef struct
{
  char ipAddress[4];
  unsigned macAddress[2];
} s_addresses;

typedef struct 
{
  unsigned ptpcorrect;
  unsigned timestamp;
  unsigned plen_b;
  unsigned pdata[ETH_FRAME_SIZE / 4];
} s_packet;

#endif

