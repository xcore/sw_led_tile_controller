// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethTftp.h
 *
 *
 **/                                   
#ifndef ETHTFTP_H_
#define ETHTFTP_H_

#include "ethPkt.h"

// TFTP Defines
#define TFTP_OPCODE_RRQ      1
#define TFTP_OPCODE_WRQ      2
#define TFTP_OPCODE_DATA     3
#define TFTP_OPCODE_ACK      4
#define TFTP_OPCODE_ERROR    5
#define PORT_TFTP            69
#define TFTP_SIZE            4

// TFTP Structure
typedef struct
{
  unsigned short opcode;
  unsigned char data[ETH_FRAME_SIZE - MAC_SIZE - IP_SIZE - UDP_SIZE - 2];
} s_packetTftp;

// process TFTP packet
void processTftp(s_packet *p, s_packetTftp *t, unsigned cTx, unsigned cFlash);

#endif /*ETHTFTP_H_*/
