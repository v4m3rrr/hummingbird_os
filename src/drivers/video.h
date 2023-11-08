#include <stdint.h>

#ifndef __VIDEO
#define __VIDEO

#define VIDEO_MEMORY (uint8_t*)0xB8000
extern uint8_t* VIDEO_POINTER;

void putch(uint8_t c);
void print(const char* str);

#endif