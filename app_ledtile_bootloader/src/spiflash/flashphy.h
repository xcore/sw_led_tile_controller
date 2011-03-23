// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign_Bootloader
 * Version: 9.10.0
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
 * File:    flashphy.h
 *
 *
 **/                                   
#ifndef __FLASHPHY_H__
#define __FLASHPHY_H__

// --------- Global ---------
#define DISABLE_SPI_FLASH


// -------- Atmel specific commands ---------
// Sectors are used for protection
static const int SPI_NUM_SECTORS         = 8;
static const int SPI_NUM_BYTES_IN_SECTOR = 65536;

static const int SPI_DEVICE_ID_MASK = 0xffffffff;
static const int SPI_DEVICE_ID = 0x1f440100;

static const int SPI_BYTES_IN_PAGE = 256;

// Write in progress status register mask bit
static const int SPI_WIP_BIT_MASK = 1;

// Commands
static const int SPI_WREN      = 0x06;   // Write Enable
static const int SPI_WRDI      = 0x04;   // Write Disable
static const int SPI_RDID      = 0x9F;   // Read Device ID
static const int SPI_RDSR      = 0x05;   // Read Status Register
static const int SPI_READ      = 0x03;   // Read Data Bytes
static const int SPI_READ_FAST = 0x0B;   // Read Data Bytes Fast
static const int SPI_PP        = 0x02;   // Page Program
static const int SPI_SE        = 0xD8;   // Sector Erase
static const int SPI_SP        = 0x36;   // Sector Protect
static const int SPI_SU        = 0x39;   // Sector Unprotect
static const int SPI_BE        = 0x20;   // Block Erase

#ifdef __XC__
// --------- Function calls ---------
// Init
void spi_init(out port p_flash_ss, buffered in port:8 p_flash_miso
    , buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi
    , clock b_clk, clock b_data);

// Clean up
void spi_end( out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Read device ID
void spi_device_id(unsigned &device_id_ref,  out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Read status register
void spi_status_reg(unsigned &status_reg_ref,  out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Read bytes from ptr
void spi_read(int ptr, unsigned char buffer[], int nbytes,  out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);
void spi_wordread(int wordptr, unsigned buffer[], int nwords,  out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Write bytes to a given page
// Page size is SPI_BYTES_IN_PAGE
// Note: Sector must be made unprotected first
// Note: Page must be erased wfirst
// Note: Write enable is handled inside
void spi_write(int page, const unsigned char buffer[], int nbytes,  out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);
void spi_wordwrite(int wordptr, const unsigned buffer[], int nbytes,  out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Erase given sector
// Sector size is SPI_NUM_BYTES_IN_SECTOR
// Note: Sector must be made unprotected first
void spi_erase(int sector,  out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);
void spi_erase_all(out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Erase given 4kB block
// Note: Sector must be made unprotected first
void spi_blockerase(int baddr, out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Unprotect sector at given address
// Takes byte address not sector number!
// This is because some devices have uneven sector protection layout
void spi_unprotect(unsigned addr, out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

void spi_unprotect_all(out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Protect sector at given address
// Takes byte address not sector number!
// This is because some devices have uneven sector protection layout
void spi_protect(unsigned addr, out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Erase/write progress
// Returns 1 if device is still busy with last erase/write
// Will try 3 times with 1us delay between each try
// Typical use: "while(spi_poll_progress())"
int spi_poll_progress(out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

// Write enable/disable
// Normally don't need to be explicitly called
void spi_write_enable( out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);
void spi_write_disable( out port p_flash_ss, buffered in port:8 p_flash_miso,
    buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

#endif
#endif
