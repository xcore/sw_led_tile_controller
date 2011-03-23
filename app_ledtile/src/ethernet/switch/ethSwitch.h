// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    ethSwitch.h
 *
 *
 **/                                   

#ifndef __ETHPHY_H__
#define __ETHPHY_H__

#include "ethPkt.h"

// ethPhyRx
// Receive packet over channel and place in s_packet structure

#ifdef __XC__
int ethPhyRx(streaming chanend c,   s_packet &pkt,  unsigned numbytes);
#else
int ethPhyRx(unsigned c,   s_packet *pkt,  unsigned numbytes);
#endif

// ethPhyTx
// Send packet over channel from s_packet structure
#ifdef __XC__
void ethPhyTx(chanend cTx, s_packet &pkt, int &tstamp);
#else
void ethPhyTx(unsigned c,  s_packet *pkt,  int *tstamp);
#endif

// ethSwitch
// Layer 2 ethernet switch framework
// Supports two external interfaces, and one local
#ifdef __XC__
void ethSwitch(streaming chanend cRx0, streaming chanend cRx1, chanend cRx2,
    streaming chanend cTx0, streaming chanend cTx1, chanend cTx2, chanend cWdog);
#else
void ethSwitch(unsigned cRx0, unsigned cRx1, unsigned cRx2,
                 unsigned cTx0, unsigned cTx1, unsigned cTx2, unsigned cWdog);
#endif

#endif /*__ETHPHY_H__*/

#ifdef __XC__
void ethernetSwitch3Port(clock clk_mii_rx_0 , in port p_mii_rxclk_0 , buffered in port:32 p_mii_rxd_0 , in port p_mii_rxdv_0 , in port p_mii_rxer_0,
             clock clk_mii_tx_0 , in port p_mii_txclk_0 , buffered out port:32 p_mii_txd_0 , out port p_mii_txen_0 ,
             clock clk_mii_rx_1 , in port p_mii_rxclk_1 , buffered in port:32 p_mii_rxd_1 , in port p_mii_rxdv_1 , in port p_mii_rxer_1,
             clock clk_mii_tx_1 , in port p_mii_txclk_1 , buffered out port:32 p_mii_txd_1 , out port p_mii_txen_1 ,
             clock clk_mii_ref, clock clk_smi, out port p_smi_mdc_0, out port p_smi_mdc_1,
             port p_smi_mdio_0,    port p_smi_mdio_1, out port p_mii_resetn,
             chanend cRx, chanend cTx, chanend cWdog);
#endif


