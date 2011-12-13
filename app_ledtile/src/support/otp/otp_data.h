// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    getmac.h
 *
 *
 **/                                   
#include <xs1.h>
#include <xccompat.h>

#ifndef __getmac_h__
#define __getmac_h__

#define OTP_DATA_PORT XS1_PORT_32B
#define OTP_ADDR_PORT XS1_PORT_16C
#define OTP_CTRL_PORT XS1_PORT_16D

#ifndef __XC__
#define out  // xccompat doesn't deal with `out' or `in' specifiers
#endif

struct otp_ports {
  port data;
  out port addr;
  port ctrl;
};

#endif
