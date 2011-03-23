// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    miimain.h
 *
 *
 **/                                   

#ifndef MIIMAIN_H_
#define MIIMAIN_H_


void miimain(streaming chanend cMiiRx0, streaming chanend cMiiRx1, 
             streaming chanend cMiiTx0, streaming chanend cMiiTx1, 
             clock clk_mii_rx_0 , in port p_mii_rxclk_0 , buffered in port:32 p_mii_rxd_0 , in port p_mii_rxdv_0 , in port p_mii_rxer_0,
             clock clk_mii_tx_0 , in port p_mii_txclk_0 , buffered out port:32 p_mii_txd_0 , out port p_mii_txen_0 ,
             clock clk_mii_rx_1 , in port p_mii_rxclk_1 , buffered in port:32 p_mii_rxd_1 , in port p_mii_rxdv_1 , in port p_mii_rxer_1,
             clock clk_mii_tx_1 , in port p_mii_txclk_1 , buffered out port:32 p_mii_txd_1 , out port p_mii_txen_1 ,
             clock clk_mii_ref, clock clk_smi, out port p_smi_mdc_0, out port p_smi_mdc_1,
             port p_smi_mdio_0,    port p_smi_mdio_1, out port p_mii_resetn);


#endif /*MIIMAIN_H_*/
