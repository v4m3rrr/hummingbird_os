#include "kernel/gdt/gdt.h"

static void gdt_add_entry(uint8_t access_byte, uint32_t base, uint32_t limit,
                          uint8_t flags, gdt_entry_t *out_entry);
static void gdt_reload_flat_mem();

__attribute__((aligned(0x08))) static gdt_entry_t gdt[5] = {0};
static gdtr_t gdtr = {0};

// extern int gdt_reload(void *gdtr);

void gdt_init_32_proc_mode() {
  // NULL Descriptor
  gdt_add_entry(0, 0, 0, 0, &gdt[GDT_NULL_DESC_INDEX]);

  // Kernel Code Descriptor
  gdt_add_entry(GDT_ACCESS_KERNEL_CODE, 0, GDT_MAX_LIMIT,
                GDT_FLAG_LIMIT_4KIB_BLOCKS | GDT_FLAG_32_BIT_MODE,
                &gdt[GDT_KERNEL_CODE_DESC_INDEX]);

  // Kernel Data Descriptor
  gdt_add_entry(GDT_ACCESS_KERNEL_DATA, 0, GDT_MAX_LIMIT,
                GDT_FLAG_LIMIT_4KIB_BLOCKS | GDT_FLAG_32_BIT_MODE,
                &gdt[GDT_KERNEL_DATA_DESC_INDEX]);

  // User Code Descriptor
  gdt_add_entry(GDT_ACCESS_USER_CODE, 0, GDT_MAX_LIMIT,
                GDT_FLAG_LIMIT_4KIB_BLOCKS | GDT_FLAG_32_BIT_MODE,
                &gdt[GDT_USER_CODE_DESC_INDEX]);

  // User Data Descriptor
  gdt_add_entry(GDT_ACCESS_USER_DATA, 0, GDT_MAX_LIMIT,
                GDT_FLAG_LIMIT_4KIB_BLOCKS | GDT_FLAG_32_BIT_MODE,
                &gdt[GDT_USER_DATA_DESC_INDEX]);

  gdtr.limit = sizeof(gdt) - 1;
  gdtr.offset = (uint32_t)&gdt[0];

  gdt_reload_flat_mem();

  return;
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

static void gdt_reload_flat_mem() {
  __asm__ volatile("pushf\n\t"
                   "cli\n\t"
                   "lgdt (%0)\n\t"
                   "ljmp %1,$1f\n\t"
                   "1:\n\t"
                   "movw %2,%%ds\n\t"
                   "movw %2,%%es\n\t"
                   "movw %2,%%ss\n\t"
                   "movw %2,%%fs\n\t"
                   "movw %2,%%gs\n\t"
                   "popf\n\t"
                   :
                   : "r"(&gdtr),
                     "i"((uint16_t)(GDT_KERNEL_CODE_DESC_INDEX << 3)),
                     "r"((uint16_t)(GDT_KERNEL_DATA_DESC_INDEX << 3))
                   : "memory");
  /*
  ;call instruction pushes only the offset, not a full segment:offset pair,
  ;and ret reuses whatever CS is current — it doesn't restore
  ;the CS from call time. This code is only correct because
  ;the segments involved are flat (base 0), making the
  ;distinction between "old CS" and "new CS" irrelevant for address
  computation.
  */
  return;
}
