#include "kernel/drivers/video.h"

static uint8_t *VIDEO_POINTER = VIDEO_MEMORY;

void clear() {
  for (uint8_t *start = VIDEO_MEMORY; start != VIDEO_POINTER;) {
    *start++ = (uint8_t)' ';
    *start++ = 0x00;
  }

  VIDEO_POINTER = VIDEO_MEMORY;
}

void putch(uint8_t c) {
  *VIDEO_POINTER++ = c;
  *VIDEO_POINTER++ = 0x0a;
}

void print(const char *str) {
  while (*str != 0) {
    putch(*str++);
  }
}
