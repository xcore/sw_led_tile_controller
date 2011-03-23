// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethernet_server_def.h
 *
 *
 **/                                   
 
#ifndef _ETHERNET_SERVER_DEF_H_
#define _ETHERNET_SERVER_DEF_H_ 1

// common definations.

#define NUM_LINK_LAYER_IF   (4)      // Number of link layers to support

// Max bytes in Ethernet frame payload
#define MAX_ETHERNET_FRAME_PAYLOAD_SIZE			(1500)

// Total number of MII Tx Frame buffers.
#define MII_TX_NUM_FRAMES_IN_BUF				      (3)

// Total number of MII Rx Frame buffers.
// NOTE: Due to implementation this MUST be min. of 2.
#define MII_RX_NUM_FRAMES_IN_BUF				      (4)


/*****************************************************************************
 *
 *  DO NOT CHANGE THESE.
 *
 *****************************************************************************/

// Ethernet frame size including MAC address(s) and type.
// ****** THIS NEEDS TO BE WORD ALIGNED *********
#define MII_FRAME_SIZE	     (MAX_ETHERNET_FRAME_PAYLOAD_SIZE + 20)	

#if (MII_FRAME_SIZE / 4 * 4) != MII_FRAME_SIZE
#error "MII_FRAME_SIZE must be word aligned"
#endif

// Total number of bytes in MII Tx Frame buffer
#define MII_TX_BUF_SIZE		 (MII_FRAME_SIZE * MII_TX_NUM_FRAMES_IN_BUF)

// Total number of bytes in MII Rx Frame buffer
#define MII_RX_BUF_SIZE		 (MII_FRAME_SIZE * MII_RX_NUM_FRAMES_IN_BUF)


// Protocol defiantions.
#define ETHERNET_TX_REQ           (0x80000000)
#define ETHERNET_TX_REQ_TIMED     (0x80000001)
#define ETHERNET_GET_MAC_ADRS     (0x80000002)

#define ETHERNET_START_DATA	  (0xA5DA1A5A)	// Marker for start of data.

#define ETHERNET_RX_FRAME_REQ	  (0x80000010)	// Request for ethernet 
                                                // complete frame, 
                                                // including src/dest
#define ETHERNET_RX_TYPE_PAYLOAD_REQ   (0x80000011) // Request for ethernet
                                                    // type and payload only 
                                                    // (i.e. strip MAC 
                                                    //  address(s))
#define ETHERNET_RX_OVERFLOW_CNT_REQ   (0x80000012)	
#define ETHERNET_RX_OVERFLOW_CLEAR_REQ (0x80000013)
#define ETHERNET_RX_FILTER_SET         (0x80000014)
#define ETHERNET_RX_DROP_PACKETS_SET   (0x80000015)


#define ETHERNET_REQ_ACK	       (0x80000020)	// Acknowledged
#define ETHERNET_REQ_NACK	       (0x80000021)	// Negative ack.


#endif
