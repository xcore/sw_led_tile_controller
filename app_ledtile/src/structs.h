// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    structs.h
 *
 *
 **/                                   
#ifndef STRUCTS_H_
#define STRUCTS_H_

#ifdef __XC__

struct s_eth_mii_ports
{
  clock clk_mii_rx;
  clock clk_mii_tx;
  in port p_mii_rxclk;
  buffered in port:32 p_mii_rxd;
  in port p_mii_rxdv;
  in port p_mii_rxer;
  in port p_mii_txclk;
  buffered out port:32 p_mii_txd;
  out port p_mii_txen;
  port p_smi_mdio;
  out port p_smi_mdc;
};

#else

struct s_eth_mii_ports
{
  unsigned clk_mii_rx;
  unsigned clk_mii_tx;
  unsigned p_mii_rxclk;
  unsigned p_mii_rxd;
  unsigned p_mii_rxdv;
  unsigned p_mii_rxer;
  unsigned p_mii_txclk;
  unsigned p_mii_txd;
  unsigned p_mii_txen;
  unsigned p_smi_mdio;
  unsigned p_smi_mdc;
};

#endif

#ifdef __XC__

struct s_eth_glob_ports
{
  #ifdef SIMULATION
  port p_mii_txcsn;
  #endif
  clock clk_mii_ref;
  clock clk_smi;
  out port p_mii_resetn;
};

#else

struct s_eth_glob_ports
{
  #ifdef SIMULATION
  unsigned p_mii_txcsn;
  #endif
  unsigned clk_mii_ref;
  unsigned clk_smi;
  unsigned p_mii_resetn;
};

#endif

#ifdef __XC__

struct s_led_ports
{
  buffered out port:32 p_led_out_r0;
  buffered out port:32 p_led_out_g0;
  buffered out port:32 p_led_out_b0;
  buffered out port:32 p_led_out_r1;
  buffered out port:32 p_led_out_g1;
  buffered out port:32 p_led_out_b1;
  out port p_led_out_addr;
  buffered out port:32 p_led_out_clk;
  buffered out port:32 p_led_out_ltch;
  buffered out port:32 p_led_out_oe;
  clock b_led_clk;
  clock b_led_data;
  clock b_led_gsclk;
  clock b_ref;
};

#else

struct s_led_ports
{
  unsigned p_led_out_r0;
  unsigned p_led_out_g0;
  unsigned p_led_out_b0;
  unsigned p_led_out_r1;
  unsigned p_led_out_g1;
  unsigned p_led_out_b1;
  out port p_led_out_addr;
  unsigned p_led_out_clk;
  unsigned p_led_out_ltch;
  unsigned p_led_out_oe;
  unsigned b_led_clk;
  unsigned b_led_data;
  unsigned b_led_gsclk;
  unsigned b_ref;
};

#endif

#ifdef __XC__

struct s_flash_ports
{
  clock b_flash_clk;
  clock b_flash_data;
  buffered in port:8 p_flash_miso;
  out port p_flash_ss;
  buffered out port:32 p_flash_clk;
  buffered out port:8 p_flash_mosi;
};

#else

struct s_flash_ports
{
  unsigned b_flash_clk;
  unsigned b_flash_data;
  unsigned p_flash_miso;
  unsigned p_flash_ss;
  unsigned p_flash_clk;
  unsigned p_flash_mosi;
};

#endif

#endif /*STRUCTS_H_*/
