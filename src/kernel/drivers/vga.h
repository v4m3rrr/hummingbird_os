#ifndef KERNEL_DRIVERS_VGA_H
#define KERNEL_DRIVERS_VGA_H

#include <stdint.h>

void vga_init();

void vga_clear();
// void vga_set_ink(uint8_t color);
void vga_putc(uint8_t c);
void vga_write(const char *str);

#endif // KERNEL_DRIVERS_VGA_H
