// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    mbi5030.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <platform.h>
#include <xclib.h>

#include "print.h"
#include "led.h"
#include "ledprocess.h"
#include "leddriver.h"
#include "mbi5030.h"
#include "math.h"
#include "resetres.h"

#if defined MBI5030

#ifdef MODE12BIT
  int options = SELF_SYNC | GCLK_TIMEOUT | PWM_GS_12BIT;
#else
  int options = SELF_SYNC | GCLK_TIMEOUT;
#endif
int currentgain = CURRENT_GAIN;

extern unsigned char intensityadjust[3];
extern unsigned short gammaLUT[3][256];

// Write to the LED Drivers' configuration registers
void writeConfiguration_mbi5030(
    buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
    buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
    buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_clk,  
                        unsigned value, unsigned cgain, unsigned mask)
{
  // Create an invalid value (false parity) for the other drivers
  unsigned dummyvalue = PARITY;
  int driver = BUFFER_SIZE/LEDS_PER_DRIVER;

#ifdef MBI5030C
  cgain >>= 2;
#endif
  
  // Include current gain
  value = value | (cgain << 2);
  
#ifndef MBI5030C
  // Correct parity for real value
  if (countOnes(value) & 1)
    value |= PARITY;
#endif

  // Bit reverse if necessary
#ifdef BITREVERSE
  dummyvalue = bitrev(dummyvalue) >> 16;
  value = bitrev(value) >> 16;
#endif
  
  while (driver)
  {
    driver--;
    // First 3 channels
    if (mask & 0b000001)
      partout(p_led_out_r0, 16, value);
    else
      partout(p_led_out_r0, 16, dummyvalue);
    if (mask & 0b000010)
      partout(p_led_out_g0, 16, value);
    else
      partout(p_led_out_g0, 16, dummyvalue);
    if (mask & 0b000100)
      partout(p_led_out_b0, 16, value);
    else
      partout(p_led_out_b0, 16, dummyvalue);
    // Second three channels
    if (mask & 0b001000)
      partout(p_led_out_r1, 16, value);
    else
      partout(p_led_out_r1, 16, dummyvalue);
    if (mask & 0b010000)
      partout(p_led_out_g1, 16, value);
    else
      partout(p_led_out_g1, 16, dummyvalue);
    if (mask & 0b100000)
      partout(p_led_out_b1, 16, value);
    else
      partout(p_led_out_b1, 16, dummyvalue);
    
    if (driver == 0)
      partout(p_spi_ltch, 16, REGISTER_WRITE_LATCH);
    else
      partout(p_spi_ltch, 16, 0);
    
    p_spi_clk <: 0x55555555;
  }
  
  // Bring latch low
  partout(p_spi_ltch, 1, 0);
  partout(p_spi_clk, 2, 0x01);
}

void leddrive_mbi5030_init(buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref
               )
{

  partout(p_spi_clk, 1, 0);
  
  resetresources(p_led_out_r0, p_led_out_g0, p_led_out_b0, p_led_out_r1, p_led_out_g1, p_led_out_b1,
      p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_oe ,
      b_clk, b_data, b_gsclk, b_ref);
  
  // Initialise ports
  set_clock_ref(b_clk);
  set_clock_ref(b_gsclk);
  set_clock_ref(b_data);
  
  stop_clock(b_clk);
  stop_clock(b_data);
  stop_clock(b_gsclk);
  
  set_clock_div(b_gsclk, GSCLK_CLKDIV);
  set_clock_div(b_clk, SPI_CLKDIV);
  
  set_port_clock(p_spi_clk, b_clk);
  configure_port_clock_output(p_spi_oe, b_gsclk);

  set_clock_src(b_data, p_spi_clk);
  // Clock ports
  set_port_clock(p_led_out_r0, b_data);
  set_port_clock(p_led_out_g0, b_data);
  set_port_clock(p_led_out_b0, b_data);
  set_port_clock(p_led_out_r1, b_data);
  set_port_clock(p_led_out_g1, b_data);
  set_port_clock(p_led_out_b1, b_data);
  // Latch is clocked off clock
  set_port_clock(p_spi_ltch, b_data);

  start_clock(b_data);
  start_clock(b_clk);
  start_clock(b_gsclk);

  set_thread_fast_mode_on();
  
  p_spi_addr <: 0;
  //partout(p_spi_clk, 2, 1);
  

  // Setup the default configuration register
  writeConfiguration_mbi5030(p_led_out_r0, p_led_out_g0, p_led_out_b0, p_led_out_r1, p_led_out_g1, p_led_out_b1,
  p_spi_ltch, p_spi_clk, options, currentgain, 0xFFFFFFFF);
}


