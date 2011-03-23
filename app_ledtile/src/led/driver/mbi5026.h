// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    mbi5026.h
 *
 *
 **/                                   
#ifndef MBI5026_H_
#define MBI5026_H_

#include "led.h"

#if defined MBI5026

#ifdef __XC__
int leddrive_mbi5026(streaming chanend cLedData, streaming chanend cLedCmd, chanend cWdog, 
                   buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref
               );
#endif

// SPI Clock divider
// 1 = 25Mhz SPI Clock
// 2 = 12.5Mhz SPI Clock
// etc
#define SPI_CLKDIV        2

// OE Resolution
// In 10nS units.
// MBI5026 = 200nS
#define OE_MULTI        (20)

#define GET_DATA(a) a
#define BITREVERSE

// Add some extra dither over multiple frame-times
// Increased bit depth but produces noticable flicker
//#define SOFT_DITHER

// Color depth of output
#define BCM_BITS         (10)

// Specify the number of times the driver refresh should be repeated
// Use to simulate increased panel sizes
#define DRIVE_REPEAT_COUNT    (1)


// ----------------------- Calculated Defines -----------------
#define PORT_WIDTH            (6)
#define LEDS_PER_CHAIN   (CHAIN_LENGTH * CHAIN_LOOPBACK_X * CHAIN_LOOPBACK_Y * NUM_MODULES_X * NUM_MODULES_Y)
#define INPUT_BUF_SIZE  (LEDS_PER_CHAIN * SCAN_RATE * PORT_WIDTH )
#define OUTPUT_BUF_SIZE ((LEDS_PER_CHAIN * SCAN_RATE * PORT_WIDTH ) / 32)
#define OUTS_PER_CYCLE  (LEDS_PER_CHAIN / 32)

#endif

#endif /*MBI5026_H_*/
