// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign
 * Version: 10.4.1
 * Build:   977cb8e0d3fefc67ac350c5f294ac65919b3ebdc
 * File:    chanabs.h
 *
 *
 **/                                   
#ifndef CHANABS_H_
#define CHANABS_H_

#include <xs1.h>

#ifndef __XC__

#define chanend unsigned
#define checkct(a,b) {__asm__ __volatile__ ("chkct res[%0], %1": : "r" (a) , "r" (b));}
#define outct(a,b) {__asm__ __volatile__ ("outct res[%0], %1": : "r" (a) , "r" (b));}
#define outuchar(a,b) {__asm__ __volatile__ ("outt res[%0], %1": : "r" (a) , "r" (b));}
#define outuint(a,b) {__asm__ __volatile__ ("out res[%0], %1": : "r" (a) , "r" (b));}
#define inuint_byref(a,b) {__asm__ __volatile__ ("in %0, res[%1]": "=r" (b) : "r" (a));}
#define sync(a) {__asm__ __volatile__ ("syncr res[%0]": : "r" (a));}

static inline unsigned getchanend(unsigned otherside) {
  unsigned cend;
  __asm__ __volatile__ ("getr %0, 2"
                       : "=r" (cend));
  __asm__ __volatile__ ("setd res[%0], %1"
                       : : "r" (cend), "r" (otherside) );
  return cend;
}


static inline unsigned gettime() {
  unsigned tmr, val;
  __asm__ __volatile__ ("getr %0, 1"
                         : "=r" (tmr));
  __asm__ __volatile__ ("in %0, res[%1]"
                         : "=r" (val) :"r" (tmr));
  __asm__ __volatile__ ("freer res[%0]"
                         : : "r" (tmr));
  return val;
}

static inline void freechanend(unsigned cend) {
__asm__ __volatile__ ("freer res[%0]"
                       : /* no output */
                       : "r" (cend));
}

static inline int inuint(unsigned a)
{
  unsigned val;
  inuint_byref(a,val);
  return val;
}

static inline void out(unsigned a, unsigned b)
{
  outct(a, XS1_CT_END);
  checkct(a, XS1_CT_END);
  outuint(a, b);
  outct(a, XS1_CT_END);
  checkct(a, XS1_CT_END);
}

static inline int in(unsigned a)
{
  int retval;
  checkct(a, XS1_CT_END);
  outct(a, XS1_CT_END);
  retval = inuint(a);
  checkct(a, XS1_CT_END);
  outct(a, XS1_CT_END);
  return retval;
}

static inline unsigned getprocnum()
{
  unsigned c = getchanend(0x2);
  freechanend(0x2);
  return (c >> 16) & 0xFF;
}

#define outp(a,b) {__asm__ __volatile__ ("out res[%0], %1": : "r" (a) , "r" (b));}
#define outpw(a,b,c) {__asm__ __volatile__ ("outpw res[%0], %1, %2": : "r" (a) , "r" (b), "i" (c));}
#define set_port_clock_output(a) {__asm__ __volatile__ ("setc res[%0], 0x500f": : "r" (a));}
#define setpt(a,b) {__asm__ __volatile__ ("setpt res[%0], %1": : "r" (a) , "r" (b));}

static inline unsigned getts(unsigned a)
{
  unsigned retval;
  __asm__ __volatile__ ("getts %0, res[%1]": "=r" (retval) : "r" (a));
  return retval;
}

#endif

#endif /*CHANABS_H_*/