/*
 * LED PIN DRIVER
 *
 * Physical SPI interface. Receive reformatted data and output to pins, with correct
 * latch signals on the physical SPI interface.
 * Controls latching and clock generation as well as register writes.
 *
 * Channels
 * cln - Streaming bidirectional pixel/command input
 *
 * Port
 * p_spi_r0 - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_g0 - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_b1 - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_r1 - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_g1 - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_b1 - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_addr - Output port, 4bit Port Width
 * p_spi_clk - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_ltch - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_oe - 1bit Port Width
 */
#pragma unsafe arrays
int leddrive_mbi5030_pins(streaming chanend c, 
                   buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe, 
                   unsigned short buffers[2][NUM_MODULES_X*FRAME_HEIGHT][3],
                   int x, int &now, timer t
               )
{
  int cmdResponse;


  // Check if any commands come down the pipeline
  // Receive data from reprocessing thread
  
  c :> cmdResponse;
  while (cmdResponse == 0)
  {
    // Commands
    int cmd;
    c :> cmd;
    switch (cmd)
    {
      case (XMOS_INTENSITYADJ):
      {
        // Adjust the "current gain" value of the controllers
        unsigned mask, value;
        
        c :> mask;
        c :> currentgain;

        writeConfiguration_mbi5030(p_led_out_r0, p_led_out_g0, p_led_out_b0, p_led_out_r1, p_led_out_g1, p_led_out_b1,
            p_spi_ltch, p_spi_clk, options, currentgain, mask);
        break;
      }
      case (XMOS_CHANGEDRIVER):
      {
        int newdrivertype;
        c :> newdrivertype;
        return newdrivertype;
      }
      default:
        break;
    }
    c :> cmdResponse;
  }

  for (int channel=0; channel < LEDS_PER_DRIVER; channel++)
  {
    for (int drivernum=0; drivernum < NUM_DRIVERS; drivernum++)
    {
      unsigned yptr = channel + LEDS_PER_DRIVER * drivernum;
      // Pass new data to the output ports
#ifdef MODE12BIT
      partout(p_led_out_r0, 16, bitrev(buffers[0][yptr][2]) >> 12);
      partout(p_led_out_g0, 16, bitrev(buffers[0][yptr][1]) >> 12);
      partout(p_led_out_b0, 16, bitrev(buffers[0][yptr][0]) >> 12);
      partout(p_led_out_r1, 16, bitrev(buffers[1][yptr][2]) >> 12);
      partout(p_led_out_g1, 16, bitrev(buffers[1][yptr][1]) >> 12);
      partout(p_led_out_b1, 16, bitrev(buffers[1][yptr][0]) >> 12);
#else
      partout(p_led_out_r0, 16, bitrev(buffers[0][yptr][2]) >> 16);
      partout(p_led_out_g0, 16, bitrev(buffers[0][yptr][1]) >> 16);
      partout(p_led_out_b0, 16, bitrev(buffers[0][yptr][0]) >> 16);
      partout(p_led_out_r1, 16, bitrev(buffers[1][yptr][2]) >> 16);
      partout(p_led_out_g1, 16, bitrev(buffers[1][yptr][1]) >> 16);
      partout(p_led_out_b1, 16, bitrev(buffers[1][yptr][0]) >> 16);
#endif
      
      if (drivernum == (BUFFER_SIZE/LEDS_PER_DRIVER) - 1)
      {
        if (channel == LEDS_PER_DRIVER - 1)
          partout(p_spi_ltch, 16, GLOBL_LATCH);
        else
          partout(p_spi_ltch, 16, LOCAL_LATCH);
      }
      else
      {
        partout(p_spi_ltch, 16, 0);
      }        
      
      // Clock out this data
      p_spi_clk <: 0x55555555;
    }
  }
  // Wait for the latch point

  t when timerafter(now + FRAME_TIME) :> now;   
  // Bring down the latch
  partout(p_spi_ltch, 1, 0);
  partout(p_spi_clk, 2, 0x55555555);
  p_spi_addr <: (unsigned)x;    
  
  return 0;
}

