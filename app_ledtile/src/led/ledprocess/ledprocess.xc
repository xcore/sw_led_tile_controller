// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ledprocess.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <xclib.h>
#include "led.h"
#include "ledprocess.h"
#include "print.h"


unsigned char intensityadjust[3] = {0xFF, 0xFF, 0xFF};
unsigned short gammaLUT[3][256];

#pragma unsafe arrays
void ledprocess_init()
{
  // Init pixintensity
#ifdef PER_PIXEL_ADJUSTMENT
  for (int i=0; i<(FRAME_HEIGHT*FRAME_WIDTH*3); i++)
  {
    (pixintensity, unsigned char[])[i] = -1;
  }
#endif
}


// ledreprocess
// Load pixel data from buffer and apply gamma LUT and intensity colour correction
#pragma unsafe arrays
int ledprocess_commands(streaming chanend cLedCmd, streaming chanend cOut, int outen)
{
  int ledCmdResponse;
  
  // Check for commands
  cLedCmd <: 0;
  cLedCmd :> ledCmdResponse;
  while (ledCmdResponse == 0)
  {
    // New command received
    unsigned int cmdlen, cmdtyp;
    cLedCmd :> cmdlen;
    cLedCmd :> cmdtyp;
    switch (cmdtyp)
    {
      case (XMOS_GAMMAADJ):
      {
        int colchan;
        
        cLedCmd :> colchan;

        cmdlen -= 2;
        if (cmdlen >= 256)
          cmdlen = 256;
        for (int i=0; i < cmdlen; i++)
        {
          int data;
          cLedCmd :> data;
          
          switch(colchan)
          {
            case ('R'):              
              gammaLUT[0][i] = (unsigned short)data;
              break;
            case ('G'):
              gammaLUT[1][i] = (unsigned short)data;
              break;
            case ('B'):
              gammaLUT[2][i] = (unsigned short)data;
              break;
            default:
              gammaLUT[0][i] = (unsigned short)data;
              gammaLUT[1][i] = (unsigned short)data;
              gammaLUT[2][i] = (unsigned short)data;
              break;
          }
        }
      }
      break;
      case (XMOS_CHANGEDRIVER):
      {
        int newdrivertype;
        cLedCmd :> newdrivertype;
        if (outen)
        {
          cOut <: 0;
          cOut <: XMOS_CHANGEDRIVER;
          cOut <: newdrivertype;
        }
        return (newdrivertype);
      }
      break;
      case (XMOS_INTENSITYADJ):
      {
        int colchan, data;
        
        cLedCmd :> colchan;
        cLedCmd :> data;
        
        if (outen)
        {
          cOut <: 0;
          cOut <: XMOS_INTENSITYADJ;
          switch(colchan)
          {
            case ('R'):
              cOut <: 0x09090909;
              break;
            case ('G'):
              cOut <: 0x12121212;
              break;
            case ('B'):
              cOut <: 0x24242424;
              break;
            default:
              cOut <: 0xFFFFFFFF;
              break;
          }
          cOut <: data;
        }
      }
      break;
      case (XMOS_SINTENSITYADJ):
      {
        int colchan, data;
        
        cLedCmd :> colchan;
        cLedCmd :> data;
        
        switch(colchan)
        {
          case ('R'):
            intensityadjust[0] = data;
            break;
          case ('G'):
            intensityadjust[1] = data;
            break;
          case ('B'):
            intensityadjust[2] = data;
            break;
          default:
            intensityadjust[0] = data;
            intensityadjust[1] = data;
            intensityadjust[2] = data;
            break;
        }
      }
      break;
      case (XMOS_SINTENSITYADJ_PIX):
#ifdef PER_PIXEL_ADJUSTMENT
      {
        int colchan, x, y, data;
        
        cLedCmd :> colchan;
        cLedCmd :> y;
        cLedCmd :> x;
        cLedCmd :> data;
        switch(colchan)
        {
          case ('R'):
            pixintensity[y][x][0] = data;
            break;
          case ('G'):
            pixintensity[y][x][1] = data;
            break;
          case ('B'):
            pixintensity[y][x][2] = data;
            break;
          default:
            pixintensity[y][x][0] = data;
            pixintensity[y][x][1] = data;
            pixintensity[y][x][2] = data;
            break;
        }
      }
#endif
      break;
      default:
        for (int i=1; i < cmdlen; i++)
          cLedCmd :> int;
        break;
    }
    cLedCmd <: 0;
    cLedCmd :> ledCmdResponse;
  }
  
  if (outen)
  {
    cOut <: 1;
  }
  return 0;
}
