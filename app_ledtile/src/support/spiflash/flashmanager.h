// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    flashmanager.h
 *
 *
 **/                                   
#ifndef SPIFLASH_H_
#define SPIFLASH_H_

#ifdef __XC__  // required for 9.9.2 tools
#include <platform.h>
#endif

#define SPI_FLASH_READ          0
#define SPI_FLASH_WRITEFIRMWARE 1
#define SPI_FLASH_NEWFIRMWARE   2
#define SPI_FLASH_NEWGAMMA      3
#define SPI_FLASH_READGAMMA     4

/*
 * SPI FLASH
 *
 * SPI Flash read and write. Loads Gamma LUTs off SPI flash and provides auto-update and firmware upgrade capability.
 *
 * Channels
 * cln - bidirectional
 *
 * Port
 * p_flash_miso - Buffered input port, 8bit transfer width, 1bit Port Width
 * p_flash_mosi - Buffered output port, 8bit transfer width, 1bit Port Width
 * p_flash_clk - Buffered output port, 32bit transfer width, 1bit Port Width
 * p_flash_ss - Output port, 1bit Port Width
 */
#ifdef __XC__
void spiFlash(chanend cSpiFlash,
    buffered in port:8 p_flash_miso, out port p_flash_ss, buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi, clock b_flash_clk, clock b_flash_data);
#endif

#endif /*SPIFLASH_H_*/
