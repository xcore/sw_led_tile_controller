// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    flashclient.h
 *
 *
 **/                                   
#ifndef FLASHCLIENT_H_
#define FLASHCLIENT_H_

#include <xccompat.h>

void flash_write_gamma(int block, unsigned short gt[], chanend cFlash);

#ifdef __XC__
void flash_write_firmware(chanend cFlash, int addr, int len, unsigned char data[]);
#else
void flash_write_firmware(chanend cFlash, int addr, int len, unsigned char *data);
#endif

#endif /*FLASHCLIENT_H_*/
