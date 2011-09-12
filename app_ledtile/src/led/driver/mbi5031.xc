// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    mbi5031.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <platform.h>
#include <xclib.h>

#include "print.h"
#include "led.h"
#include "ledprocess.h"
#include "mbi5031.h"
#include "math.h"

#if defined MBI5031

//some prototpyes for our private functions
//initialize SPi# ports
void mbi5031_resetresources(buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_gclk ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref);


#ifdef MODE12BIT
  int options = SELF_SYNC | GCLK_TIMEOUT | PWM_GS_12BIT;
#else
  int options = SELF_SYNC | GCLK_TIMEOUT;
#endif
int currentgain = CURRENT_GAIN;

extern unsigned char intensityadjust[3];
extern unsigned short gammaLUT[3][256];

/*
 * Write to the LED Drivers' configuration registers
 *
 * PORTS
 * p_led_out_r0 - Port R0 of led output connector
 * p_led_out_g0 - Port G0 of led output connector
 * p_led_out_b0 - Port B0 of led output connector
 * p_led_out_r1 - Port R1 of led output connector
 * p_led_out_g1 - Port G1 of led output connector
 * p_led_out_b1 - Port B1 of led output connector
 * p_spi_ltch - PORT SPI_LTCH of led output connector
 *
 * PARAMETERS
 * value
 * mask - which RGB ports to use: 0b1 for R0, 0b10 for G0, 0b100 for B0, 0b1000 for R1 and so on
 * value - the configuration value to write - the current gain setting will be added
 */
