// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    smi.h
 *
 *
 **/                                   

#ifndef _smi_h_
#define _smi_h_

/* Initilisation of SMI ports
   Must be called first */
void smi_init(clock clk_mii_ref, clock clk_smi, out port p_smi_mdc, port p_smi_mdio, out port p_mii_resetn);

/* Phy configuration
   If eth100 is non-zero, 100BaseT is advertised to the link peer
   Full duplex is always advertised
	 Returns 0 if no error and link established
	 Returns 1 on ID read error or config register readback error
	 Returns 2 if no error but link times out (3 sec) */
int smi_config(int eth100, out port p_smi_mdc, port p_smi_mdio);

// Reset the MII PHY
void smi_reset( out port p_mii_resetn, port p_smi_mdio);

/* Cleanup of SMI ports */
void smi_deinit(clock clk_mii_ref, clock clk_smi, out port p_smi_mdc, port p_smi_mdio, out port p_mii_resetn);

/* Enable/disable phy loopback */
void smi_loopback(int enable, out port p_smi_mdc, port p_smi_mdio);


// Return 1 if link established
int smi_checklink(out port p_smi_mdc, port p_smi_mdio);

/* Direct SMI register access (for advanced use) */
int smi_rd( int reg,  out port p_smi_mdc, port p_smi_mdio);
void smi_wr( int reg, int val, out port p_smi_mdc, port p_smi_mdio);


#endif
