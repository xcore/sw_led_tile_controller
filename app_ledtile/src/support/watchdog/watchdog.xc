// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    watchdog.xc
 *
 *
 **/                                   
#include "xs1.h"
#include "watchdog.h"
#include "misc.h"
#include "led.h"
#include "print.h"

void watchDog(chanend c[NUM_WATCHDOG_CHANS], int slow)
{
  timer t;
  int time;
  int dog_kicked;
  
  if (slow)
  {
    slowdown();
  }
  
  // Init dog
  dog_kicked = 0;
  
  // Wait on start
  t :> time;
  t when timerafter(time + WDOG_INITIAL_WAIT/CORECLOCKDIV) :> time;
  
  while (1)
  {
    select
    {
      case t when timerafter (time + WDOG_WAIT/CORECLOCKDIV) :> time:
        // Check dog    
        if (dog_kicked != (1 << NUM_WATCHDOG_CHANS) - 1)
        {
          for (int i=0; i<NUM_WATCHDOG_CHANS; i++)
          {
            if (!(dog_kicked & (1<<i)))
            {
              printstr("Watchdog failed on chan "); printintln(i);
            }
          }
          printintln(dog_kicked);
#ifdef RELEASE
          chipReset();
#else
          while (1);
#endif
        }
        dog_kicked = 0;
        break;
      case (int i=0; i<NUM_WATCHDOG_CHANS; i++) c[i] :> int _:
        dog_kicked |= (1 << i);
        break;
    }
  }
}
