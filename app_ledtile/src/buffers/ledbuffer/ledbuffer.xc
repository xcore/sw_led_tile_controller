// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ledbuffer.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <xclib.h>
#include "led.h"
#include "ledbuffercalculations.h"
#include "logo.h"

#define SWAP(a,b)      {a -= b; b += a; a = b - a;}
//should the buffer be rotate by 90 degrees while outputing data
//by default no - since the data is fed in and put out by columns
//TODO shouldn't the driver decide this??
//#define NOROTATE

//----Possible test patterns-----
#ifndef SIMULATION

//#define SINGLELINETEST
//#define SHADETESTX
#define SHADETESTY
//#define GAMMATEST 100
#define LOGO

#endif

//default color for gamma test (or something similar)
#define DIV 1

// ------------------------------
//TODO is the unsafe array needed?
#pragma unsafe arrays
void ledbuffer(chanend cIn, streaming chanend cOut)
{
  // Double buffer -- two frames
  // Frame is stored with in columns (original bitmap xy swapped)
  // This allows outputting one column at a time in a simple loop
  //the size is defined by width * heigt * 3 (rgb) *2 (double buffer)
  unsigned char buffer[LED_BUFFER_BUFFER_SIZE];

  //a marker variable if the buffer sink (i.e led driver) allowed to swap the buffers
  //i.e. are all values rendered from the first buffer to prevent image tearing
  unsigned bufswaptriggerN=1;
  //the part of the buffer to write to
  unsigned inbufptr=0;
  //the part of the buffer to read from
  unsigned outbufptr=LED_BUFFER_FRAME_SIZE;
  
  
  // Initialise the buffer to the specified test pattern
  // ---------------------------------------------------
  {
    unsigned ptr = 0;
#ifndef SIMULATION
    for (int buf=0; buf < LED_BUFFER_BUFFER_SIZE; buf++)
      buffer[buf] = 0;
#endif
    
#if defined SINGLELINETEST
    for (int buf=0; buf < 2; buf ++)
    {
  	  for (int y=0; y < FRAME_HEIGHT; y++)
  	  {
  	    for (int x=0; x < FRAME_WIDTH; x++)
  	    {
          for (int c=0; c < LED_BUFFER_COLORS; c++)
          {
            buffer[ptr] = 0xFF * (y==1); 
            ptr++;
          }
        }
      }
    } 
#elif defined SHADETESTX
    for (int buf=0; buf < 2; buf ++)
    {
      for (int y=0; y < FRAME_HEIGHT; y++)
      {
        for (int x=0; x < FRAME_WIDTH; x++)
        {
          for (int c=0; c < LED_BUFFER_COLORS; c++)
          {
            buffer[ptr] = (( 0xFF * x ) / (FRAME_WIDTH - 1)); 
            ptr++;
          }
        }
      }
    }
#elif defined SHADETESTY
    for (int buf=0; buf < 2; buf ++)
    {
      for (int y=0; y < FRAME_HEIGHT; y++)
      {
        for (int x=0; x < FRAME_WIDTH; x++)
        {
          for (int c=0; c < LED_BUFFER_COLORS; c++)
          {
            buffer[ptr] = ((0xFF * y) / ((FRAME_HEIGHT - 1))); 
            ptr++;
          }
        }
      }
    }
#elif defined GAMMATEST
    for (int buf=0; buf < 2; buf ++)
    {
      for (int y=0; y < FRAME_HEIGHT; y++)
      {
        for (int x=0; x < FRAME_WIDTH; x++)
        {
          for (int c=0; c < LED_BUFFER_COLORS; c++)
          {
            if (y < FRAME_HEIGHT >> 1)
            {
              buffer[ptr] = ( (GAMMATEST * 255) / 100 ); 
            }
            else if ((y+x) & 1)
            {
              buffer[ptr] = 0;
            }
            else
            {
              buffer[ptr] = (255/ DIV);
            }
              
            ptr++;
          }
        }
      }
    }  
#elif defined LOGO
    {
      int ptr=0;
      // Load from logo.c
      for (int y=0; y<FRAME_HEIGHT; y++)
      {
        for (int x=0; x<FRAME_WIDTH; x++)
        {
          for (int c=0; c < LED_BUFFER_COLORS; c++)
          {
            int ptrx, ptr2;
            
#if LOGO_WIDTH > FRAME_WIDTH
            ptrx = (x * (LOGO_WIDTH / FRAME_WIDTH)) * LOGO_HEIGHT;
#else
            ptrx = (x % LOGO_WIDTH) * LOGO_HEIGHT ;            
#endif
#if LOGO_HEIGHT > FRAME_HEIGHT
            ptr2 = (ptrx + ((FRAME_HEIGHT - 1 - y)*(LOGO_HEIGHT / FRAME_HEIGHT))) * LED_BUFFER_COLORS + c;
#else
            ptr2 = (ptrx + ((FRAME_HEIGHT - 1 - y)%LOGO_HEIGHT)) * LED_BUFFER_COLORS + c;
#endif                        
            //copy over the logo
            buffer[ptr] = xmossmall_raw[ptr2];
            //and put it in the 2nd buffer too
            buffer[LED_BUFFER_FRAME_SIZE + ptr] = buffer[ptr];
            ptr++;
          }
        }
      }
    }
#endif
  }
  
  // ---------------------------------------------------
  // Buffer init complete

  //now we can move over to our pixel pushing routine
  while (1)
  {
    unsigned pixelptr;
#pragma ordered
    select
    {
        // Sink request of pixel data (send data to the led driver)
    	//the pixelpointer contains -1 for a new image
    	//or the column/row number
      case cOut :> pixelptr:
        if (pixelptr == -1)
        {
          // End of frame signal from display driver
          // If the source wants us to swap, do so
          if (bufswaptriggerN == 0)
          {
            SWAP(inbufptr, outbufptr);
            bufswaptriggerN=1;
          }
        }
        else
        {
          // Request for data received by display driver
          // Entire column sent in response
          // Move ptr to required frame
        	//TODO why is it outputed as 32 bit with 0GBR??
#ifdef NOROTATE
          //output the data row wise
          pixelptr = LED_BUFFER_ROW(pixelptr);
          pixelptr += outbufptr;
          for (int i=0; i<FRAME_WIDTH; i++)
          {
              cOut <: (char)buffer[pixelptr+2];
              cOut <: (char)buffer[pixelptr+1];
              cOut <: (char)buffer[pixelptr];
              cOut <: (char)0;
              //move to the next pixel in the row
              pixelptr += LED_BUFFER_COLORS;
          }
#else
          //output the data column wise
          pixelptr *= LED_BUFFER_COLORS;
          pixelptr += outbufptr;
          for (int i=0; i<FRAME_HEIGHT; i++)
          {
            cOut <: (char)buffer[pixelptr+2];
            cOut <: (char)buffer[pixelptr+1];
            cOut <: (char)buffer[pixelptr];
            cOut <: (char)0;
            //move to the next pixel in the row
            pixelptr += LED_BUFFER_ROW_SIZE;
          }
#endif
        }
        break;
      
      // Source dump
      // Guard exists to prevent more data pushed in after frame switch
      case (bufswaptriggerN) => slave
      {
        cIn :> pixelptr;
        if (pixelptr == -1)
        {
          // End of frame signal from source
          // Frame will not be swapped until sink completes also
          bufswaptriggerN = 0;
        }
        else
        {
          // New data from source
          int len;
          cIn :> len;
          
          //TODO this should we reworked using defines - hard to understand math
          pixelptr = LED_BUFFER_BUFFER_BYTE_POSITION(pixelptr);
          pixelptr += inbufptr;
          //write the pixel data to the buffer
          while (len > 0)
          {
            cIn :> buffer[pixelptr+2];
            cIn :> buffer[pixelptr+1];
            cIn :> buffer[pixelptr];
            
            pixelptr+=LED_BUFFER_COLORS;
            len-=LED_BUFFER_COLORS;
          }
        }
      }:
      break;
    }
  }
  
  // Should never reach here
}
