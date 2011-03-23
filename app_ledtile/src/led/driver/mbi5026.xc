// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    mbi5026.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <platform.h>
#include <xclib.h>
#include "safestring.h"
#include "resetres.h"
#include "led.h"
#include "ledprocess.h"
#include "leddriver.h"
#include "print.h"
#include "leddriver.h"
#include "mbi5026.h"

#if defined MBI5026

extern unsigned char intensityadjust[3];
extern unsigned short gammaLUT[3][256];

void led_mbi5026_init(buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
              buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
              out port p_spi_addr, buffered out port:32 p_spi_clk ,
              buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe ,
              clock b_clk, clock b_data, clock b_gsclk, clock b_ref
              )
{
  resetresources(p_led_out_r0, p_led_out_g0, p_led_out_b0, p_led_out_r1, p_led_out_g1, p_led_out_b1,
      p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_oe ,
      b_clk, b_data, b_gsclk, b_ref);
  
  // Initialise ports
  partout(p_spi_clk, 1, 1);
  partout(p_spi_oe, 1, 1);
  
  set_clock_off(b_clk);
  set_clock_off(b_gsclk);
  set_clock_off(b_data);
  set_clock_on(b_clk);
  set_clock_on(b_gsclk);
  set_clock_on(b_data);
  stop_clock(b_clk);
  stop_clock(b_data);
  set_clock_ref(b_clk);
  
  set_clock_div(b_clk, SPI_CLKDIV);
  set_port_clock(p_spi_clk, b_clk);

  set_clock_src(b_data, p_spi_clk);
  set_port_clock(p_led_out_r0, b_data);
  set_port_clock(p_led_out_g0, b_data);
  set_port_clock(p_led_out_b0, b_data);
  set_port_clock(p_led_out_r1, b_data);
  set_port_clock(p_led_out_g1, b_data);
  set_port_clock(p_led_out_b1, b_data);
  set_port_clock(p_spi_ltch, b_clk);
  //set_pad_delay(p_spi_clk, 5);
  start_clock(b_data);
  start_clock(b_clk);
  //set_thread_fast_mode_on();

  p_spi_addr <: 0;
}

#pragma unsafe arrays
void processColumn(int x, unsigned tbuf[FRAME_HEIGHT], unsigned drivebuf[BCM_BITS][OUTPUT_BUF_SIZE])
{
  int y,c,i;
  int x1 = (x / MODULE_WIDTH);
  int x2 = ((x % MODULE_WIDTH) / (CHAIN_LOOPBACK_X*SCAN_RATE));
  int x3 = (x % SCAN_RATE);
  
  // Process column
  for (y=0; y<FRAME_HEIGHT; y++)
  {
    unsigned val = tbuf[y];
    for (c=2; c>=0; c--)
    {
      unsigned outval, outptr;
      int tval;
      
      val >>= 8;
      tval = val & 0xFF;
      
      // Apply DSP (gamma correction etc0 to LED data
      outval = bitrev(gammaLUT[c][tval]) >> 16;
      outval = (outval * (intensityadjust[c])) >> 8;
      
      // Calculate position in the output array
      outptr = y;
      outptr += FRAME_HEIGHT * (NUM_MODULES_X - 1 - x1);
      outptr += FRAME_HEIGHT * NUM_MODULES_X * c;
      outptr += FRAME_HEIGHT * NUM_MODULES_X * 3 * x2;
      outptr += FRAME_HEIGHT * NUM_MODULES_X * 3 * (MODULE_WIDTH/(CHAIN_LOOPBACK_X*SCAN_RATE)) * x3;

      // Truncate to the BCM depth
      outval >>= (16 - BCM_BITS);
      
      // Split the output bits into two sections
      // The lower bits we ignore if the highest bit is set
#define INTER_POINT (BCM_BITS - 2)
      if (!(outval >> BCM_BITS - 1))
      {
        for (i=0; i<(BCM_BITS - 1); i++)
        {
          drivebuf[i][outptr >> 5] |= ( (outval & 1) << (outptr & 0x1F) );    
          outval >>= 1;
        }        
      }
      else
      {
        outval >>= (BCM_BITS - 1);
      }
      
      for (i=(BCM_BITS - 1); i<BCM_BITS; i++)
      {
        drivebuf[i][outptr >> 5] |= ( (outval & 1) << (outptr & 0x1F) );    
        outval >>= 1;
      }        

    }
  }
}


