// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    misc.xc
 *
 *
 **/                                   
#include <xs1.h>
#include "misc.h"

void sleep(int timerticks)
{
  timer t;
  int now;
  
  t :> now;
  t when timerafter(now + timerticks) :> now;
}

int pollChan(chanend c)
{
  select
  {
    case c :> int _:
      return 0;
    default:
      return 1;
  }
}

int pollSChan(streaming chanend c)
{
  select
  {
    case c :> int _:
      return 0;
    default:
      return 1;
  }
}

// Perform a soft reset of the device by writing to the PLL control register
void chipReset(void)
{
  unsigned x;
  
  read_sswitch_reg(get_core_id(), 6, x);
  write_sswitch_reg(get_core_id(), 6, x);
}

void slowdown(void)
{
  // Clock down this core
  write_pswitch_reg(get_core_id(), 6, CORECLOCKDIV);
  // Clock down switch
  write_sswitch_reg(get_core_id(), 7, 3);
  // Reference clock is still running at 100Mhz, so we cannot sample it reliably
  // Set reference to XCore clock
  setps(0x20b, 0x1);
}

