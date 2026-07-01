#ifndef KERNEL_IO_IO_H
#define KERNEL_IO_IO_H

#include <stdint.h>

static inline uint8_t inportb(uintptr_t port) {
  uint8_t read;
  __asm__ volatile("inb %%dx,%%al" : "=a"(read) : "d"(port) :);
  return read;
}

static inline void outportb(uint8_t value, uintptr_t port) {
  __asm__ volatile("outb %%al,%%dx" ::"a"(value), "d"(port) :);
}

#endif // KERNEL_IO_IO_H
