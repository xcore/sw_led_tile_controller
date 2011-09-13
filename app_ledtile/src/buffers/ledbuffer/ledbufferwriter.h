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

void sendLedData(chanend c, unsigned pixptr, unsigned len, unsigned char buf[]);
void sendLedLatch(chanend c);

#endif /*LEDBUFFERCLIENT_H_*/
