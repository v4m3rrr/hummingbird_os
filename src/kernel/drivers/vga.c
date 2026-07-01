#include "kernel/drivers/vga.h"
#include "kernel/drivers/vga_internal.h"

#include "kernel/io.h"

// I think only OS modifies this memory but the be sure i make it volatile
static volatile uint8_t *VGA_MEMORY_BEGIN = (uint8_t *)0xB8000;
static volatile uint8_t *VGA_POINTER;

/*
 * API
 */

void vga_init() {
  // Makes sure that VGA is in color mode
  // which is importat for address of crtc regs
  outportb(0x63, 0x3C2);

  vga_init_crtc_and_input1_regs();
  vga_load_grahpics_mode();
  VGA_POINTER = VGA_MEMORY_BEGIN;

  uint32_t base, limit;
  vga_read_memory_map(&base, &limit);
}

void vga_read_memory_map(uint32_t *out_base, uint32_t *out_limit) {
  uint8_t mem_select = vga_gc_read(VGA_GC_MISCELLANEOUS_INDEX);

  mem_select >>= VGA_GC_MEMORY_MAP_BITSHIFT;
  mem_select &= (uint8_t)0b11; // cause it is two bit value

  switch (mem_select) {
  case 0x0:
    *out_base = 0xA0000;
    *out_limit = 0xBFFFF;
    break;
  case 0x1:
    *out_base = 0xA0000;
    *out_limit = 0xAFFFF;
    break;
  case 0x2:
    *out_base = 0xB0000;
    *out_limit = 0xB7FFF;
    break;
  case 0x3:
    *out_base = 0xB8000;
    *out_limit = 0xBFFFF;
    break;
  }
}

void vga_clear() {
  for (volatile uint8_t *start = VGA_MEMORY_BEGIN; start != VGA_POINTER;) {
    *start++ = (uint8_t)' ';
    *start++ = 0x00;
  }

  VGA_POINTER = VGA_MEMORY_BEGIN;
}

void vga_putc(uint8_t c) {

  *VGA_POINTER++ = c;
  *VGA_POINTER++ = 0x0a;
}

void vga_write(const char *str) {
  while (*str != 0) {
    vga_putc(*str++);
  }
}

void vga_load_grahpics_mode() {
  VGA_SCREEN_WIDTH = 320;
  VGA_SCREEN_HEIGHT = 200;
  while (inportb(VGA_INPUT1_STATUS_REG) & 0x08)
    ; // wait for retrace to END
  while (!(inportb(VGA_INPUT1_STATUS_REG) & 0x08))
    ; // wait for retrace to BEG

  vga_disable_display();
  vga_unlock_CTRC_regs();

  // 320x200 256colors
  vga_attr_write(VGA_ATTR_MODE_CONTROL_INDEX, 0x41);
  vga_attr_write(VGA_ATTR_OVERSCAN_COLOR_INDEX, 0x0);
  vga_attr_write(VGA_ATTR_COLOR_PLANE_ENABLE_INDEX, 0x0F);
  vga_attr_write(VGA_ATTR_HORIZONTAL_PANNING_INDEX, 0x0);
  vga_attr_write(VGA_ATTR_COLOR_SELECT_INDEX, 0x0);

  // External reg
  outportb(0x63, 0x3C2);

  // Must perserve display disabled
  uint8_t display_disable_bit =
      1 << VGA_SEQ_CLOCKING_MODE_SCREEN_DISABLE_BITSHIFT;
  vga_seq_write(VGA_SEQ_CLOCKING_MODE_INDEX, 0x1 | display_disable_bit);
  vga_seq_write(VGA_SEQ_MAP_MASK_INDEX, 0x0F);
  vga_seq_write(VGA_SEQ_CHARACTER_MAP_INDEX, 0x0);
  vga_seq_write(VGA_SEQ_MEMORY_MODE_INDEX, 0x0E);

  vga_gc_write(VGA_GC_MODE_INDEX, 0x40);
  vga_gc_write(VGA_GC_MISCELLANEOUS_INDEX, 0x5);

  vga_crtc_write(VGA_CRTC_HORIZONTAL_TOTAL_INDEX, 0x5F);
  vga_crtc_write(VGA_CRTC_HORIZONTAL_DISP_END_INDEX, 0x4F);
  vga_crtc_write(VGA_CRTC_HORIZONTAL_BLANK_START_INDEX, 0x50);
  vga_crtc_write(VGA_CRTC_HORIZONTAL_BLANK_END_INDEX, 0x82);
  vga_crtc_write(VGA_CRTC_HORIZONTAL_RETRACE_START_INDEX, 0x54);
  vga_crtc_write(VGA_CRTC_HORIZONTAL_RETRACE_END_INDEX, 0x80);
  vga_crtc_write(VGA_CRTC_VERTICAL_TOTAL_INDEX, 0xBF);
  vga_crtc_write(VGA_CRTC_OVERFLOW_INDEX, 0x1F);
  vga_crtc_write(VGA_CRTC_PRESET_ROW_SCAN_INDEX, 0x0);
  vga_crtc_write(VGA_CRTC_MAXIMUM_SCAN_LINE_INDEX, 0x41);
  vga_crtc_write(VGA_CRTC_VERTICAL_RETRACE_START_INDEX, 0x9C);

  // This write changes
  uint8_t protect_crtc_bit =
      0x1 << VGA_CRTC_VERTICAL_RETRACE_END_PROTECT_REG_BITSHIT;
  vga_crtc_write(VGA_CRTC_VERTICAL_RETRACE_END_INDEX, 0x0E | protect_crtc_bit);
  vga_crtc_write(VGA_CRTC_VERTICAL_DISPLAY_ENABLE_END_INDEX, 0x8F);
  vga_crtc_write(VGA_CRTC_LOGICAL_WIDTH_INDEX, 0x28);
  vga_crtc_write(VGA_CRTC_UNDERLINE_LOC_INDEX, 0x40);
  vga_crtc_write(VGA_CRTC_VERTICAL_BLANK_START_INDEX, 0x96);
  vga_crtc_write(VGA_CRTC_VERTICAL_BLANK_END_INDEX, 0xB9);
  vga_crtc_write(VGA_CRTC_MODE_CONTROL_INDEX, 0xA3);

  uint8_t *vram2 = (uint8_t *)0xA0000;
  for (int i = 0; i < 64000; i++) {
    vram2[i] = 0x00;
  }

  uint16_t blank = (0x00 << 12) | (0x00 << 8) | ' ';

  for (int i = 0; i < 80 * 25; i++) {
    VGA_MEMORY_BEGIN[i] = blank;
  }

  vga_lock_CTRC_regs();
  vga_enable_display();
}

