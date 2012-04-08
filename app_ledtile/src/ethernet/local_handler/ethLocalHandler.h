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

void startEthServer(chanend c_local_tx, chanend c_local_rx,
		chanend led_buffer_chan, chanend led_cmd_chan,
		clock clk_smi, out port ?p_mii_resetn,
		smi_interface_t &smi0, smi_interface_t &smi1, mii_interface_t &mii0,
		mii_interface_t &mii1, struct otp_ports& otp_ports);


#endif /*__ETHPHY_H__*/



