// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    getmac.xc
 *
 *
 **/                                   
#include <xs1.h>
#include "print.h"
#include "getmac.h"

#define OTPADDRESS 0x7FF
#define OTPREAD 1
#define OTP_tACC_TICKS 4 // 40nS

unsigned otpRead(unsigned address, port ctrl, out port addr, port data)
{
  unsigned value;
  timer t;
  int now;
  
  ctrl <: 0;
  addr <: 0;
  addr <: address;
  sync(addr);
  ctrl <: OTPREAD;
  sync(addr);
   t :> now;
   t when timerafter(now + OTP_tACC_TICKS) :> now;
  data :> value;
  ctrl <: 0;

  return value;
}

int retrieveBitmap(unsigned &bitmap, unsigned &address, struct otp_ports &ports)
{
  int validbitmapfound = 0;
  
  address = OTPADDRESS;
  while (!validbitmapfound)
  {      
    bitmap = otpRead(address, ports.ctrl, ports.addr, ports.data);
#if 0
  printhexln(bitmap);
#endif  

    if (bitmap >> 31)
    {
      // Bitmap has not been written
      return 2;
    }
    else if (bitmap >> 30)
    {
      validbitmapfound = 1;
    }
    else
    {
      unsigned headersize = (bitmap >> 25) & 0x1F;
      if (headersize == 0)
        headersize = 8;
      // Invalid bitmap
      address -= headersize;
    }
  }
  return !validbitmapfound;
  
}

int getMacAddr(unsigned MACAddrNum, unsigned macAddr[2], struct otp_ports &ports)
{
  unsigned address = OTPADDRESS;
  unsigned bitmap;
  
  if (MACAddrNum < 7)
  {
    if (retrieveBitmap(bitmap, address, ports))
      return 2;
    
    if (((bitmap >> 22) & 0x7) > MACAddrNum)
    {
      address -= ((MACAddrNum << 1) + 1);
      macAddr[0] = otpRead(address, ports.ctrl, ports.addr, ports.data);
      address--;
      macAddr[1] = otpRead(address, ports.ctrl, ports.addr, ports.data);
      return 0;
    }
    else
    {
      // MAC Address cannot be found
      return 3;
    }
  }
  else
  {
    // Incorrect number of MAC addresses given
    return 1;
  }
}
