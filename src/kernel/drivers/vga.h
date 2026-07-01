#ifndef KERNEL_DRIVERS_VGA_H
#define KERNEL_DRIVERS_VGA_H

#include <stdint.h>

void vga_init();

// 320x200 linear 256 color
void vga_load_grahpics_mode();
void vga_read_memory_map(uint32_t *out_base, uint32_t *out_limit);

void vga_clear();
// void vga_set_ink(uint8_t color);
void vga_putc(uint8_t c);
void vga_write(const char *str);
void vga_set_color_palette(uint8_t r, uint8_t g, uint8_t b, uint32_t index);

uint32_t vga_get_screen_width();
uint32_t vga_get_screen_height();

#endif // KERNEL_DRIVERS_VGA_H
