// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    main.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <platform.h>

//ethernet stuff
#include "ethernet_server.h"
#include "ethernet_tx_client.h"
#include "ethernet_rx_client.h"
#include "getmac.h"


#include "ledbuffer.h"
#include "pktbuffer.h"
#include "watchdog.h"
#include "flashmanager.h"
#include "ledprocess.h"
#include "misc.h"

#include "otp_data.h"
#include "ethLocalHandler.h"
#include "ethServer.h"

#include "led.h"
#if defined MBI5031
#include "mbi5031.h"
#elif defined MBI5030
#include "mbi5030.h"
#elif defined MBI5026
#include "mbi5026.h"
#endif




// Ethernet Ports and Clock Blocks
// -----------------------
on stdcore[2]: clock clk_mii_ref                = XS1_CLKBLK_REF;
on stdcore[2]: clock clk_smi                    = XS1_CLKBLK_3;

on stdcore[2]: mii_interface_t mii_0 =
  {
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,

    PORT_ETH_RXCLK_0,
    PORT_ETH_RXER_0,
    PORT_ETH_RXD_0,
    PORT_ETH_RXDV_0,

    PORT_ETH_TXCLK_0,
    PORT_ETH_TXEN_0,
    PORT_ETH_TXD_0,
  };

on stdcore[2]: mii_interface_t mii_1 =
  {
    XS1_CLKBLK_4,
    XS1_CLKBLK_5,

    PORT_ETH_RXCLK_1,
    PORT_ETH_RXER_1,
    PORT_ETH_RXD_1,
    PORT_ETH_RXDV_1,

    PORT_ETH_TXCLK_1,
    PORT_ETH_TXEN_1,
    PORT_ETH_TXD_1,
  };


on stdcore[2]: out port p_mii_resetn = PORT_ETH_RST_N;
on stdcore[2]: smi_interface_t smi_0 = { PORT_ETH_MDIO_0, PORT_ETH_MDC_0, 0 };
on stdcore[2]: smi_interface_t smi_1 = { PORT_ETH_MDIO_1, PORT_ETH_MDC_1, 0 };

// LED Tile Ports
// -----------------------
buffered out port:32 p_led_out_r0               = PORT_LED_OUT_R0;
buffered out port:32 p_led_out_g0               = PORT_LED_OUT_G0;
buffered out port:32 p_led_out_b0               = PORT_LED_OUT_B0;
buffered out port:32 p_led_out_r1            	= PORT_LED_OUT_R1;
buffered out port:32 p_led_out_g1            	= PORT_LED_OUT_G1;
buffered out port:32 p_led_out_b1            	= PORT_LED_OUT_B1;
out port p_led_out_addr                         = PORT_LED_OUT_ADDR;
buffered out port:32 p_led_out_clk              = PORT_LED_OUT_CLK;
buffered out port:32 p_led_out_ltch             = PORT_LED_OUT_LATCH;
buffered out port:32 p_led_out_oe               = PORT_LED_OUT_OE;
on stdcore[0]: clock b_led_clk                  = XS1_CLKBLK_2;
on stdcore[0]: clock b_led_data                 = XS1_CLKBLK_3;
on stdcore[0]: clock b_led_gsclk                = XS1_CLKBLK_4;
on stdcore[0]: clock b_ref                      = XS1_CLKBLK_REF;
on stdcore[0]: clock b_flash_clk                = XS1_CLKBLK_1;
on stdcore[0]: clock b_flash_data               = XS1_CLKBLK_5;
buffered in port:8 p_flash_miso                 = PORT_SPI_MISO;
out port p_flash_ss                             = PORT_SPI_SS;
buffered out port:32 p_flash_clk                = PORT_SPI_CLK;
buffered out port:8 p_flash_mosi                = PORT_SPI_MOSI;

//the otp data structure
struct otp_ports otp = {OTP_DATA_PORT, OTP_ADDR_PORT, OTP_CTRL_PORT};

//enable or disable the watchdog
#define WATCHDOG_ENABLED 0

// Top level main
int main(void)
{
  streaming chan c_led_data_out;
  chan c_led_data_in;
  chan c_local_tx, c_local_rx_in;
  chan c_led_cmds_in;
  streaming chan c_led_cmds_out, c_local_rx_out;
  chan cSpiFlash;
  chan cWdog[NUM_WATCHDOG_CHANS];
  chan rx[1], tx[1];

  par
  {
    // Threads constrained by I/O or latency requirements
	//the internal 3 port ethernet switch
    on stdcore[2]: {
    	startEthServer(c_local_tx,c_local_rx_in,
    			c_led_data_in, c_led_cmds_in,
    			cSpiFlash,
    			clk_smi,p_mii_resetn,smi_0,smi_1,mii_0,mii_1,otp);
    }

    
    //TODO we must find a way to select the correct led driver at startup - perhaps from flash??
    //this needs to be done so taht each led driver can define & use the pins it wants to use
#if defined MBI5031
    on stdcore[0]: leddrive_mbi5031(c_led_data_out, c_led_cmds_out, cWdog[0],
        p_led_out_r0, p_led_out_g0, p_led_out_b0, p_led_out_g1, p_led_out_b1,
        p_led_out_addr, p_led_out_clk , p_led_out_ltch, p_led_out_oe ,
        b_led_clk, b_led_data, b_led_gsclk, b_ref);
#elif defined MBI5030
    on stdcore[0]: leddrive_mbi5030(
       		c_led_data_out, c_led_cmds_out, cWdog[0],
           p_led_out_r0, p_led_out_g0, p_led_out_b0,
           p_led_out_r1, p_led_out_g1, p_led_out_b1,
           p_led_out_addr, p_led_out_clk , p_led_out_ltch, p_led_out_oe ,
           b_led_clk, b_led_data, b_led_gsclk, b_ref);
#elif defined MBI5026
    on stdcore[0]: leddrive_mbi5026(
          		c_led_data_out, c_led_cmds_out, cWdog[0],
              p_led_out_r0, p_led_out_g0, p_led_out_b0,
              p_led_out_r1, p_led_out_g1, p_led_out_b1,
              p_led_out_addr, p_led_out_clk , p_led_out_ltch, p_led_out_oe ,
              b_led_clk, b_led_data, b_led_gsclk, b_ref);
#endif
    //the interface to the flash memory for config data
    on stdcore[0]: spiFlash(cSpiFlash, p_flash_miso, p_flash_ss, p_flash_clk, p_flash_mosi, b_flash_clk, b_flash_data);
    
    // Unconstrained threads
    //a watchdog to reset the hardware if some thread has gone wild
    on stdcore[1]: watchDog(cWdog, 1, WATCHDOG_ENABLED);

    //the packetbuffer for the internal ethernet server (3rd port of the switch)
    //TODO this was on core 2 - for a reason, is there a way to go back? (it makes sense to have this BEFORE the channel)
    on stdcore[3]: pktbuffer(c_local_rx_in, c_local_rx_out);
    //the ethernet server itself
    //on stdcore[3]: ethServer(c_local_rx_out, c_local_tx, c_led_data_in, c_led_cmds_in, cSpiFlash, cWdog[2]);
    // apacket buffer buffering the led commmands
    on stdcore[3]: pktbuffer(c_led_cmds_in, c_led_cmds_out);
    //the central pixel buffer
    on stdcore[3]: ledbuffer(c_led_data_in, c_led_data_out);
    
  }
  return 0;
}
