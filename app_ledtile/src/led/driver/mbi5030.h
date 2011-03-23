// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    mbi5030.h
 *
 *
 **/                                   
#ifndef MBI5030_H_
#define MBI5030_H_

#include <led.h>

#if defined MBI5030

#ifdef __XC__
int leddrive_mbi5030(streaming chanend cLedData, streaming chanend cLedCmd, chanend cWdog, 
                   buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref
               );

#endif

// Clock dividers
// 1 = 25Mhz Clock
// 2 = 12.5Mhz Clock
// etc
#define SPI_CLKDIV        2
#define GSCLK_CLKDIV      8

#define REFRESH_RATE        600
#define FRAME_TIME       (XS1_TIMER_HZ / (SCAN_RATE * REFRESH_RATE))

#define GET_DATA(a) a
#define BITREVERSE
#define MODE12BIT

#define LOCAL_LATCH             (bitrev((1 <<  1) - 1) >> 16)
#define GLOBL_LATCH             (bitrev((1 <<  3) - 1) >> 16)
#define REGISTER_WRITE_LATCH    (bitrev((1 << 11) - 1) >> 16)


#define SELF_SYNC      (1 << 0xA)
#define GCLK_TIMEOUT   (1 << 0x0)
#define PWM_GS_12BIT   (1 << 0xD)
#define PARITY         (1 << 0xF)
#define CURRENT_GAIN   (0b11111111)


#endif

#endif /*MBI5030_H_*/
