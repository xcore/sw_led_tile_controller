// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    xmosAC.h
 *
 *
 **/                                   
#ifndef XMOSAC_H_
#define XMOSAC_H_


typedef struct
{
  unsigned char myCommandTTL;
  
  unsigned char XstartFlag;
  unsigned char YstartFlag;
  unsigned char XendFlag;
  unsigned char YendFlag;
  
  unsigned char nextXNodeMac[6];
  unsigned char nextXNodeFlag;
  
  unsigned char nextYNodeMac[6];
  unsigned char nextYNodeFlag;
} s_xmosAC;

#endif /*XMOSAC_H_*/
