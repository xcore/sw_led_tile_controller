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

/*
 * DATA BUFFER
 * Double-buffered frame store. Frame buffer for storing pixel data.
 * Sinks incoming data from the local server, and sources data to the LED driving threads.
 * Supports frame turnaround without tearing.
 *
 * Channels
 * cln - Streaming bidirectional pixel sink
 * cOut -Streaming bidirectional pixel source
 */

#ifdef __XC__
void ledbuffer(chanend cIn, streaming chanend cOut);
#else
void ledbuffer(unsigned cIn, unsigned cOut);
#endif

#endif

