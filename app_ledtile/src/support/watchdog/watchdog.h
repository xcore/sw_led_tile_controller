// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    watchdog.h
 *
 *
 **/                                   
#define SWITCH_WAIT             100000
#define SERV_WAIT               100000
#define LED_WAIT                100000
#define WDOG_WAIT           4000000000 // 10 second timeout
#define WDOG_INITIAL_WAIT   1000000000

#ifndef WATCHDOG_H_
#define WATCHDOG_H_

#define NUM_WATCHDOG_CHANS 3

void watchDog(chanend c[NUM_WATCHDOG_CHANS], int slowdown);

#endif /*WATCHDOG_H_*/
