// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethOther.h
 *
 *
 **/                                   
#ifndef ETHOTHER_H_
#define ETHOTHER_H_

#include "ethPkt.h"
#include "led.h"
// ---------

// Structures for XMOS packets
// --------------------------
#define OTHER
#define XMOS_SIZE 6

typedef struct
{
  unsigned char macPrefix[6];
  unsigned char ipPrefix[4];
} s_packetMacSet;

typedef struct
{
  unsigned char colchan[2];
  unsigned short gammaTable[256];
} s_packetGammaTable;

typedef struct
{
  unsigned char colchan[2];
  unsigned short intensity;
} s_packetIntensity;

typedef struct
{
  unsigned char colchan;
  unsigned char x;
  unsigned char y;
  unsigned char dummy;
  unsigned short intensity;
  unsigned short dummy2;
} s_packetIntensityPix;

typedef struct
{
  unsigned char drivertype;
  unsigned char dummy[3];
} s_packetDriverType;


typedef struct
{
  unsigned short segwidth;
  unsigned short segheight;
  unsigned short segid;
  unsigned short pixptr;
  unsigned short datalen;
  unsigned short dummy;
  // data is now word aligned
  unsigned char data[ETH_FRAME_SIZE - MAC_SIZE - IP_SIZE - UDP_SIZE - 6 - 10];
} s_packetData;

typedef struct
{
  unsigned char  magicNumber[4];
  unsigned short identifier;
  unsigned char  payload[ETH_FRAME_SIZE - MAC_SIZE - IP_SIZE - UDP_SIZE - 6];
} s_packetXmos;

#endif /*ETHOTHER_H_*/
