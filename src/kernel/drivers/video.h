#ifndef KERNEL_DRIVERS_VIDEO_H
#define KERNEL_DRIVERS_VIDEO_H

#include <stdint.h>

#define VIDEO_MEMORY (uint8_t *)0xB8000

void clear();
void putch(uint8_t c);
void print(const char *str);

#endif // KERNEL_DRIVERS_VIDEO_H
