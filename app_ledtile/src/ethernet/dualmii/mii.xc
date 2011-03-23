// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    mii.xc
 *
 *
 **/                                   


#include <xs1.h>
#include "mii.h"
#include "print.h"
#include <syscall.h>
#include <xclib.h>

// Timestamps
#ifndef MII_TX_BUFFERED
#define MII_TX_TIMESTAMPS
#endif

// Error handling
#if 0
#define NO_ERROR_DISCARD
#endif

#ifdef SIMULATION
#define ERROR_TRAP
#endif

// Minimum interframe gap
// smi_is100() is used to time the gap on a 100 MHz timer
#define ENFORCE_MINIMUM_GAP
#define MINIMUM_GAP_TIMER_CYCLES_100MBPS 96
#define MINIMUM_GAP_TIMER_CYCLES_10MBPS 960

// Timing tuning constants
#define PAD_DELAY_RECEIVE    0
#define PAD_DELAY_TRANSMIT   0
#define CLK_DELAY_RECEIVE    0
#define CLK_DELAY_TRANSMIT   7  // Note: used to be 2 (improved simulator?)

// After-init delay (used at the end of mii_init)
#define PHY_INIT_DELAY 1000000
#define RX_BUF_OVERFLOW_TRAP

extern void user_trap();

#ifdef MII_COUNTERS
int mii_counter_rxgood;
int mii_counter_txall;
int mii_counter_rxercrc;
int mii_counter_rxerlen;
int mii_counter_rxeralgn;
#endif

#define MII_TX_SEQBUF
#undef MII_TX_TIMESTAMPS

enum mii_ctl {
  FRAME_DATA = 0,
  END_FRAME = 1,
} ;



void mii_init(clock clk_mii_rx , in port p_mii_rxclk , buffered in port:32 p_mii_rxd ,
              in port p_mii_rxdv , in port p_mii_rxer,
              clock clk_mii_tx , in port p_mii_txclk , buffered out port:32 p_mii_txd ,
              out port p_mii_txen ,
              clock clk_mii_ref)
{
#ifndef SIMULATION
  timer tmr;
  unsigned t;
#endif
  set_port_use_on(p_mii_rxclk);
  p_mii_rxclk :> int x;
  set_port_use_on(p_mii_rxd);
  set_port_use_on(p_mii_rxdv);
  set_port_use_on(p_mii_rxer);
  set_port_clock(p_mii_rxclk, clk_mii_ref);
  set_port_clock(p_mii_rxd, clk_mii_ref);
  set_port_clock(p_mii_rxdv, clk_mii_ref);

  set_pad_delay(p_mii_rxclk, PAD_DELAY_RECEIVE);

  set_port_strobed(p_mii_rxd);
  set_port_slave(p_mii_rxd);

  set_clock_on(clk_mii_rx);
  set_clock_src(clk_mii_rx, p_mii_rxclk);
  set_clock_ready_src(clk_mii_rx, p_mii_rxdv);
  set_port_clock(p_mii_rxd, clk_mii_rx);
  set_port_clock(p_mii_rxdv, clk_mii_rx);

  set_clock_rise_delay(clk_mii_rx, CLK_DELAY_RECEIVE);

  start_clock(clk_mii_rx);

  clearbuf(p_mii_rxd);

  set_port_use_on(p_mii_txclk);
  set_port_use_on(p_mii_txd);
  set_port_use_on(p_mii_txen);
  set_port_clock(p_mii_txclk, clk_mii_ref);
  set_port_clock(p_mii_txd, clk_mii_ref);
  set_port_clock(p_mii_txen, clk_mii_ref);

  set_pad_delay(p_mii_txclk, PAD_DELAY_TRANSMIT);

  p_mii_txd <: 0;
  p_mii_txen <: 0;
  sync(p_mii_txd);
  sync(p_mii_txen);

  set_port_strobed(p_mii_txd);
  set_port_master(p_mii_txd);
  clearbuf(p_mii_txd);

  set_port_ready_src(p_mii_txen, p_mii_txd);
  set_port_mode_ready(p_mii_txen);

  set_clock_on(clk_mii_tx);
  set_clock_src(clk_mii_tx, p_mii_txclk);
  set_port_clock(p_mii_txd, clk_mii_tx);
  set_port_clock(p_mii_txen, clk_mii_tx);

  set_clock_fall_delay(clk_mii_tx, CLK_DELAY_TRANSMIT);

  start_clock(clk_mii_tx);

  clearbuf(p_mii_txd);

#ifndef SIMULATION
  tmr :> t;
  tmr when timerafter(t + PHY_INIT_DELAY) :> t;
#endif
#ifdef MII_COUNTERS
  mii_counter_rxgood = 0;
  mii_counter_txall = 0;
  mii_counter_rxercrc = 0;
  mii_counter_rxerlen = 0;
  mii_counter_rxeralgn = 0;
#endif
}

