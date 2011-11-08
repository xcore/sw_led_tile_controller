/*
 * gamma_lut_builder.h
 *
 *  Created on: 13.09.2011
 *      Author: marcus
 */

#ifndef GAMMA_LUT_BUILDER_H_
#define GAMMA_LUT_BUILDER_H_

#ifndef __XC__
void buildGammaLUT(unsigned short* gammaBuffer);
#else
void buildGammaLUT(unsigned short gammaBuffer[256]);
#endif

#endif /* GAMMA_LUT_BUILDER_H_ */