void writeConfiguration_mbi5031(
    buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
    buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_clk,  
                        unsigned value, unsigned cgain)
{
  // Create an invalid value (false parity) for the other drivers
  int driver = BUFFER_SIZE/LEDS_PER_DRIVER;

  
  // Include current gain
  value = value | (cgain << 2);
  

  // Bit reverse if necessary
#ifdef BITREVERSE
  value = bitrev(value) >> 16;
#endif
  
  while (driver)
  {
    driver--;
    partout(p_led_out_r0, 16, value);
    partout(p_led_out_g0, 16, value);
    partout(p_led_out_b0, 16, value);
    
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

/*
 * PORTS
 * p_led_out_r0 - Port R0 of led output connector
 * p_led_out_g0 - Port G0 of led output connector
 * p_led_out_b0 - Port B0 of led output connector
 * p_led_out_r1 - Port R1 of led output connector
 * p_led_out_g1 - Port G1 of led output connector
 * p_led_out_b1 - Port B1 of led output connector
 * p_spi_addr the 4 bit port for the address (only 3 are brought out to the LED OUT connector)
 * p_spi_clck - the SPI serial data clock port
 * p_spi_ltch - PORT SPI_LTCH of led output connector
 * p_spi_gclk The SPI Output Enable port (in reality it is the grayscale clock)
 *
 * PARAMETERS
 * value
 * mask - which RGB ports to use: 0b1 for R0, 0b10 for G0, 0b100 for B0, 0b1000 for R1 and so on
 * value - the configuration value to write - the current gain setting will be added
 */
void leddrive_mbi5031_init(buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_gclk ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref
               )
{

  partout(p_spi_clk, 1, 0);
  
  mbi5031_resetresources(p_led_out_r0, p_led_out_g0, p_led_out_b0,
      p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_gclk ,
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
  configure_port_clock_output(p_spi_gclk, b_gsclk);

  set_clock_src(b_data, p_spi_clk);
  // Clock ports
  set_port_clock(p_led_out_r0, b_data);
  set_port_clock(p_led_out_g0, b_data);
  set_port_clock(p_led_out_b0, b_data);
  // Latch is clocked off clock
  set_port_clock(p_spi_ltch, b_data);

  start_clock(b_data);
  start_clock(b_clk);
  start_clock(b_gsclk);

  set_thread_fast_mode_on();
  
  p_spi_addr <: 0;
  //partout(p_spi_clk, 2, 1);
  

  // Setup the default configuration register
  writeConfiguration_mbi5031(p_led_out_r0, p_led_out_g0, p_led_out_b0,
  p_spi_ltch, p_spi_clk, options, currentgain);
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
 * p_spi_b0 - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_r1 - output port, part of the address
 * p_spi_b1 - output port, part of the address
 * p_spi_addr - Output port, 4bit Port Width bit 1-3 used
 * p_spi_clk - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_ltch - Buffered output port, 32bit Transfer Width, 1bit Port Width
 * p_spi_gclk - 1bit Port Width
 */
#pragma unsafe arrays
int leddrive_mbi5031_pins(streaming chanend c,
                   buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   out port p_led_out_r1, out port p_led_out_b1,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_gclk,
                   unsigned short buffers[NUM_MODULES_X*FRAME_HEIGHT][3],
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

        //TODO there is no mask on MBI5031 - perhaps we have to introduce it manually later
        writeConfiguration_mbi5031(p_led_out_r0, p_led_out_g0, p_led_out_b0,
            p_spi_ltch, p_spi_clk, options, currentgain);
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
      partout(p_led_out_r0, 16, bitrev(buffers[yptr][2]) >> 12);
      partout(p_led_out_g0, 16, bitrev(buffers[yptr][1]) >> 12);
      partout(p_led_out_b0, 16, bitrev(buffers[yptr][0]) >> 12);
      
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

  {
	  //TODO the soldering of the adress is a tad funny, let's improve in the 2nd version
	  unsigned int address = (bitrev(x)>>28) & 0x7;
	  unsigned char a_address = x & 0x1;

	  p_spi_addr <: (unsigned)address;
	  p_led_out_b1 <: a_address;
	  p_led_out_r1 <: 0;
  }
  
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
int ledreformat_mbi5031(streaming chanend cLedData, streaming chanend cLedCmd, streaming chanend cOut,
    unsigned short buffers[NUM_MODULES_X*FRAME_HEIGHT][3], int x)
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
    getColumn(cLedData, buffers, i * FRAME_HEIGHT, (xptr - (i*MODULE_WIDTH)));
  }

  return 0;
}

#pragma unsafe arrays
int leddrive_mbi5031(streaming chanend cLedData, streaming chanend cLedCmd, chanend cWdog,
                   buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   out port p_led_out_r1, out port p_led_out_b1,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_gclk ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref
               )
{
  unsigned short buffers[2][NUM_MODULES_X*FRAME_HEIGHT][3];
  int retval;
  int lastx;
  timer t;
  int now;
  int starttime,endtime;
  streaming chan c;

#ifndef SIMULATION
  for (int i=0; i<2*2*NUM_MODULES_X*FRAME_HEIGHT*3; i++)
    (buffers, unsigned char[])[i] = 0;
#endif
  
  leddrive_mbi5031_init(p_led_out_r0, p_led_out_g0, p_led_out_b0,
      p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_gclk ,
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
    
    /*
     * The buffering scheme looks quite complicated here - but it is not:
     * in each run two columns are read:
     * first read into buffer 1, outputted from buffer 0
     * next read into buffer 0, outputted from buffer 1 (which is the column read in the first round)
     *
     * TODO the principle is simple - why isn't the code simple?
     */
    for (int x=0; x<SCAN_RATE; x++)
    {
    	//read new data in buffers[1]
    	//and send the data from buffer[0] to the rgb matrix
      par
      {
        leddrive_mbi5031_pins(c, p_led_out_r0, p_led_out_g0, p_led_out_b0,
            p_led_out_r1,p_led_out_b1,
            p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_gclk,
            buffers[0], lastx, now, t);
        retval = ledreformat_mbi5031(cLedData, cLedCmd, c, buffers[1], x);
      }
      
      if (retval)
        return retval;
      
      lastx++;
      if (lastx == SCAN_RATE)
        lastx = 0;
      
      x++;
      
  	//read new data in buffers[0]
  	//and send the data from buffer[1] to the rgb matrix
      par
      {
        leddrive_mbi5031_pins(c, p_led_out_r0, p_led_out_g0, p_led_out_b0,
            p_led_out_r1, p_led_out_b1,
            p_spi_addr, p_spi_clk , p_spi_ltch, p_spi_gclk,
            buffers[1], lastx, now, t);
        retval = ledreformat_mbi5031(cLedData, cLedCmd, c, buffers[0], x);
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


void mbi5031_resetresources(buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
                   out port p_spi_addr, buffered out port:32 p_spi_clk ,
                   buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_gclk ,
                   clock b_clk, clock b_data, clock b_gsclk, clock b_ref)
{
  configure_out_port_no_ready(p_led_out_r0, b_ref, 0);
  configure_out_port_no_ready(p_led_out_g0, b_ref, 0);
  configure_out_port_no_ready(p_led_out_b0, b_ref, 0);
  configure_out_port_no_ready(p_spi_addr, b_ref, 0);
  configure_out_port_no_ready(p_spi_clk, b_ref, 0);
  configure_out_port_no_ready(p_spi_ltch, b_ref, 0);
  configure_out_port_no_ready(p_spi_gclk, b_ref, 0);

  set_clock_off(b_clk);
  set_clock_off(b_data);
  set_clock_off(b_gsclk);

  set_clock_on(b_clk);
  set_clock_on(b_data);
  set_clock_on(b_gsclk);

  set_clock_ref(b_clk);
  set_clock_ref(b_data);
  set_clock_ref(b_gsclk);
}



#endif

