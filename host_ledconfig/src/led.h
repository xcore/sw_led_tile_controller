// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedConfig
 * Version: 9.10.0
 * Build:   N/A
 * File:    src/led.h
 *
 **/                                   

#ifndef LED_H_
#define LED_H_

// --------------------- GENERAL OPTIONS ---------------------
#define VERSION          0x0001
#define RELEASE

// --------------------- TILE SIZE --------------------------

#define MODULE_WIDTH         16    // Width of an LED module in pixels
#define MODULE_HEIGHT        32    // Height of an LED module in pixels
#define NUM_MODULES_X         1    // Number of LED modules along the width 
#define NUM_MODULES_Y         1    // Number of LED modules along the height
#define LEDS_PER_DRIVER      16    // Number of output drivers supported by the driver
#define SCAN_RATE             8    // Scan ratio on multiplex outputs

// --------------------- LED DRIVER TYPE --------------------
#define MBI5026
#define MBI5030
//#define MBI5031

// --------------------- Ethernet Server --------------------
// Define that will determine which components the base Ethernet server supports
#define ARP
#define ICMP
#define LED
#define TFTP 

// --------------------- TESTING ---------------------
#define PROCESSCOMMANDS
#define LOADGAMMAFROMSPI
#define WATCHDOGRESET
//#define LOOPBACKTESTING
//#define PTPAWARE

// --------------------- Calculated Defines ---------------
#define FRAME_HEIGHT         (MODULE_HEIGHT * NUM_MODULES_Y) // Height of frame in pixels
#define FRAME_WIDTH          (MODULE_WIDTH * NUM_MODULES_X) // Width of frame in pixels
#endif /*LED_H_*/
