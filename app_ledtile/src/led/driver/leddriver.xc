// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    leddriver.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <ledprocess.h>
#include <mbi5026.h>
#include <mbi5030.h>
#include <mbi5031.h>


/*
 * A generic led driver frontend. It sends the data to the real LED drivers but also allows to dynamically switch the led driver.
 *
 * Channels
 * cLEdData - channel end to receive LED data from the LED Buffer thread.
 * cLedCmd - channel end to receive LED commands e.g. to receive gamma or color correction commands
 * cWdog - connection to the watchdog
 *
 * Ports
 * p_led_out_r0,1 - 1bit serial output ports for led data (red)
 * p_led_out_g0,1 - 1bit serial output ports for led data (green)
 * p_led_out_b0,1 - 1bit serial output ports for led data (blue)
 * p_spi_addr 	  - SPI CS port (TODO ???)
 * p_spi_clk	  - SPI clock port
 * p_spi_ltch     - latch port to latch the data to the drivers
 * p_spi_oe 	  - output enable port
 *
 * Clocks
 * b_clk		  - master clock
 * d_data		  - data clock (TODO??)
 * b_gsclk		  - clock for the output enable (TODO ????)
 *
 * Drivers
 * - MBI5030 (#1)
 * - MBI5026 (#2)
 * the led drivers itself are responsible to switch the driver on request (TODO - isn't that a tad akward?)
 */
void leddrive(streaming chanend cLedData, streaming chanend cLedCmd, chanend cWdog,
    buffered out port:32 p_led_out_r0, buffered out port:32 p_led_out_g0, buffered out port:32 p_led_out_b0,
    buffered out port:32 p_led_out_r1, buffered out port:32 p_led_out_g1, buffered out port:32 p_led_out_b1,
    out port p_spi_addr, buffered out port:32 p_spi_clk ,
    buffered out port:32 p_spi_ltch, buffered out port:32 p_spi_oe ,
    clock b_clk, clock b_data, clock b_gsclk, clock b_ref)
{
  int driver = -1;
  
  //initialize the led data processor (which later applies gamm & color correction)
  ledprocess_init();
  
  while (1)
  {
	//the driver is selected according to the 'driver' variable to enabl dynamically driver switching
	//the data is sen to tht corresponding driver
    switch (driver)
    {
  #if defined MBI5030
      case (1):
      {
        driver = leddrive_mbi5030(cLedData, cLedCmd, cWdog, 
                           p_led_out_r0, p_led_out_g0, p_led_out_b0,
                           p_led_out_r1, p_led_out_g1, p_led_out_b1,
                           p_spi_addr, p_spi_clk ,
                           p_spi_ltch, p_spi_oe ,
                           b_clk, b_data, b_gsclk, b_ref
                       );
      }
      break;
  #endif
#if defined MBI5026
      case (2):
      {
        driver = leddrive_mbi5026(cLedData, cLedCmd, cWdog, 
                           p_led_out_r0, p_led_out_g0, p_led_out_b0,
                           p_led_out_r1, p_led_out_g1, p_led_out_b1,
                           p_spi_addr, p_spi_clk ,
                           p_spi_ltch, p_spi_oe ,
                           b_clk, b_data, b_gsclk, b_ref
                       );
      }
      break;
#endif
#if defined MBI5031
    case (1):
    {
      driver = leddrive_mbi5031(cLedData, cLedCmd, cWdog,
                         p_led_out_r0, p_led_out_g0, p_led_out_b0,
                         p_led_out_r1, p_led_out_g1, p_led_out_b1,
                         p_spi_addr, p_spi_clk ,
                         p_spi_ltch, p_spi_oe ,
                         b_clk, b_data, b_gsclk, b_ref
                     );
    }
    break;
#endif
      default:
#if defined MBI5030
        driver = 1;
#elif defined MBI5026
        driver = 2;
#elif defined MBI5031
        driver = 2;
#else
        #error "No valid LED driver defined"
#endif
        break;
    }
  }
  
  
}

