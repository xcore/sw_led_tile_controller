// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    pktbuffer.h
 *
 *
 **/                                   
#ifndef __PKTBUFFER_H__
#define __PKTBUFFER_H__

/*
 * COMMAND BUFFER
 * Buffering FIFO for commands.
 * Sinks commands such as gamma LUT changes, intensity value changes from
 * the local server and buffers them on a packet-by-packet basis in
 * a circular fifo for the LED driving thread to receive when ready.
 *
 * Packets are send via cIn and can be received via cOut.
 * For storing a package the sender sends the size of the package (int) and either receives a 0 if the package can be store
 * or a 0 if there is not enough room. If the package is accepted the sender must send as many int values as specified by the
 * length of th package.
 * The receiver can request a package by sending an arbitrary int over cOut. It then receives the size of the package as int
 * and the package data as int values. It must read all values as specified by the length.
 *
 *
 * Channels
 * cln - Streaming bidirectional command sink
 * cOut - Streaming bidirectional command source
 */

void pktbuffer(chanend cIn, streaming chanend cOut);

#endif

