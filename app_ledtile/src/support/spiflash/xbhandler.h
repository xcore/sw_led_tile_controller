// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
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
