// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ledbufferclient.xc
 *
 *
 **/                                   
void sendLedData(chanend c, unsigned pixptr, unsigned len, unsigned char buf[])
{
  int i = len;
  master
  {
      c <: pixptr;
      c <: len;
      for (int i=0; i<len; i+=3)
      {
      c <: (char)buf[i];
      c <: (char)buf[i+1];
      c <: (char)buf[i+2];
      }
  }
}

void sendLedLatch(chanend c)
{
  master
  {
    c <: -1;
  }
}

