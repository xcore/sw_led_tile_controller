// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    mii.h
 *
 *
 **/                                   

#ifndef _mii_h_
#define _mii_h_

#include "led.h"
#include "ethernet_server_def.h"

/* Configuration options */



/**
 * 
 * Frame data structure for use within MII layer
 */
typedef struct mii_frame_t 
{
  unsigned int nbytes;
  unsigned int timestamp;
  unsigned int data[MII_FRAME_SIZE/4]; 
} mii_frame_t;

/*
 * Initialises MII I/O
 *
 * Call this function prior to receive and transmit functions
 *
 * Note: the mii_init and mii_deinit functions can be called in
 * arbitrary order arbitrary many times - this allows initialisation
 * and deinitialisation without reset
 */
void mii_init(clock clk_mii_rx , in port p_mii_rxclk , buffered in port:32 p_mii_rxd ,
              in port p_mii_rxdv , in port p_mii_rxer,
              clock clk_mii_tx , in port p_mii_txclk , buffered out port:32 p_mii_txd ,
              out port p_mii_txen,
              clock clk_mii_ref);

/*
 * Clean up MII I/O
 */
void mii_deinit(clock clk_mii_rx , in port p_mii_rxclk , buffered in port:32 p_mii_rxd ,
                in port p_mii_rxdv , in port p_mii_rxer,
                clock clk_mii_tx , in port p_mii_txclk , buffered out port:32 p_mii_txd ,
                out port p_mii_txen);

/* Receive a raw Ethernet frame
   Returns time of SFD symbol (end of preamble)
   Protocol: c <- 0
             c -> nbytes
             c <- 0
             c -> word 1
             c <- 0
             c -> word 2
             ...
             c <- 0
             c -> crc
             c <- 0
             c -> timestamp
             ...
   NOTE nbytes excludes CRC and SFD
   NOTE This function cannot be blocked out by calling thread. There
        is an internal fifo buffer. If this overflows, packets will 
        be discarded.
   NOTE Other thread must use the start/stop streaming master
        functions to delimit the streaming I/O */
void mii_rx(streaming chanend ch_client, buffered in port:32 p_mii_rxd ,
            in port p_mii_rxdv , in port p_mii_rxer);


/* Transmit a raw Ethernet frame
   Returns time of SFD symbol (end of preamble)
   Protocol:

   Unbuffered with timestamps:

             c_mii_tx <- frame1.nbytes (arbitrary)
             c_mii_tx <- frame1.word1
             c_mii_tx <- frame1.word2
             ...
             c_mii_tx -> timestamp
             ...
             c_mii_tx <- frame2.nbytes (arbitrary)
             c_mii_tx <- frame2.word1
             c_mii_tx <- frame2.word2
             ...
             c_mii_tx -> timestamp
             ...            

   Buffered with timestamps

   c_mii_tx <- timestamp id1            ...
   c_mii_tx <- frame1.nbytes            ...
   c_mii_tx <- frame1.word1
   c_mii_tx <- frame1.word2
   ...

   c_mii_tx <- timestamp id1
   c_mii_tx frame2.nbytes               c_tx_ts -> timestamp id1
   c_mii_tx frame2.word1                c_tx_ts -> timestamp
   c_mii_tx frame2.word2 
   ...
   ...                                  c_tx_ts -> timestamp id2
                                        c_tx_ts -> timestamp 

   NOTE nbytes excludes CRC and SFD
   NOTE Other thread must use the start/stop streaming master
        functions to delimit the streaming I/O */
void mii_tx(streaming chanend c_mii_tx, buffered out port:32 p_mii_txd);

/*
 * Internal FIFO buffer sizes.
 *
 * These sizes must be powers of 2 for efficient implementation.
 *
 */ 
#define MII_RX_LOGFIFO_SIZE 11
#define MII_RX_FIFO_SIZE (1<<MII_RX_LOGFIFO_SIZE)

#define MII_TX_LOGFIFO_SIZE 9
#define MII_TX_FIFO_SIZE (1<<MII_TX_LOGFIFO_SIZE)





#endif
