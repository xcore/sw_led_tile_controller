// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    dprint.h
 *
 *
 **/                                   
//#define VERBOSE


#ifdef VERBOSE
#include <print.h>
#define   dbgprintstr(a) printstr(a)
#define   dbgprinthex(a) printhex(a)
#define   dbgprinthexln(a) printhexln(a)
#define   dbgprintint(a) printint(a)
#define   dbgprintintln(a) printintln(a)
#else
#define   dbgprinthex(a)
#define   dbgprinthexln(a)
#define   dbgprintstr(a)
#define   dbgprintint(a)
#define   dbgprintintln(a)
#endif
