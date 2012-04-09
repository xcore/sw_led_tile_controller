/*
 * ledbuffercalculations.h
 *
 *  Created on: 13.09.2011
 *      Author: marcus
 */

#ifndef LEDBUFFERCALCULATIONS_H_
#define LEDBUFFERCALCULATIONS_H_

//the offset by embedding different colors in the buffer
#define LED_BUFFER_COLORS 3

// Gives us FRAME_HEIGHT and FRAME_WIDTH
#define LED_BUFFER_ROW_SIZE (FRAME_WIDTH*LED_BUFFER_COLORS)
#define LED_BUFFER_FRAME_SIZE     (LED_BUFFER_COLORS*FRAME_HEIGHT * FRAME_WIDTH)
#define LED_BUFFER_BUFFER_SIZE    (2 * LED_BUFFER_FRAME_SIZE)

//example how to calulate a position
//the index, not pointing to the byte but the virtual index position over allcolors
#define LED_BUFFER_INDEX(x,y) (((y * FRAME_WIDTH)+x))
//the virtual index in the led buffer
#define LED_BUFFER_BUFFER_BYTE_POSITION(index) (index*LED_BUFFER_COLORS)
//the byte position
#define LED_BUFFER_POSITION(x,y) (LED_BUFFER_BUFFER_BYTE_POSITION(LED_BUFFER_INDEX(x,y)))
//beginning of a row
#define LED_BUFFER_ROW(row) (row*LED_BUFFER_ROW_SIZE)



#endif /* LEDBUFFERCALCULATIONS_H_ */
