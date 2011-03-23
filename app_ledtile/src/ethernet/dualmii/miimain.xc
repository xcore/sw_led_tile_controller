// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    miimain.xc
 *
 *
 **/                                   

#include <xs1.h>
#include "print.h"
#include "mii.h"
#include "smi.h"

#ifdef SIMULATION
extern port p_mii_txcsn;
#endif

void mii_txrx(streaming chanend c_mii_client, streaming chanend c_mii_tx, 
              clock clk_mii_rx , in port p_mii_rxclk , buffered in port:32 p_mii_rxd , in port p_mii_rxdv , in port p_mii_rxer,
              clock clk_mii_tx , in port p_mii_txclk , buffered out port:32 p_mii_txd , out port p_mii_txen, clock clk_mii_ref,
              out port p_smi_mdc, port p_smi_mdio)
{
  // Init Xcore ports for mii
  mii_init(clk_mii_rx , p_mii_rxclk , p_mii_rxd , p_mii_rxdv , p_mii_rxer,
      clk_mii_tx, p_mii_txclk, p_mii_txd, p_mii_txen, clk_mii_ref);
  
  // Set phy to autodiscovery
  smi_config(1, p_smi_mdc, p_smi_mdio);
  
  // Start MII threads
  par
  {
    mii_rx(c_mii_client, p_mii_rxd, p_mii_rxdv, p_mii_rxer);
    mii_tx(c_mii_tx, p_mii_txd);
  }
  return;
}


void miimain(streaming chanend c_mii_client_0, streaming chanend c_mii_client_1, 
             streaming chanend c_mii_tx_0, streaming chanend c_mii_tx_1, 
             clock clk_mii_rx_0 , in port p_mii_rxclk_0 , buffered in port:32 p_mii_rxd_0 , in port p_mii_rxdv_0 , in port p_mii_rxer_0,
             clock clk_mii_tx_0 , in port p_mii_txclk_0 , buffered out port:32 p_mii_txd_0 , out port p_mii_txen_0 , 
             clock clk_mii_rx_1 , in port p_mii_rxclk_1 , buffered in port:32 p_mii_rxd_1 , in port p_mii_rxdv_1 , in port p_mii_rxer_1,
             clock clk_mii_tx_1 , in port p_mii_txclk_1 , buffered out port:32 p_mii_txd_1 , out port p_mii_txen_1 , 
             clock clk_mii_ref, clock clk_smi,
             out port p_smi_mdc_0, out port p_smi_mdc_1,
             port p_smi_mdio_0,    port p_smi_mdio_1, out port p_mii_resetn)
{  
  // Initialise xcore ports

  smi_init(clk_mii_ref, clk_smi, p_smi_mdc_0, p_smi_mdio_0, p_mii_resetn);
  smi_init(clk_mii_ref, clk_smi, p_smi_mdc_1, p_smi_mdio_1, p_mii_resetn);
  
  smi_reset(p_mii_resetn, p_smi_mdio_0);
  
  par
  {
    mii_txrx(c_mii_client_0, c_mii_tx_0,
             clk_mii_rx_0, p_mii_rxclk_0, p_mii_rxd_0, p_mii_rxdv_0, p_mii_rxer_0,
             clk_mii_tx_0, p_mii_txclk_0, p_mii_txd_0, p_mii_txen_0, clk_mii_ref,
             p_smi_mdc_0, p_smi_mdio_0);
    mii_txrx(c_mii_client_1, c_mii_tx_1,
             clk_mii_rx_1, p_mii_rxclk_1, p_mii_rxd_1, p_mii_rxdv_1, p_mii_rxer_1,
             clk_mii_tx_1, p_mii_txclk_1, p_mii_txd_1, p_mii_txen_1, clk_mii_ref,
             p_smi_mdc_1, p_smi_mdio_1);
  }
}
