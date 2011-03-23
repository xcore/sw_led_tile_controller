// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    xbhandler.xc
 *
 *
 **/                                   
#include <xs1.h>
#include <flashphy.h>


#ifdef OTPSUPPORT
#include <otp.h>
#endif
#ifdef BOOTSUPPORT
#include <support.h>
#endif
#include <xclib.h>

#include "dprint.h"

#ifndef OTPSUPPORT
#define otpRead(a,b,c,d,e,f)
#endif

#define wordRead(addr, buf, nwords, type) { if (type) spi_wordread(addr, buf, nwords, p_flash_ss, p_flash_miso, p_flash_clk, p_flash_mosi); \
                                        else otpRead(addr, buf, nwords, otp_data, otp_addr, otp_ctrl);}



// ---------------- XB Handling -----------------

int getTStamp(int addr, int type,
#ifdef OTPSUPPORT
    in port otp_data, out port otp_addr, out port otp_ctrl ,
#endif
    out port p_flash_ss, buffered in port:8 p_flash_miso,
        buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi)
{
  unsigned buf[1];
  wordRead(addr, buf, 1, type);
  return buf[0];
}

int checkXbCrc(unsigned addr, int type, 
#ifdef OTPSUPPORT
    in port otp_data, out port otp_addr, out port otp_ctrl ,
#endif
    out port p_flash_ss, buffered in port:8 p_flash_miso,
        buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi)
{
  unsigned buf[2], sectortype, sectorsize;
  unsigned poly = bitrev(0x04c11db7);
  // addr received in bytes
  // Convert to words
  addr >>= 2;
  // Skip timestamp
  addr++;
  
  // Check XB Header
  wordRead(addr, buf, 2, type);
  if (buf[0] != 0x534F4D58 || buf[1] != 0x01)
  {
    dbgprintstr("XB Header failed\n");
    return 1;
  }
  dbgprintstr("XB Header passed\n");
  addr += 2;

  // Read sector type
  wordRead(addr, buf, 1, type);
  sectortype = buf[0] & 0xFFFF;
  while (sectortype != 0x5555)
  {
    unsigned crc=0;
    dbgprintstr("Found sector type");
    dbgprintintln(sectortype);
    // Read 
    wordRead(addr+1, buf, 2, type);
    if ((buf[0] & 0x3) || (buf[1] & 0xFFFF0000))
    {
      dbgprintstr("Size Misaligned\n");
      return 2;
    }
    sectorsize = ((buf[0] >> 2) | (buf[1] << 30)) - 1;
    dbgprintstr("Size: ");
    dbgprintintln(sectorsize);

    if (sectorsize != 0)
    {
      for (int i=1; i<sectorsize+4; i++)
      {
        wordRead(addr, buf, 1, type);
        crc32(crc, buf[0], poly);
        addr++;
      }
      
      wordRead(addr, buf, 1, type);
      addr++;
      buf[0] = bitrev(buf[0]);

      if (crc != buf[0] && (crc ^ poly) != buf[0])
      {
        dbgprinthexln(buf[0]);
        dbgprinthexln(bitrev(crc));
        dbgprintstr("CRC Failed\n");
        return 3;
      }
      else
      {
        dbgprintstr("CRC Passed\n");
      }
    }
    else
    {
      addr+=4;
      dbgprintstr("Zero Size\n");
    }
    
    // Read sector type
    wordRead(addr, buf, 1, type);
    sectortype = buf[0] & 0xFFFF;
  }
  return 0;
}

#ifdef BOOTSUPPORT
int bootXb(unsigned addr, int type, in port otp_data, out port otp_addr, out port otp_ctrl ,
    out port p_flash_ss, buffered in port:8 p_flash_miso,
        buffered out port:32 p_flash_clk, buffered out port:8 p_flash_mosi)
{
   unsigned buf[2], sectortype, sectorsize;
   // addr received in bytes
   // Convert to words
   addr >>= 2;
   // Skip timestamp
   addr++;
   
   // Check XB Header
   wordRead(addr, buf, 2, type);
   if (buf[0] != 0x534F4D58 || buf[1] != 0x01)
   {
     dbgprintstr("XB Header failed\n");
     return 1;
   }
   dbgprintstr("XB Header passed\n");
   addr += 2;

   // Read sector type
   wordRead(addr, buf, 1, type);
   sectortype = buf[0] & 0xFFFF;
   while (sectortype != 0x5555)
   {
     dbgprintstr("Found sector type");
     dbgprintintln(sectortype);
     // Read 
     wordRead(addr+1, buf, 2, type);
     if ((buf[0] & 0x3) || (buf[1] & 0xFFFF0000))
     {
       dbgprintstr("Size Misaligned\n");
       return 2;
     }
     sectorsize = ((buf[0] >> 2) | (buf[1] << 30)) - 1;
     dbgprintstr("Size: ");
     dbgprintintln(sectorsize);
     addr += 4;
     if (sectorsize != 0 && sectortype == 1)
     {
       unsigned nodeid,coreid;
       wordRead(addr, buf, 1, type);
       nodeid = buf[0] & 0xFFFF;
       coreid = buf[0] >> 16;
       
       dbgprintstr("Node ID ");        dbgprintintln(nodeid);
       dbgprintstr("Core ID ");        dbgprintintln(coreid);
       if (nodeid != 0 || coreid > 3)
       {
         dbgprintstr("Invalid\n");
         addr += sectorsize;
       }
       else
       {
         unsigned ptr;
         sectorsize -= 3;
         addr += 3;
         
         if (coreid)
         {
           ptr = getChanEnd((coreid << 16) | 0x02);
           outw(ptr, ptr);
           outw(ptr, sectorsize-1);
         }
         else
         {
           ptr = 0x10000;
         }
         
         while (sectorsize > 1)
         {
           wordRead(addr, buf, 1, type);
           if (coreid)
           {
             outw(ptr, buf[0]);
           }
           else
           {
             store(ptr, buf[0]);
             ptr += 4;
           }

           sectorsize--;
           addr++;
         }
         // Skip CRC
         addr++;
        
         if (coreid)
         {
           outw(ptr, 0xd15ab1e);
           outCT(ptr, XS1_CT_END);
           freeChanEnd(ptr);
         }
       }
     }
     else
     {
       addr+=sectorsize;
       dbgprintstr("Skipping\n");
     }
     
     wordRead(addr, buf, 1, type);
     sectortype = buf[0] & 0xFFFF;
   }

   jump(0x10000);
   return 0;
}
#endif

