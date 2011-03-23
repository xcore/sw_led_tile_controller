// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ledprocess.h
 *
 *
 **/                                   
#ifndef LEDPROCESS_H_
#define LEDPROCESS_H_

#include "led.h"

#define FRAME_SIZE       (FRAME_HEIGHT * FRAME_WIDTH)
#define BUFFER_SIZE      (FRAME_HEIGHT * NUM_MODULES_X)
#define NUM_DRIVERS      (BUFFER_SIZE/LEDS_PER_DRIVER)


#define START_IP_X               0x01
#define START_IP_Y               0x01

#define XMOS_VERSION             0x01
#define XMOS_DATA                0x02
#define XMOS_LATCH               0x03
#define XMOS_GAMMAADJ            0x04
#define XMOS_INTENSITYADJ        0x05
#define XMOS_SINTENSITYADJ       0x06
#define XMOS_RESET               0x07
#define XMOS_AC_1                0x08
#define XMOS_AC_2                0x09
#define XMOS_AC_3                0x0A
#define XMOS_AC_4                0x0B
#define XMOS_SINTENSITYADJ_PIX   0x0C
#define XMOS_CHANGEDRIVER        0x0D
#define XMOS_DSPADJ              0x0E

// XMOS Packets come in on this port
#define PORT_XMOS          306
//#define PER_PIXEL_ADJUSTMENT

// ledreprocess
// Load pixel data from buffer and apply gamma LUT and intensity colour correction
#ifdef __XC__
void ledprocess_init();
int ledprocess_commands(streaming chanend cLedCmd, streaming chanend cOut, int oeen);
#else
void ledprocess_init();
int ledprocess_commands(unsigned cLedCmd, unsigned cOut, int oeen);
#endif


#endif /*LEDPROCESS_H_*/