#pragma unsafe arrays
void getColumn(streaming chanend cLedData, unsigned short buffers[NUM_MODULES_X*FRAME_HEIGHT][3],int yptr, int xptr)
{
  unsigned tbuf[FRAME_HEIGHT];

  // Retrieve column's led data from frame buffer
  {
    unsigned ptr = FRAME_HEIGHT;
    cLedData <: FRAME_WIDTH - 1 - xptr;
    while (ptr)
    {
      ptr--;
      cLedData :> tbuf[ptr];
    }
  }
  
  for (int y=0; y<FRAME_HEIGHT; y++)
  {
#pragma loop unroll(3)
    for (int c=0; c<3; c++)
    {
      int val = (tbuf, char[])[(y << 2) + c + 1];
      
      val = bitrev(gammaLUT[ 2- c ][val]) >> 16;
      val = (val * intensityadjust[ 2- c ]) >> 8;
      
      buffers[yptr + y][c] = val;
    }
  }

}

#pragma unsafe arrays
int ledreformat_mbi5030(streaming chanend cLedData, streaming chanend cLedCmd, streaming chanend cOut,
    unsigned short buffers[2][NUM_MODULES_X*FRAME_HEIGHT][3], int x)
{
  int cmdresponse;
  unsigned xptr = FRAME_WIDTH + x - (SCAN_RATE * 2);

  // Process any commands coming down the pipeline
  if (x==0)
  {
    cmdresponse = ledprocess_commands(cLedCmd, cOut, 1);
    if (cmdresponse)
      return cmdresponse;
  }
  else
  {
    cOut <: 1;
  }
  
  for (int i=0; i < FRAME_WIDTH/MODULE_WIDTH; i++)
  {
    getColumn(cLedData, buffers[0], i * FRAME_HEIGHT, (xptr - (i*MODULE_WIDTH)));
    getColumn(cLedData, buffers[1], i * FRAME_HEIGHT, (xptr - (i*MODULE_WIDTH) + SCAN_RATE));
  }

  return 0;
}

#pragma unsafe arrays
int leddrive_mbi5030(streaming chanend cLedData, streaming chanend cLedCmd, chanend cWdog, 
                   buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref
               )
{
  unsigned short buffers[2][2][NUM_MODULES_X*FRAME_HEIGHT][3];
  int retval;
  int x;
  int lastx;
  int currentbuf=0;
  timer t;
  int now;
  int starttime,endtime;
  streaming chan c;

#ifndef SIMULATION
  for (int i=0; i<2*2*2*NUM_MODULES_X*FRAME_HEIGHT*3; i++)
    (buffers, unsigned char[])[i] = 0;
#endif
  
  leddrive_mbi5030_init(p_led_out_r0, p_led_out_g0, p_led_out_b0,
      p_led_out_r1, p_led_out_g1, p_led_out_b1,
      p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_oe ,
      b_clk, b_data, b_gsclk, b_ref
  );
  
  t :> now;
  
  while (1)
  {
    t :> starttime;
    
#ifndef SIMULATION
    cWdog <: 1;
#endif
    
    lastx = SCAN_RATE - 1;
    
    for (int x=0; x<SCAN_RATE; x++)
    {
      par
      {
        leddrive_mbi5030_pins(c, p_led_out_r0, p_led_out_g0, p_led_out_b0,
            p_led_out_r1, p_led_out_g1, p_led_out_b1,
            p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_oe,
            buffers[0], lastx, now, t);
        retval = ledreformat_mbi5030(cLedData, cLedCmd, c, buffers[1], x);
      }
      
      if (retval)
        return retval;
      
      lastx++;
      if (lastx == SCAN_RATE)
        lastx = 0;
      
      x++;
      
      par
      {
        leddrive_mbi5030_pins(c, p_led_out_r0, p_led_out_g0, p_led_out_b0,
            p_led_out_r1, p_led_out_g1, p_led_out_b1,
            p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_oe,
            buffers[1], lastx, now, t);
        retval = ledreformat_mbi5030(cLedData, cLedCmd, c, buffers[0], x);
      }
      
      if (retval)
        return retval;
      
      lastx++;
      if (lastx == SCAN_RATE)
        lastx = 0;
    }
    
    cLedData <: -1;
    
    t :> endtime;
    
#if 0
    printintln(endtime - starttime);
#endif
  }
  return 0;
}

#endif

