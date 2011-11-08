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

/*
 * A simple watchog thread. It recives signals from all watched threads (connected over a channel to the watchdog.
 * If one thread does not send a alive package (any int value) to the watchdog a reset is performed.
 * Technically only in the RELEASE config the chip is rebootet.
 *
 * Channels
 * c - the end channels for the threads to supervise.
 *
 * Parameters
 * slow - if the thread should run at 100/32Mhz (??), if set, or full speed
 */
void watchDog(chanend c[NUM_WATCHDOG_CHANS], int slow, int enabled)
{
  //the timer & time to schedule the watchdog activities
  timer t;
  int time;
  //a bit field which thread has answered to the watchdog
  int dog_kicked;

  //if we are requested to run at a lower clock rate - do so
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
      //if the timer has run out check which threads have answered
      case t when timerafter (time + WDOG_WAIT/CORECLOCKDIV) :> time:
        // if not all threads have answered
        if (dog_kicked != (1 << NUM_WATCHDOG_CHANS) - 1)
        {
          //check which thread has not answered
          for (int i=0; i<NUM_WATCHDOG_CHANS; i++)
          {
            if (!(dog_kicked & (1<<i)))
            {
              printstr("Watchdog failed on chan "); printintln(i);
            }
          }
          printintln(dog_kicked);
          if (enabled) {
        	  //reboot
        	  chipReset();
          }
        }
        //reset the thread notfication bit field
        dog_kicked = 0;
        //and go ahead
        break;
      //if any of the watched threads sends a value
      case (int i=0; i<NUM_WATCHDOG_CHANS; i++) c[i] :> int _:
        //set whe corresponding bit
        dog_kicked |= (1 << i);
        break;
    }
  }
}
