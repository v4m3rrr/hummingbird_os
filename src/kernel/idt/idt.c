#include "kernel/idt/idt.h"

#include "kernel/gdt/gdt.h"

static void idt_set_entry(uint8_t gate_type_and_flags, uint16_t segment_sel,
                          uint32_t offset, idt_entry_t *out_entry);
extern void *isr_stub_table[];

__attribute__((
    aligned(sizeof(idt_entry_t)))) static idt_entry_t idt[IDT_MAX_GATES] = {0};
static idtr_t idtr = {0};

void idt_init_32_proc_mode() {
  for (uint32_t i = 0; i < IDT_INTEL_MANDATORY_EXCEPTIONS_NUMBER; ++i) {
    idt_set_entry(
        IDT_GATE_TYPE_INTERRUPT | IDT_FLAG_SIZE_GATE_32 | IDT_FLAG_PRESENT,
        GDT_KERNEL_CODE_DESC_INDEX << 3, (uint32_t)isr_stub_table[i], &idt[i]);
  }

  idtr.limit = sizeof(idt) - 1;
  idtr.offset = (uint32_t)&idt[0];

  __asm__ volatile("lidt %0" : : "m"(idtr) : "memory");
}

static void idt_set_entry(uint8_t gate_type_and_flags, uint16_t segment_sel,
                          uint32_t offset, idt_entry_t *out_entry) {
  *out_entry = (idt_entry_t){0};

  out_entry->low_offset = (uint16_t)offset;
  out_entry->high_offset = (uint16_t)(offset >> 16);

  out_entry->segment_sel = segment_sel;
  out_entry->gate_type_and_flags = gate_type_and_flags;
  out_entry->zero_byte = 0;

  return;
}

//__attribute__((noreturn)) void panic_handler() {
//  clear();
//  print("Kernel entered panic state. The system reboot is needed.");
//  __asm__ volatile("cli;hlt");
//  __builtin_unreachable();
//}