void vga_set_color_palette(uint8_t r, uint8_t g, uint8_t b, uint32_t index) {
  outportb(index, 0x3C8);
  outportb(r >> 2, 0x3C9);
  outportb(g >> 2, 0x3C9);
  outportb(b >> 2, 0x3C9);
}

/*
 * Settings funcitons
 */

static void vga_enable_display() {
  vga_seq_clear(VGA_SEQ_CLOCKING_MODE_INDEX,
                0x1 << VGA_SEQ_CLOCKING_MODE_SCREEN_DISABLE_BITSHIFT);
}

static void vga_disable_display() {
  vga_seq_set(VGA_SEQ_CLOCKING_MODE_INDEX,
              0x1 << VGA_SEQ_CLOCKING_MODE_SCREEN_DISABLE_BITSHIFT);
}

static void vga_lock_CTRC_regs() {
  vga_crtc_set(VGA_CRTC_VERTICAL_RETRACE_END_INDEX,
               0x1 << VGA_CRTC_VERTICAL_RETRACE_END_PROTECT_REG_BITSHIT);
}

static void vga_unlock_CTRC_regs() {
  vga_crtc_clear(VGA_CRTC_VERTICAL_RETRACE_END_INDEX,
                 0x1 << VGA_CRTC_VERTICAL_RETRACE_END_PROTECT_REG_BITSHIT);
}

static void vga_init_crtc_and_input1_regs() {
  uint8_t crt_address_bit = inportb(0x03CC) & 0x1;

  if (crt_address_bit) {
    // If bit set
    VGA_CRTC_ADDRESS_REG_PORT = 0x03D4;
    VGA_CRTC_DATA_REG_PORT = 0x03D5;
    VGA_INPUT1_STATUS_REG = 0x03DA;
  } else {
    // If bit clear
    VGA_CRTC_ADDRESS_REG_PORT = 0x03B4;
    VGA_CRTC_DATA_REG_PORT = 0x03B5;
    VGA_INPUT1_STATUS_REG = 0x03BA;
  }
}

uint32_t vga_get_screen_width() { return VGA_SCREEN_WIDTH; }

uint32_t vga_get_screen_height() { return VGA_SCREEN_HEIGHT; }

/*
 * HELPERS FUNCTIONS
 */

static uint8_t vga_read_reg(uintptr_t address_port, uintptr_t data_port,
                            uint8_t index) {
  uint8_t resore_addr = inportb(address_port);
  outportb(index, address_port);
  uint8_t value = inportb(data_port);
  outportb(resore_addr, address_port);

  return value;
}

