// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    math.h
 *
 *
 **/                                   

#ifndef MATH_H_
#define MATH_H_

unsigned countOnes(unsigned input);

#ifndef __XC__
void memswap(unsigned char *a, unsigned char *b, unsigned len);
#endif

#endif /*MATH_H_*/
