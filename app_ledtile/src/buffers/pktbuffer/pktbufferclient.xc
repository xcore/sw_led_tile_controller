// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    pktbufferclient.xc
 *
 *
 **/                                   

/*
 * send packets to the command buffer
 *
 * Channel
 * c - the packet sink channel of the packet buffer
 *
 * len - the length of the data package
 * data - the data package itself
 *
 * TODO this can fail if the FIFO is full - it should be returned
 * TODO the package buffer handles the length as int - this may clash
 */
void sendPktData(chanend c, unsigned len, unsigned data[])
{
  int response;
  master
  {
	//send the package length
    c <: len;
    //see if the buffer can handle the data
    c :> response;
    //if the buffer is ready
    if (!response)
    {
      //send the data
      for (int i=0; i<len; i++)
      {
        c <: data[i];
      }
    }
  }  
}
