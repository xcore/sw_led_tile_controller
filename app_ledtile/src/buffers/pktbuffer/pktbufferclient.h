// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    pktbufferclient.h
 *
 *
 **/                                   
#ifndef PKTBUFFERCLIENT_H_
#define PKTBUFFERCLIENT_H_

/*
 * send packets to the command buffer
 *
 * Channel
 * c - the packet sink channel of the packet buffer
 *
 * len - the length of the data package
 * data - the data package itself
 */
void sendPktData(chanend c, unsigned len, unsigned data[]);

#endif /*PKTBUFFERCLIENT_H_*/
