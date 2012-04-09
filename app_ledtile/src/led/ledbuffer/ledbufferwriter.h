// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ledbufferclient.h
 *
 *
 **/                                   
#ifndef LEDBUFFERCLIENT_H_
#define LEDBUFFERCLIENT_H_

/**
 * Routine to send LED data to the internal led buffer.
 * The LED data is send as bulk, so the correct organization in rows & cols
 * must have done before
 * c - the chanend to the led buffer
 * pixptr - the position in the led buffer (normally pointing to the begin of a column)
 * len - the lenght of the data transmitted
 * buf the data itself, must be at least the lenght of len
 */
void sendLedData(chanend c, unsigned pixptr, unsigned len, unsigned char buf[]);

/**
 * send a latch signal to the buffer.
 * The latch signal indicates that a frame is constructed by the led data and can be send to the output modules
 * c - the channel to the led buffer
 */
void sendLedLatch(chanend c);

#endif /*LEDBUFFERCLIENT_H_*/
