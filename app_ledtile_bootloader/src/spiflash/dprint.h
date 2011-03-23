// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign_Bootloader
 * Version: 9.10.0
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
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
