// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    flashclient.xc
 *
 *
 **/                                   
#include "flashmanager.h"

void flash_write_gamma(int block, unsigned short gt[], chanend cFlash)
{
  cFlash <: SPI_FLASH_NEWGAMMA;
  master
  {
    cFlash <: block;
    cFlash <: 256;
    for (int i=0; i<256; i++)
    {
      cFlash <: (unsigned int)gt[i];
    }
  }
}

void flash_write_firmware(chanend cFlash, int addr, int len, unsigned char data[])
{
  cFlash <: SPI_FLASH_WRITEFIRMWARE;
  
  master
  {
    cFlash <: addr;
    cFlash <: len;
    for (int j=0; j<len; j++)
      cFlash <: (char)data[j];
  }
}


