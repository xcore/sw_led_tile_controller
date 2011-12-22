// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>


#define MAX_ETHERNET_PACKET_SIZE (1518)

//this defines the initial IP address, split into 4 number - in the end it will be INITIAL_IP_0.INITIAL_IP_1.INITIAL_IP_2.INITIAL_IP_3
#define INITIAL_IP_0 192
#define INITIAL_IP_1 168
#define INITIAL_IP_2 0
#define INITIAL_IP_3 254

#define NUM_MII_RX_BUF 5
#define NUM_MII_TX_BUF 5

#define MAX_ETHERNET_CLIENTS   (4)    

#define NUM_ETHERNET_PORTS (2)

//the chattyness of the helper functions
#define ETHERNET_DEBUG_OUTPUT

//a simle switch to turn of the mac packet filtering for debug purpose
#define MAC_DO_NOT_FILTER
