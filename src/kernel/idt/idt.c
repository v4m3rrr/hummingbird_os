#include "kernel/idt/idt.h"
#include "kernel/drivers/video.h"

__attribute__((aligned(0x08))) static idt_entry_t idt[256] = {0};
static idtr_t idtr = {0};

static void idt_add_entry(uint8_t gate_type_and_flags, uint16_t segment_sel,
                          uint32_t offset, idt_entry_t *out_entry);

static void idt_add_entry(uint8_t gate_type_and_flags, uint16_t segment_sel,
                          uint32_t offset, idt_entry_t *out_entry) {
  *out_entry = (idt_entry_t){0};

  out_entry->low_offset = (uint16_t)offset;
  out_entry->high_offset = (uint16_t)(offset >> 16);

  out_entry->segment_sel = segment_sel;
  out_entry->gate_type_and_flags = gate_type_and_flags;
  out_entry->zero_byte = 0;

  return;
}

__attribute__((noreturn)) void panic_handler() {
  print("Kernel entered panic state. The system reboot is needed.");
  __asm__ volatile("cli;hlt");
  __builtin_unreachable();
}
