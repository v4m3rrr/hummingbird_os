#ifndef KERNEL_GDT_GDT_H
#define KERNEL_GDT_GDT_H

#include <stdint.h>

#define GDT_ACCESS_DPL_KERNEL (uint8_t)0x00
#define GDT_ACCESS_DPL_USER (uint8_t)0x60

#define GDT_ACCESS_KERNEL_CODE (uint8_t)(0b10011011 | GDT_ACCESS_DPL_KERNEL)
#define GDT_ACCESS_KERNEL_DATA (uint8_t)(0b10010011 | GDT_ACCESS_DPL_KERNEL)

#define GDT_ACCESS_USER_CODE (uint8_t)(0b10011011 | GDT_ACCESS_DPL_USER)
#define GDT_ACCESS_USER_DATA (0b10010011 | GDT_ACCESS_DPL_USER)

#define GDT_FLAG_LIMIT_4KIB_BLOCKS (uint8_t)0x8
#define GDT_FLAG_32_BIT_MODE (uint8_t)0x4
#define GDT_FLAG_16_BIT_PROCTED_MODE (uint8_t)0x0
#define GDT_FLAG_LONG_MODE (uint8_t)0x2

#define GDT_FLAT_MODEL_BASE (uint32_t)0x0
#define GDT_MAX_LIMIT (uint32_t)0xfffff

#define GDT_NULL_DESC_INDEX (uint8_t)0x0
#define GDT_KERNEL_CODE_DESC_INDEX (uint8_t)0x1
#define GDT_KERNEL_DATA_DESC_INDEX (uint8_t)0x2
#define GDT_USER_CODE_DESC_INDEX (uint8_t)0x3
#define GDT_USER_DATA_DESC_INDEX (uint8_t)0x4

typedef struct gdt_entry_t {
  uint16_t low_limit;
  uint16_t low_base;
  uint8_t mid_base;
  uint8_t access_byte;
  uint8_t high_limit_and_flags; // 0-3 high_limit 4-7 flags
  uint8_t high_base;
} __attribute__((__packed__)) gdt_entry_t;

typedef struct gdtr_t {
  uint16_t limit;  // size - 1
  uint32_t offset; // linear address (paging applies)
} __attribute__((__packed__)) gdtr_t;

void gdt_init_32_proc_mode();

#endif // KERNEL_GDT_GDT_H
