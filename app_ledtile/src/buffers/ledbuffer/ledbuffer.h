// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ledbuffer.h
 *
 *
 **/                                   
#ifndef __LEDBUFFER_H__
#define __LEDBUFFER_H__

// ledbuffer
// Frame buffer for pixel data
// Uses "double-buffer" scheme with tearing prevention

#ifdef __XC__
void ledbuffer(chanend cIn, streaming chanend cOut);
#else
void ledbuffer(unsigned cIn, unsigned cOut);
#endif

#endif

