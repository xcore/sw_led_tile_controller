// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    math.c
 *
 *
 **/                                   
unsigned countOnes(unsigned input)
{
  int i;
  unsigned retVal=0;
  for (i=0; i<16; i++)
  {
    if (input & 1)
      retVal++;
    input>>=1;
  }
  return retVal;
}

void memswap(unsigned char *a, unsigned char *b, unsigned len)
{
  int i;
  for (i = 0; i < len; i++)
  {
    a[i] ^= b[i];
    b[i] ^= a[i];
    a[i] ^= b[i];
  }
}
