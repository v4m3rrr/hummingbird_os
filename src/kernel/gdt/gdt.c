#include "kernel/gdt/gdt.h"

static void gdt_add_entry(uint8_t access_byte, uint32_t base, uint32_t limit,
                          uint8_t flags, gdt_entry_t *out_entry);

static gdt_entry_t gdt[5] = {0};
static gdtr_t gdtr = {0};

extern int gdt_reload(void *gdtr);

void gdt_init_32_proc_mode() {
  // NULL Descriptor
  gdt_add_entry(0, 0, 0, 0, &gdt[0]);

  // Kernel Code Descriptor
  gdt_add_entry(GDT_ACCESS_KERNEL_CODE, 0, GDT_MAX_LIMIT,
                GDT_FLAG_LIMIT_4KIB_BLOCKS | GDT_FLAG_32_BIT_MODE, &gdt[1]);

  // Kernel Data Descriptor
  gdt_add_entry(GDT_ACCESS_KERNEL_DATA, 0, GDT_MAX_LIMIT,
                GDT_FLAG_LIMIT_4KIB_BLOCKS | GDT_FLAG_32_BIT_MODE, &gdt[2]);

  // User Code Descriptor
  gdt_add_entry(GDT_ACCESS_USER_CODE, 0, GDT_MAX_LIMIT,
                GDT_FLAG_LIMIT_4KIB_BLOCKS | GDT_FLAG_32_BIT_MODE, &gdt[3]);

  // User Code Descriptor
  gdt_add_entry(GDT_ACCESS_USER_DATA, 0, GDT_MAX_LIMIT,
                GDT_FLAG_LIMIT_4KIB_BLOCKS | GDT_FLAG_32_BIT_MODE, &gdt[4]);

  gdtr.limit = sizeof(gdt) - 1;
  gdtr.offset = (uint32_t)&gdt[0];

  gdt_reload(&gdtr);
}

static void gdt_add_entry(uint8_t access_byte, uint32_t base, uint32_t limit,
                          uint8_t flags, gdt_entry_t *out_entry) {
  *out_entry = (gdt_entry_t){0};

  out_entry->low_limit = (uint16_t)limit;
  out_entry->high_limit_and_flags =
      (uint8_t)(flags << 4 | (limit >> 16 & 0x0f));

  out_entry->low_base = (uint16_t)base;
  out_entry->mid_base = (uint8_t)(base >> 16);
  out_entry->high_base = (uint8_t)(base >> 24);

  out_entry->access_byte = access_byte;

  return;
}
