// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign_Bootloader
 * Version: 9.10.0
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
 * File:    otp.h
 *
 *
 **/                                   
#ifndef _OTP_H_
#define _OTP_H_

#define OTP_DATA_PORT XS1_PORT_32B
#define OTP_ADDR_PORT XS1_PORT_16C
#define OTP_CTRL_PORT XS1_PORT_16D

#define REFERENCE_MHZ 100

void otpRead(unsigned address, unsigned buffer[], unsigned length, in port otp_data, out port otp_addr, out port otp_ctrl);

#endif /* _OTP_H_ */