void mii_deinit(clock clk_mii_rx , in port p_mii_rxclk , buffered in port:32 p_mii_rxd ,
                in port p_mii_rxdv , in port p_mii_rxer,
                clock clk_mii_tx , in port p_mii_txclk , buffered out port:32 p_mii_txd ,
                out port p_mii_txen )
{
#ifdef SIMULATION
#endif
  set_port_use_off(p_mii_rxd);
  set_port_use_off(p_mii_rxclk);
  set_port_use_off(p_mii_rxdv);
  set_clock_off(clk_mii_rx);
  set_port_use_off(p_mii_txd);
  set_port_use_off(p_mii_txclk);
#ifndef SIMULATION
  // Bug in plugin
  set_port_use_off(p_mii_txen);
#endif
  set_clock_off(clk_mii_tx);
  set_port_use_off(p_mii_rxer);
}

#pragma unsafe arrays
void mii_rx_pins(streaming chanend c_mii_data , buffered in port:32 p_mii_rxd , in port p_mii_rxdv , in port p_mii_rxer)
{
  const register unsigned poly = 0xEDB88320;
  timer tmr;

//  set_thread_fast_mode_on();

  p_mii_rxdv when pinseq(0) :> int lo;
  do
  {
    int success = 0;
    int length = 0;
    register unsigned crc = 0x9226F562;
    unsigned time;
    unsigned word;

    p_mii_rxdv when pinseq(1) :> int hi;
    
    p_mii_rxd when pinseq(0xD) :> int sof;
    
    tmr :> time;
    
    p_mii_rxd :> word;
    c_mii_data <: FRAME_DATA;
    c_mii_data <: word;
    length+=4;
    crc32(crc, word, poly);
    p_mii_rxd :> word;  
    c_mii_data <: FRAME_DATA;
    c_mii_data <: word;
    length+=4;
    crc32(crc, word, poly);
    
    do
      {    
        select
          {
          case p_mii_rxd :> word:
            {
              c_mii_data <: FRAME_DATA;
              c_mii_data <: word;
              length+=4;
              crc32(crc, word, poly);
              break;
            }
          case p_mii_rxdv when pinseq(0) :> int lo:
            {
              unsigned tail;
              int taillen;
              int endbytes;
              int error;
              
              taillen = endin(p_mii_rxd);
              p_mii_rxd :> tail;
              
              tail = tail >> (32 - taillen);          
              endbytes =  (taillen >> 3);
              length += endbytes;
              while (endbytes)
              {
                tail = crc8shr(crc, tail, poly);
                endbytes--;
              }
              c_mii_data <: FRAME_DATA;
              c_mii_data <: tail;
              //length -= 4;
              
              error = (taillen & 7);
              error |= (length < 30);
              error |= ~crc;

              if (error)
              {
                length=0;
                clearbuf(p_mii_rxd);      
              }

              c_mii_data <: FRAME_DATA;
              c_mii_data <: time;
              c_mii_data <: END_FRAME;
              c_mii_data <: length;
              success = 1;
            }
          break;
          }
      } while (!success);
 
  } while (1);

  
  // These will not get executed due to the while(1) loop but
  // would tidy up if we did exit
  set_thread_fast_mode_off();
}

