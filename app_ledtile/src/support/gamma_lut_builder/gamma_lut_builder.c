/*
 * gamma_lut_builder.c
 *
 *  Created on: 13.09.2011
 *      Author: marcus
 */
#include <xs1.h>
#include <math.h>
#include "gamma_lut_builder.h"

void buildGammaLUT(unsigned short* gammaBuffer) {
	for (int i=0; i< 256; i++) {
		gammaBuffer[i] = (unsigned short) (pow((double)i / 255.0, 2.2) * 255.0*255.0);
	}
}
