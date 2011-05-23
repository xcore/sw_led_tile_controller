// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    led.h
 *
 *
 **/                                   
#ifndef LED_H_
#define LED_H_

// --------------------- GENERAL OPTIONS ---------------------
#define MAJ_VERSION          0x10
#define MIN_VERSION          0x04
#define RELEASE
//#define SIMULATION

// ------------------- USER TILE OPTIONS --------------------
// Uncomment one of the following defines to enable a drive mode
// Both MBI5026 and MBI5030 can be enabled on the same build


//#define SINGLE_INDOOR_16x32_MBI5026
//#define QUAD_INDOOR_16x32_MBI5026
//#define OCTAL_INDOOR_16x32_MBI5026
//#define HEX_INDOOR_16x32_MBI5026
//#define SINGLE_INDOOR_16x32_MBI5030
//#define QUAD_INDOOR_16x32_MBI5030
//#define OCTAL_INDOOR_16x32_MBI5030
//#define HEX_INDOOR_16x32_MBI5030
//#define SINGLE_OUTDOOR_16x16_MBI5026
#define SINGLE_INDOOR_16x32_MBI5030C
//#define TILE_OTHER

#ifdef TILE_OTHER
#define MODULE_WIDTH                            8    // Width of an LED module in pixels
#define MODULE_HEIGHT                          16    // Height of an LED module in pixels
#define NUM_MODULES_X                           2    // Number of LED modules along the width 
#define NUM_MODULES_Y                           1    // Number of LED modules along the height
#define CHAIN_LENGTH                          (8)
#define CHAIN_LOOPBACK_X                      (4)
#define CHAIN_LOOPBACK_Y                      (2)
#define SCAN_RATE                               1    // Scan ratio / time multiplex of columns
#define MBI5026
#endif

// ------------------- USER OPTIONS ----------------------------
// --------------------- Ethernet Server --------------------
// Define that will determine which components the base Ethernet server supports
#define ARP
#define ICMP
#define LED
#define TFTP 

// --------------------- TESTING ---------------------
#define LOADGAMMAFROMSPI
#define WATCHDOGRESET
//#define PTPAWARE

// --------------------- TILE SIZE CALCULATIONS--------------------------

#ifdef SINGLE_INDOOR_16x32_MBI5026
  #define INDOOR_16x32
  #define SINGLE
  #define MBI5026
#endif

#ifdef QUAD_INDOOR_16x32_MBI5026
  #define INDOOR_16x32
  #define QUAD
  #define MBI5026
#endif

#ifdef OCTAL_INDOOR_16x32_MBI5026
  #define INDOOR_16x32
  #define OCTAL
  #define MBI5026
#endif

#ifdef HEX_INDOOR_16x32_MBI5026
  #define INDOOR_16x32
  #define HEX
  #define MBI5026
#endif

#ifdef SINGLE_INDOOR_16x32_MBI5030
  #define INDOOR_16x32
  #define SINGLE
  #define MBI5030
#endif

#ifdef SINGLE_INDOOR_16x32_MBI5030C
  #define INDOOR_16x32
  #define SINGLE
  #define MBI5030C
#endif

#ifdef QUAD_INDOOR_16x32_MBI5030
  #define INDOOR_16x32
  #define QUAD
  #define MBI5030
#endif

#ifdef OCTAL_INDOOR_16x32_MBI5030
  #define INDOOR_16x32
  #define OCTAL
  #define MBI5030
#endif

#ifdef HEX_INDOOR_16x32_MBI5030
  #define INDOOR_16x32
  #define HEX
  #define MBI5030
#endif

#ifdef DUAL_OUTDOOR_8x16_MBI5026
  #define OUTDOOR_8x16
  #define DUAL
  #define MBI5026
#endif

#ifdef INDOOR_16x32
#define SCAN_RATE                             (8)
#define MODULE_WIDTH                         (16)
#define MODULE_HEIGHT                        (32)
#define CHAIN_LENGTH                          (32)
#define CHAIN_LOOPBACK_X                      (1)
#define CHAIN_LOOPBACK_Y                      (1)
#endif

#ifdef OUTDOOR_8x16
#define SCAN_RATE                             (1)
#define MODULE_WIDTH                          (8)
#define MODULE_HEIGHT                        (16)
#define CHAIN_LENGTH                          (8)
#define CHAIN_LOOPBACK_X                      (4)
#define CHAIN_LOOPBACK_Y                      (2)
#endif

#ifdef SINGLE
#define NUM_MODULES_X                         (1)
#define NUM_MODULES_Y                         (1)
#endif

#ifdef QUAD
#define NUM_MODULES_X                         (2)
#define NUM_MODULES_Y                         (2)
#endif

#ifdef OCTAL
#define NUM_MODULES_X                         (4)
#define NUM_MODULES_Y                         (2)
#endif

#ifdef HEX
#define NUM_MODULES_X                         (6)
#define NUM_MODULES_Y                         (2)
#endif

#ifdef MBI5026
#define LEDS_PER_DRIVER                      (16)
#endif
#ifdef MBI5030
#define LEDS_PER_DRIVER                      (16)
#endif
#ifdef MBI5030C
#define LEDS_PER_DRIVER                      (16)
#define MBI5030
#endif

#define FRAME_HEIGHT         (MODULE_HEIGHT * NUM_MODULES_Y) // Height of frame in pixels
#define FRAME_WIDTH          (MODULE_WIDTH * NUM_MODULES_X) // Width of frame in pixels
//size of the internal fifo buffers in bits (so the real size will be 2^PKTBUFFERBITS
#define PKTBUFFERBITS                         (9)
#endif /*LED_H_*/

