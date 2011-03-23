// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    bcmserver.xc
 *
 *
 **/                                   
#include "led.h"


void bcmserver(chanend cIn, chanend cOut)
{
  unsigned buf[BCM_BITS][OUTPUT_BUF_SIZE];
  
  int pixptr,datalen,temp;
  unsigned char packet[1520];
  
  while (1)
  {
    // Receive new frame data
    slave
    {
      for (int x=0; x<FRAME_WIDTH; x++)
      {
        int x1 = (x / MODULE_WIDTH);
        int x2 = ((x % MODULE_WIDTH) / (CHAIN_LOOPBACK_X*SCAN_RATE));
        int x3 = (x % SCAN_RATE);
        for (int y=0; y<FRAME_HEIGHT; y++)
        {
          for (int c=0; c<3; c++)
          {
            unsigned outval, outptr;
            cIn :> outval;
            // Calculate position in the output array
            outptr = y;
            outptr += FRAME_HEIGHT * (NUM_MODULES_X - 1 - x1);
            outptr += FRAME_HEIGHT * NUM_MODULES_X * c;
            outptr += FRAME_HEIGHT * NUM_MODULES_X * 3 * x2;
            outptr += FRAME_HEIGHT * NUM_MODULES_X * 3 * (MODULE_WIDTH/(CHAIN_LOOPBACK_X*SCAN_RATE)) * x3;

            // Truncate to the BCM depth
            outval >>= (16 - BCM_BITS);
            
            // Split the output bits into two sections
            // The lower bits we ignore if the highest bit is set
            #define INTER_POINT (BCM_BITS - 2)
            if (!(outval >> BCM_BITS - 1))
            {
              for (int i=0; i<(BCM_BITS - 1); i++)
              {
                buf[i][outptr >> 5] |= ( (outval & 1) << (outptr & 0x1F) );    
                outval >>= 1;
              }        
            }
            else
            {
              outval >>= (BCM_BITS - 1);
            }
            
            for (int i=(BCM_BITS - 1); i<BCM_BITS; i++)
            {
              buf[i][outptr >> 5] |= ( (outval & 1) << (outptr & 0x1F) );    
              outval >>= 1;
            }                    
          }
        }
      }      
    }
    // End of frame receive
    
    // Pass frame data to pins thread
    master
    {
      for (int scan = 0; scan < SCAN_RATE; scan++)
      {          
        for (int bcmbit = 0; bcmbit < BCM_BITS; bcmbit++)
        {
          int r, ts;
          for (r = 0; r < DRIVE_REPEAT_COUNT; r++)
          {
            unsigned ptr = scan * OUTS_PER_CYCLE * PORT_WIDTH;
            for (int i = 0; i < OUTS_PER_CYCLE; i++)
            {
              cOut <: buf[bcmbit][ptr + 0];
              cOut <: buf[bcmbit][ptr + 1 * OUTS_PER_CYCLE];
              cOut <: buf[bcmbit][ptr + 2 * OUTS_PER_CYCLE];
              cOut <: buf[bcmbit][ptr + 3 * OUTS_PER_CYCLE];
              cOut <: buf[bcmbit][ptr + 4 * OUTS_PER_CYCLE];
              cOut <: buf[bcmbit][ptr + 5 * OUTS_PER_CYCLE];
            }
          }
        }
      }
    }
  }
}