#pragma unsafe arrays
void mii_rx_buf(streaming chanend c_mii_data, streaming chanend c_mii_client) 
{
  unsigned int buffer[MII_RX_FIFO_SIZE];
  int outIndex= 1;
  int startIndex=0;
  int inIndex= 0;
  int isEmpty = 1;
  int overFlow = 0;
  unsigned int x;

//  set_thread_fast_mode_on();

  while (1) {
#pragma ordered
    select {
    case c_mii_data :> x:
    {
      if (x != FRAME_DATA)
      {
        unsigned int nbytes;
        c_mii_data :> nbytes;
        if (overFlow || (nbytes==0)) {
          outIndex = startIndex + 1;
          overFlow = 0;
        }
        else {
          buffer[startIndex] = nbytes;
          startIndex = outIndex;
          outIndex++;
          isEmpty = 0;
        }            
      }
      else {
        c_mii_data :> x;
        buffer[outIndex] = x;
        outIndex += 1;
        outIndex &= (MII_RX_FIFO_SIZE) - 1;  // assume size is power of 2
        overFlow |= (outIndex == inIndex);
        if (overFlow) {          
#ifdef RX_BUF_OVERFLOW_TRAP
          //while (1);
#endif
          outIndex = startIndex + 1;
        }
      }
      break;
    }
    case (!isEmpty) => c_mii_client :> x:
      c_mii_client <: buffer[inIndex];
      inIndex += 1;
      inIndex &= (MII_RX_FIFO_SIZE) - 1;
      isEmpty = (inIndex == startIndex);
      break;
    }
  }
}



void mii_rx(streaming chanend c_mii_client, buffered in port:32 p_mii_rxd ,
    in port p_mii_rxdv , in port p_mii_rxer) 
{
  streaming chan c_mii_data;

  par {
    mii_rx_pins(c_mii_data, p_mii_rxd, p_mii_rxdv, p_mii_rxer);
    mii_rx_buf(c_mii_data, c_mii_client);
  }  

}

static void wait(unsigned int x) 
{
  timer tmr;
  unsigned int t;
  tmr :> t;
  tmr when timerafter(t+x) :> int _;
  return;
}

#pragma unsafe arrays
void mii_tx(streaming chanend c_mii_tx, buffered out port:32 p_mii_txd) 
{
  unsigned int buf[512];
  int bytes_left, words_left;
  
  int correctionptr, timestamp;
//  set_thread_fast_mode_on();
  while (1)
  {    
    c_mii_tx :> bytes_left;
    c_mii_tx :> correctionptr;
    c_mii_tx :> timestamp;    
    words_left = (bytes_left + 3) >> 2;
    
    while (words_left)
    {
      words_left --;
      c_mii_tx :> buf[words_left];
    }
    
    {
      register const unsigned poly = 0xEDB88320;  
      int index=0;
      unsigned int crc = 0;
      unsigned int word;
      unsigned int time;
      long s;
             
      p_mii_txd <: 0x55555555;
      p_mii_txd <: 0x55555555;
      p_mii_txd <: 0xD5555555;    
      
      word = buf[index++];
      p_mii_txd <: word;
      crc32(crc, ~word, poly);     
      bytes_left -=4;
      
      while (bytes_left > 3) {
        word = buf[index++];
        p_mii_txd <: word;
        crc32(crc, word, poly);        
        bytes_left -= 4;
      }
      
      switch (bytes_left) 
          {
          case 0:
            crc32(crc, 0, poly);
            crc = ~crc;
            p_mii_txd <: crc;    
            break;
          case 1:
            word = buf[index++];
            crc8shr(crc, word, poly);
            partout(p_mii_txd, 8, word);
            crc32(crc, 0, poly);
            crc = ~crc;
            p_mii_txd <: crc;    
            break;
          case 2:
            word = buf[index++];
            partout(p_mii_txd, 16, word);
            word = crc8shr(crc, word, poly);
            crc8shr(crc, word, poly);
            crc32(crc, 0, poly);
            crc = ~crc;
            p_mii_txd <: crc;    
            break;
          case 3:
            word = buf[index++];
            partout(p_mii_txd, 24, word);
            word = crc8shr(crc, word, poly);
            word = crc8shr(crc, word, poly);
            crc8shr(crc, word, poly);
            crc32(crc, 0, poly);
            crc = ~crc;
            p_mii_txd <: crc;    
            break;
          }
    #ifdef MII_COUNTERS
      mii_counter_txall++;
    #endif
      wait(MINIMUM_GAP_TIMER_CYCLES_100MBPS);

    }
  }
}
