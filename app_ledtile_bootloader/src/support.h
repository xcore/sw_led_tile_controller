// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * Module:  LedRefDesign_Bootloader
 * Version: 9.10.0
 * Build:   4061a1a31070a4a2edc04cae089d434475f9cb06
 * File:    support.h
 *
 *
 **/                                   
void store(unsigned address, unsigned data);
void outw(unsigned cend, unsigned data);
void outCT(unsigned cend, unsigned data);
unsigned getChanEnd(unsigned dest);
void freeChanEnd(unsigned cend);
void jump(unsigned dest);