void leddrivepins_mbi5026(streaming chanend c, 
    unsigned drivebuf[BCM_BITS][OUTPUT_BUF_SIZE],
    buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
    buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
    out port p_spi_addr, buffered out port:32 p_spi_clk ,
    buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe,
    unsigned oeval, int &scanval)
{
  int running = 1;  

  while (running)
  {    
    int scan;
    
    sync (p_spi_oe);
    scan = scanval;
    scanval++;
    if (scanval == SCAN_RATE)
      scanval=0;
    p_spi_addr <: scan;
    
    for (int bcmbit = 0; bcmbit < BCM_BITS; bcmbit++)
    {
      int r, ts;
      for (r = 0; r < DRIVE_REPEAT_COUNT; r++)
      {
        unsigned ptr = scan * OUTS_PER_CYCLE * PORT_WIDTH;
        for (int i = 0; i < OUTS_PER_CYCLE; i++)
        {
          p_led_out_r0 <: drivebuf[bcmbit][ptr + 0];
          p_led_out_g0 <: drivebuf[bcmbit][ptr + 1 * OUTS_PER_CYCLE];
          p_led_out_b0 <: drivebuf[bcmbit][ptr + 2 * OUTS_PER_CYCLE];
          p_led_out_r1 <: drivebuf[bcmbit][ptr + 3 * OUTS_PER_CYCLE];
          p_led_out_g1 <: drivebuf[bcmbit][ptr + 4 * OUTS_PER_CYCLE];
          p_led_out_b1 <: drivebuf[bcmbit][ptr + 5 * OUTS_PER_CYCLE];
          p_spi_clk <: 0xAAAAAAAA;
          p_spi_clk <: 0xAAAAAAAA;
          ptr ++;
        }
      }
      sync(p_spi_clk);
      sync(p_spi_oe);
      partout(p_spi_ltch, 8, 0x78);
      sync(p_spi_ltch);
      ts = partout_timestamped(p_spi_oe, 1, 0);
      partout_timed(p_spi_oe, 1, 1, ts + (1 << bcmbit) * OE_MULTI);
    }
    select
    {
      case c :> int _:
        running = 0;
        break;
      default:
        break;
    }
  }
  
  // Turn off drivers in reload period
  partout(p_spi_oe, 1, 1);
}

#pragma unsafe arrays
int ledreformat_mbi5026(streaming chanend cLedData, streaming chanend cLedCmd, streaming chanend cOut,
    unsigned drivebuf[BCM_BITS][OUTPUT_BUF_SIZE], int oeval)
{
  int cmdresponse;
  
  // Process any commands coming down the pipeline
  cmdresponse = ledprocess_commands(cLedCmd, cOut, 0);
  if (cmdresponse)
    return cmdresponse;
  
  // Reset output buffer
  for (int i=0; i<BCM_BITS * OUTPUT_BUF_SIZE; i++)
    (drivebuf, unsigned int[])[i] = 0;
  
  for (int x=0; x < FRAME_WIDTH; x++)
  {
    unsigned tbuf[FRAME_HEIGHT];

    // Retrieve column's led data from frame buffer
    {
      unsigned ptr = FRAME_HEIGHT;
      cLedData <: FRAME_WIDTH - 1 - x;
      while (ptr)
      {
        ptr--;
        cLedData :> tbuf[ptr];
      }
    }
    
    processColumn(x, tbuf, drivebuf);
  }
  
  cLedData <: -1;
  cOut <: 0;


  return 0;
}

// leddrive
// Macroblock LED Driver threads
// Requires channel to LED Pixel buffer, and channel to LED Command buffer
// Splits to three threads
//  - Reprocessing thread for colour correction etc
//  - Reformatting thread for splitting onto 8-bit port (not needed if have enough 1-bit ports)
//  - Pins thread for actually driving the IO and clocks
#pragma unsafe arrays
int leddrive_mbi5026(streaming chanend cLedData, streaming chanend cLedCmd, chanend cWdog, 
                   buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref
               )
{
  unsigned drivebuf1[BCM_BITS][OUTPUT_BUF_SIZE];
  unsigned drivebuf2[BCM_BITS][OUTPUT_BUF_SIZE];

  int retval;
  unsigned oeval1, oeval2;
  streaming chan c;
  int scanval = 1;
  
  led_mbi5026_init(p_led_out_r0, p_led_out_g0, p_led_out_b0,
      p_led_out_r1, p_led_out_g1, p_led_out_b1,
      p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_oe ,
      b_clk, b_data, b_gsclk, b_ref
  );
  
  ledprocess_init();
  
  for (int i=0; i<BCM_BITS*OUTPUT_BUF_SIZE; i++)
  {
    (drivebuf1, unsigned int[])[i] = -1;
    (drivebuf2, unsigned int[])[i] = -1;
  }
  
  while (1)
  {
    cWdog <: 1;
    par
    {
      leddrivepins_mbi5026(c, drivebuf2,
        p_led_out_r0, p_led_out_g0, p_led_out_b0,
        p_led_out_r1, p_led_out_g1, p_led_out_b1,
        p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_oe,
        oeval2, scanval);
      retval = ledreformat_mbi5026(cLedData, cLedCmd, c, drivebuf1, oeval1);
    }
    if (retval)
      return retval;
    
    par
    {
      leddrivepins_mbi5026(c, drivebuf1,
        p_led_out_r0, p_led_out_g0, p_led_out_b0, p_led_out_r1, p_led_out_g1, p_led_out_b1,
        p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_oe,
        oeval1, scanval);
      retval = ledreformat_mbi5026(cLedData, cLedCmd, c, drivebuf2, oeval1);
    }
    if (retval)
      return retval;
  }
  return 0;
}

#endif
