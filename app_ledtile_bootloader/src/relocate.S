// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign_Bootloader
 * Version: 9.10.0
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
 * File:    relocate.S
 *
 *
 **/                                   
#include <xs1.h>

 .text
 
 
 #ifdef RELOCATE
 
 .globl main
 main:
   // Initial DP
   ldap r11,   _dp
   set  dp,    r11
   
   ldw   r0,   dp[ramBase]
   ldw   r1,   dp[stage2Dest]
   ldw   r11,  dp[stage2Size]
copyWordUp:
   sub   r11,  r11,    1
   ldw   r3,   r0[r11]
   stw   r3,   r1[r11]
   bt    r11,  copyWordUp
   
// Adjust dp and sp
   sub   r1,   r1,     r0
   ldap  r11, _dp
   add   r11, r11, r1
   set   dp,  r11
   ldap  r11, _cp
   add   r11, r11, r1
   set   cp,  r11
   ldap  r11, _sp
   add   r11, r11, r1
   set   sp,  r11
   


// Jump to high code
   ldap  r11, realmain
   add   r11, r11, r1
   bau   r11
   
.align 4
.space 600
_sp:
.space 4   
#endif

 
 .globl store
 .globl store.nstackwords
.linkset store.nstackwords, 0
 store:
   stw r1, r0[0]
   retsp 0
   
 .globl outw
 .globl outw.nstackwords
.linkset outw.nstackwords, 0
 outw:
   out res[r0], r1
   retsp 0
   
 .globl outCT
 .globl outCT.nstackwords
.linkset outCT.nstackwords, 0
 outCT:
   outct res[r0], r1
   retsp 0
   
.globl getChanEnd
.globl getChanEnd.nstackwords
.linkset getChanEnd.nstackwords, 0
getChanEnd:
  getr r1, 2
  setd res[r1], r0
  mov  r0, r1
  retsp 0
  
.globl freeChanEnd
.globl freeChanEnd.nstackwords
.linkset freeChanEnd.nstackwords, 0
freeChanEnd:
  freer res[r0]
  retsp 0
  
.globl jump
.globl jump.nstackwords
.linkset jump.nstackwords, 0
jump:
  bau   r0
  retsp 0
