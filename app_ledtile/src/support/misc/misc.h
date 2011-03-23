// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    misc.h
 *
 *
 **/                                   
#ifndef MISC_H_
#define MISC_H_

void chipReset(void);
void sleep(int timerticks);

#ifdef __XC__
int pollChan(chanend c);
#else
int pollChan(unsigned c);
#endif

#ifdef __XC__
int pollSChan(streaming chanend c);
#else
int pollSChan(unsigned c);
#endif

void slowdown(void);

#define CORECLOCKDIV 32


#endif /*MISC_H_*/

