// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign_Bootloader
 * Version: 9.10.0
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
 * File:    otp.xc
 *
 *
 **/                                   
#include <xs1.h>

#include "otp.h"

#define WAIT(thetimer, time) { int now; thetimer :> now; thetimer when timerafter(now + time) :> now; }

#define REF_TIME_TICK (1000 / REFERENCE_MHZ)

/* READ access time */
#define tACC_TICKS (35 / REF_TIME_TICK)

/* Control signals */
#define READ_SHIFT 0
#define READ (1 << READ_SHIFT)

#define STATUS_SHIFT 5
#define STATUS  (1 << STATUS_SHIFT)

void otpRead(unsigned address, unsigned buffer[], unsigned length, in port otp_data, out port otp_addr, out port otp_ctrl)
{
  for (int i=0; i<length; i++)
  {
#ifdef ASYNC
  unsigned status = 0;
  otp_addr <: address;
  sync(otp_addr);
  otp_ctrl <: READ;
  sync(otp_addr);
  sync(otp_ctrl);
  do {
    status = Peek(otp_ctrl);
    status = (status & STATUS) != 0;
  } while (! status);
  otp_data :> buffer[i];
  otp_data :> buffer[i];
  otp_ctrl <: 0;
#else
  otp_addr <: address;
  sync(otp_addr);
  otp_ctrl <: READ;
  sync(otp_addr);
  // Sync time
  sync(otp_addr);  sync(otp_addr);   sync(otp_addr);   sync(otp_addr);
  sync(otp_addr);  sync(otp_addr);   sync(otp_addr);   sync(otp_addr);
  otp_data :> buffer[i];
  otp_ctrl <: 0;
  sync(otp_addr);  sync(otp_addr);   sync(otp_addr);   sync(otp_addr);
#endif
  }
}