static void vga_write_reg(uintptr_t address_port, uintptr_t data_port,
                          uint8_t index, uint8_t value) {
  uint8_t resore_addr = inportb(address_port);
  outportb(index, address_port);
  outportb(value, data_port);
  outportb(resore_addr, address_port);
}

static void vga_set_reg(uintptr_t address_port, uintptr_t data_port,
                        uint8_t index, uint8_t bits) {
  uint8_t resore_addr = inportb(address_port);
  outportb(index, address_port);
  uint8_t value = inportb(data_port);
  value |= bits;
  outportb(value, data_port);
  outportb(resore_addr, address_port);
}

static void vga_clear_reg(uintptr_t address_port, uintptr_t data_port,
                          uint8_t index, uint8_t bits) {
  uint8_t resore_addr = inportb(address_port);
  outportb(index, address_port);
  uint8_t value = inportb(data_port);
  value &= ~bits;
  outportb(value, data_port);
  outportb(resore_addr, address_port);
}

static void vga_gc_write(uint8_t index, uint8_t value) {
  vga_write_reg(VGA_GRAPHICS_ADDRESS_REG_PORT, VGA_GRAPHICS_DATA_REG_PORT,
                index, value);
}

static void vga_gc_set(uint8_t index, uint8_t bits) {
  vga_set_reg(VGA_GRAPHICS_ADDRESS_REG_PORT, VGA_GRAPHICS_DATA_REG_PORT, index,
              bits);
}

static void vga_gc_clear(uint8_t index, uint8_t bits) {
  vga_clear_reg(VGA_GRAPHICS_ADDRESS_REG_PORT, VGA_GRAPHICS_DATA_REG_PORT,
                index, bits);
}

static uint8_t vga_gc_read(uint8_t index) {
  return vga_read_reg(VGA_GRAPHICS_ADDRESS_REG_PORT, VGA_GRAPHICS_DATA_REG_PORT,
                      index);
}

static void vga_seq_write(uint8_t index, uint8_t value) {
  vga_write_reg(VGA_SEQUENCER_ADDRESS_REG_PORT, VGA_SEQUENCER_DATA_REG_PORT,
                index, value);
}

static void vga_seq_set(uint8_t index, uint8_t bits) {
  vga_set_reg(VGA_SEQUENCER_ADDRESS_REG_PORT, VGA_SEQUENCER_DATA_REG_PORT,
              index, bits);
}

static void vga_seq_clear(uint8_t index, uint8_t bits) {
  vga_clear_reg(VGA_SEQUENCER_ADDRESS_REG_PORT, VGA_SEQUENCER_DATA_REG_PORT,
                index, bits);
}

static uint8_t vga_seq_read(uint8_t index) {
  return vga_read_reg(VGA_SEQUENCER_ADDRESS_REG_PORT,
                      VGA_SEQUENCER_DATA_REG_PORT, index);
}

static void vga_crtc_write(uint8_t index, uint8_t value) {
  vga_write_reg(VGA_CRTC_ADDRESS_REG_PORT, VGA_CRTC_DATA_REG_PORT, index,
                value);
}

static void vga_crtc_set(uint8_t index, uint8_t bits) {
  vga_set_reg(VGA_CRTC_ADDRESS_REG_PORT, VGA_CRTC_DATA_REG_PORT, index, bits);
}

static void vga_crtc_clear(uint8_t index, uint8_t bits) {
  vga_clear_reg(VGA_CRTC_ADDRESS_REG_PORT, VGA_CRTC_DATA_REG_PORT, index, bits);
}

static uint8_t vga_crtc_read(uint8_t index) {
  return vga_read_reg(VGA_CRTC_ADDRESS_REG_PORT, VGA_CRTC_DATA_REG_PORT, index);
}

static void vga_attr_write(uint8_t index, uint8_t value) {
  inportb(VGA_INPUT1_STATUS_REG);
  outportb(index | 0x20, VGA_ATTRIBUTE_ADDRESS_DATA_REG_PORT);
  inportb(VGA_ATTRIBUTE_DATA_REG_PORT);
  outportb(value, VGA_ATTRIBUTE_ADDRESS_DATA_REG_PORT);
  inportb(VGA_INPUT1_STATUS_REG);
}

static uint8_t vga_attr_read(uint8_t index) {
  inportb(VGA_INPUT1_STATUS_REG);
  uint8_t rest_val = inportb(VGA_ATTRIBUTE_ADDRESS_DATA_REG_PORT);
  outportb(index, VGA_ATTRIBUTE_ADDRESS_DATA_REG_PORT);
  uint8_t value = inportb(VGA_ATTRIBUTE_DATA_REG_PORT);
  outportb(rest_val, VGA_ATTRIBUTE_ADDRESS_DATA_REG_PORT);
  inportb(VGA_INPUT1_STATUS_REG);
  return value;
}
