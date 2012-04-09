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
 *
 * cIn protocol:
 * the writer sends a single integer as write start address
 * if the start address  is -1 the writer requests swapping the buffers
 * else the address is interpreted as a pixel in the pixel buffer (remember the data is stored by column)
 * the second argument for data is a integer for the lenght of the data to be stored (best a multiple of 3).
 * After that the writer must provide as many chars as specified by the length.
 *
 * cOut protocol:
 * reader writes an int to cOut.
 * If it is -1 the driver singals that a latch can occur.
 * It is is another value the corresponding row (or column - depending on compile options) is send to the led driver
 * Always a complete row is put out with FRAME_HEIGHT char values
 */

#ifdef __XC__
void ledbuffer(chanend cIn, streaming chanend cOut);
#else
void ledbuffer(unsigned cIn, unsigned cOut);
#endif

#endif

