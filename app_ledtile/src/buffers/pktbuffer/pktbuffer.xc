// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * A general purpose packet buffer.
 *
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    pktbuffer.xc
 *
 *
 **/                                   
#include <xs1.h>
#include "led.h"

/*
 * COMMAND BUFFER
 * Buffering FIFO for commands.
 * Sinks commands such as gamma LUT changes, intensity value changes from
 * the local server and buffers them on a packet-by-packet basis in
 * a circular fifo for the LED driving thread to receive when ready.
 *
 * Packets are send via cIn and can be received via cOut.
 * For storing a package the sender sends the size of the package (int) and either receives a 0 if the package can be store
 * or a 0 if there is not enough room. If the package is accepted the sender must send as many int values as specified by the
 * length of th package.
 * The receiver can request a package by sending an arbitrary int over cOut. It then receives the size of the package as int
 * and the package data as int values. It must read all values as specified by the length.
 *
 * Channels
 * cln - Streaming bidirectional command sink
 * cOut - Streaming bidirectional command source
 */
#pragma unsafe arrays
void pktbuffer(chanend cIn, streaming chanend cOut)
{
  unsigned int temp;
  unsigned int buffer[(1 << PKTBUFFERBITS)];
  unsigned int rptr = 0;
  unsigned int wptr = 0;
  unsigned int bmask = ((1 << PKTBUFFERBITS) - 1);
  set_thread_fast_mode_on();
  
  // Buffer commands for the driver to interpret
  while (1)
  {
#pragma ordered
    select
    {
      // New packet from source
      case slave {
        cIn :> temp;
        {
    	  // Test if FIFO has enough space to include this packet
          unsigned int tempwptr = wptr + temp + 2;
          if (tempwptr > (1 << PKTBUFFERBITS) && tempwptr - (1 << PKTBUFFERBITS) >= rptr)
          {
        	  // Nack
            cIn <: (int)1;
          }
          else if (wptr < rptr && tempwptr >= rptr)
          {
            // Nack
            cIn <: (int)1;
          }
          else
          {
        	  // Ack
            cIn <: (int)0;
            // Store packet size in FIFO
            buffer[wptr++] = temp;
            wptr &= bmask;
            while (temp)
            {
              temp--;
              cIn :> buffer[wptr++];
              wptr &= bmask;
            }
          }
        }
      }:
      break;
      
      // Packet request from sink
      case cOut :> temp:
    	  // Check if FIFO is empty
        if (wptr == rptr)
        {
          // Nack
          cOut <: 1;
        }
        else
        {
          // Retrieve packet size from buffer
          unsigned int num = buffer[rptr++];
          rptr &= bmask;
          // Ack
          cOut <: 0;
          // Send packet size
          cOut <: num;
          while (num)
          {
          	num--;
          	cOut <: buffer[rptr];
          	
          	rptr++;
            rptr &= bmask;
          }
          //outct(cOut, XS1_CT_PAUSE);
        }
      break;
    }
  }
}
