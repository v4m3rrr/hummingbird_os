#ifndef KERNEL_DRIVERS_VGA_INTERNAL_H
#define KERNEL_DRIVERS_VGA_INTERNAL_H

#include <stdint.h>

static uint32_t VGA_SCREEN_WIDTH;
static uint32_t VGA_SCREEN_HEIGHT;

#define VGA_SEQUENCER_ADDRESS_REG_PORT (uintptr_t)0x3C4
#define VGA_SEQUENCER_DATA_REG_PORT (uintptr_t)0x3C5

#define VGA_SEQ_CLOCKING_MODE_INDEX (uint8_t)0x1
#define VGA_SEQ_CLOCKING_MODE_SCREEN_DISABLE_BITSHIFT (uint8_t)5

#define VGA_SEQ_MAP_MASK_INDEX (uint8_t)0x2
#define VGA_SEQ_CHARACTER_MAP_INDEX (uint8_t)0x3
#define VGA_SEQ_MEMORY_MODE_INDEX (uint8_t)0x4

// Their values depends on content of Input/Output Address Select bit in
// external Miscellaneous Output Register
static uintptr_t VGA_CRTC_ADDRESS_REG_PORT;
static uintptr_t VGA_CRTC_DATA_REG_PORT;

#define VGA_CRTC_HORIZONTAL_TOTAL_INDEX (uint8_t)0x0
#define VGA_CRTC_HORIZONTAL_DISP_END_INDEX (uint8_t)0x1
#define VGA_CRTC_HORIZONTAL_BLANK_START_INDEX (uint8_t)0x2
#define VGA_CRTC_HORIZONTAL_BLANK_END_INDEX (uint8_t)0x3
#define VGA_CRTC_HORIZONTAL_RETRACE_START_INDEX (uint8_t)0x4
#define VGA_CRTC_HORIZONTAL_RETRACE_END_INDEX (uint8_t)0x5
#define VGA_CRTC_VERTICAL_TOTAL_INDEX (uint8_t)0x6
#define VGA_CRTC_OVERFLOW_INDEX (uint8_t)0x7
#define VGA_CRTC_PRESET_ROW_SCAN_INDEX (uint8_t)0x8
#define VGA_CRTC_MAXIMUM_SCAN_LINE_INDEX (uint8_t)0x9
#define VGA_CRTC_VERTICAL_RETRACE_START_INDEX (uint8_t)0x10
#define VGA_CRTC_VERTICAL_RETRACE_END_INDEX (uint8_t)0x11
#define VGA_CRTC_VERTICAL_RETRACE_END_PROTECT_REG_BITSHIT (uint8_t)7
#define VGA_CRTC_VERTICAL_DISPLAY_ENABLE_END_INDEX (uint8_t)0x12
#define VGA_CRTC_LOGICAL_WIDTH_INDEX (uint8_t)0x13
#define VGA_CRTC_UNDERLINE_LOC_INDEX (uint8_t)0x14
#define VGA_CRTC_VERTICAL_BLANK_START_INDEX (uint8_t)0x15
#define VGA_CRTC_VERTICAL_BLANK_END_INDEX (uint8_t)0x16
#define VGA_CRTC_MODE_CONTROL_INDEX (uint8_t)0x17

#define VGA_ATTRIBUTE_ADDRESS_DATA_REG_PORT (uintptr_t)0x3C0
#define VGA_ATTRIBUTE_DATA_REG_PORT (uintptr_t)0x3C1

static uintptr_t VGA_INPUT1_STATUS_REG;

#define VGA_ATTR_MODE_CONTROL_INDEX (uint8_t)0x10
#define VGA_ATTR_OVERSCAN_COLOR_INDEX (uint8_t)0x11
#define VGA_ATTR_COLOR_PLANE_ENABLE_INDEX (uint8_t)0x12
#define VGA_ATTR_HORIZONTAL_PANNING_INDEX (uint8_t)0x13
#define VGA_ATTR_COLOR_SELECT_INDEX (uint8_t)0x14

#define VGA_GRAPHICS_ADDRESS_REG_PORT (uintptr_t)0x3CE
#define VGA_GRAPHICS_DATA_REG_PORT (uintptr_t)0x3CF

#define VGA_GC_MODE_INDEX (uint8_t)0x5
#define VGA_GC_MISCELLANEOUS_INDEX (uint8_t)0x6
#define VGA_GC_MEMORY_MAP_BITSHIFT (uint8_t)2

static void vga_init_crtc_and_input1_regs();

static void vga_enable_display();
static void vga_disable_display();

static void vga_lock_CTRC_regs();
static void vga_unlock_CTRC_regs();

static uint8_t vga_read_reg(uintptr_t address_port, uintptr_t data_port,
                            uint8_t index);
static void vga_write_reg(uintptr_t address_port, uintptr_t data_port,
                          uint8_t index, uint8_t value);
static void vga_set_reg(uintptr_t address_port, uintptr_t data_port,
                        uint8_t index, uint8_t bits);
static void vga_clear_reg(uintptr_t address_port, uintptr_t data_port,
                          uint8_t index, uint8_t bits);

static void vga_gc_write(uint8_t index, uint8_t value);
static void vga_gc_set(uint8_t index, uint8_t bits);
static void vga_gc_clear(uint8_t index, uint8_t bits);
static uint8_t vga_gc_read(uint8_t index);

static void vga_seq_write(uint8_t index, uint8_t value);
static void vga_seq_set(uint8_t index, uint8_t bits);
static void vga_seq_clear(uint8_t index, uint8_t bits);
static uint8_t vga_seq_read(uint8_t index);

static void vga_crtc_write(uint8_t index, uint8_t value);
static void vga_crtc_set(uint8_t index, uint8_t bits);
static void vga_crtc_clear(uint8_t index, uint8_t bits);
static uint8_t vga_crtc_read(uint8_t index);

static void vga_attr_write(uint8_t index, uint8_t value);
// static void vga_attr_set(uint8_t index, uint8_t bits);
// static void vga_attr_clear(uint8_t index, uint8_t bits);
static uint8_t vga_attr_read(uint8_t index);

#endif // KERNEL_DRIVERS_VGA_INTERNAL_H
