// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign_Bootloader
 * Version: 9.10.0
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
 * File:    xbhandler.h
 *
 *
 **/                                   
#ifndef XBHANDLER_H_
#define XBHANDLER_H_

int getTStamp(int addr, int type,
#ifdef OTPSUPPORT
    in port otp_data, out port otp_addr, out port otp_ctrl ,
#endif
    out port p_flash_ss, buffered in port:8 p_flash_miso,
        buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

int checkXbCrc(unsigned addr, int type, 
#ifdef OTPSUPPORT
    in port otp_data, out port otp_addr, out port otp_ctrl ,
#endif
    out port p_flash_ss, buffered in port:8 p_flash_miso,
        buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

int bootXb(unsigned addr, int type, in port otp_data, out port otp_addr, out port otp_ctrl ,
    out port p_flash_ss, buffered in port:8 p_flash_miso,
        buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi);

#endif /*XBHANDLER_H_*/
