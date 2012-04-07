// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign_Bootloader
 * Version: 9.10.0
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
 * File:    main.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <print.h>
#include <flashphy.h>
#include <otp.h>
#include <support.h>
#include <xclib.h>
#include "xbhandler.h"
#include "dprint.h"


// ---------------- Ports ---------------

in port otp_data = OTP_DATA_PORT;
out port otp_addr = OTP_ADDR_PORT;
out port otp_ctrl = OTP_CTRL_PORT;
buffered in port:8 p_flash_miso      = XS1_PORT_1A;
out port p_flash_ss                  = XS1_PORT_1B;
buffered out port:32 p_flash_clk     = XS1_PORT_1C;
buffered out port:8 p_flash_mosi     = XS1_PORT_1D;
clock b_clk                          = XS1_CLKBLK_1;
clock b_data                         = XS1_CLKBLK_2;

// ---------------- Relocation Details ---------------

#define STAGE2SIZEBYTES 0x2000
#define NO_OTP_IMAGE

unsigned ramBase = XS1_RAM_BASE;
unsigned stage2Dest = XS1_RAM_BASE + XS1_RAM_SIZE - STAGE2SIZEBYTES;
unsigned stage2Size = STAGE2SIZEBYTES >> 2;
unsigned ramSize = XS1_RAM_SIZE;

#define OTP_BFE_ADDRESS 0x500

#define wordRead(addr, buf, nwords, type) { if (type) spi_wordread(addr, buf, nwords, p_flash_ss, p_flash_miso, p_flash_clk, p_flash_mosi); \
                                        else otpRead(addr, buf, nwords, otp_data, otp_addr, otp_ctrl);}

// ---------------- Code Main -------------------

#ifdef RELOCATE
int realmain(void)
#else
int main(void)
#endif
{
  
  unsigned tstampset = 0;
  int tstamp;

  dbgprintstr("Starting Bootstrap\n");
  spi_init(p_flash_ss, p_flash_miso , p_flash_clk, p_flash_mosi, b_clk, b_data);
  
  // Look for a valid SPI image in sectors 1-3
  for (int sector=1; sector<4; sector++)
  {
    dbgprintstr("Sector");
    dbgprintintln(sector);
    if (!checkXbCrc(sector*SPI_NUM_BYTES_IN_SECTOR, 1, otp_data, otp_addr, otp_ctrl , p_flash_ss, p_flash_miso, p_flash_clk, p_flash_mosi)) 
    {
      int newtstamp = getTStamp(sector, 1, otp_data, otp_addr, otp_ctrl , p_flash_ss, p_flash_miso, p_flash_clk, p_flash_mosi);
      if ((tstampset && (newtstamp > tstamp)) || (!tstampset))
      {
        tstampset = sector+1;
        tstamp = newtstamp;
      }
    }
  }
  
  
  if (tstampset)
  {
    // Boot from SPI
    bootXb((tstampset-1)*SPI_NUM_BYTES_IN_SECTOR, 1, otp_data, otp_addr, otp_ctrl , p_flash_ss, p_flash_miso, p_flash_clk, p_flash_mosi);
  }
  else
  {
    // Boot from OTP
    // No OTP image stored currently
#ifdef NO_OTP_IMAGE
    while (1);
#else
    bootXb(OTP_BFE_ADDRESS, 0, otp_data, otp_addr, otp_ctrl , p_flash_ss, p_flash_miso, p_flash_clk, p_flash_mosi);
#endif
  }
  
  return 0;
}

