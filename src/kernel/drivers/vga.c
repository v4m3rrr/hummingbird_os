#include "kernel/drivers/vga.h"
#include "kernel/io.h"

#define VGA_GRAPHICS_REG_ADDRESS_PORT (uintptr_t)0x3CE
#define VGA_GRAPHICS_REG_DATA_PORT (uintptr_t)0x3CF

#define VGA_MEMORY_MAP_INDEX (uint8_t)0x6
#define VGA_MEMORY_MAP_MASK (uint8_t)0xC
#define VGA_MEMORY_MAP_BITSHIFT (uint8_t)2

static uint8_t *VGA_MEMORY_BEGIN;
static uint8_t *VGA_MEMORY_PAST_END;

static uint8_t *VGA_POINTER;

void vga_init() {
  uint8_t resore_addr = inportb(VGA_GRAPHICS_REG_ADDRESS_PORT);
  outportb(VGA_MEMORY_MAP_INDEX, VGA_GRAPHICS_REG_ADDRESS_PORT);
  uint8_t mem_select = inportb(VGA_GRAPHICS_REG_DATA_PORT);
  outportb(resore_addr, VGA_GRAPHICS_REG_ADDRESS_PORT);

  mem_select &= VGA_MEMORY_MAP_MASK;
  mem_select <<= VGA_MEMORY_MAP_BITSHIFT;

  switch (mem_select) {
  case 0x0:
    VGA_MEMORY_BEGIN = (uint8_t *)0xA0000;
    VGA_MEMORY_PAST_END = (uint8_t *)0xC0000;
    break;
  case 0x1:
    VGA_MEMORY_BEGIN = (uint8_t *)0xA0000;
    VGA_MEMORY_PAST_END = (uint8_t *)0xB0000;
    break;
  case 0x2:
    VGA_MEMORY_BEGIN = (uint8_t *)0xB0000;
    VGA_MEMORY_PAST_END = (uint8_t *)0xB8000;
    break;
  case 0x3:
    VGA_MEMORY_BEGIN = (uint8_t *)0xB8000;
    VGA_MEMORY_PAST_END = (uint8_t *)0xC0000;
    break;
  }

  VGA_POINTER = VGA_MEMORY_BEGIN;
}

void vga_clear() {
  for (uint8_t *start = VGA_MEMORY_BEGIN; start != VGA_POINTER;) {
    *start++ = (uint8_t)' ';
    *start++ = 0x00;
  }

  VGA_POINTER = VGA_MEMORY_BEGIN;
}

void vga_putc(uint8_t c) {
  if (VGA_POINTER + 2 >= VGA_MEMORY_PAST_END) {
  }

  *VGA_POINTER++ = c;
  *VGA_POINTER++ = 0x0a;
}

void vga_write(const char *str) {
  while (*str != 0) {
    vga_putc(*str++);
  }
}
