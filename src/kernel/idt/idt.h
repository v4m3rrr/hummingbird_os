#ifndef KERNEL_IDT_IDT_H
#define KERNEL_IDT_IDT_H

#include <stdint.h>

#define IDT_DPL_KERNEL (uint8_t)0x00
#define IDT_DPL_USER (uint8_t)0x60

#define IDT_PRESENT_FLAG (uint8_t)0x80
#define IDT_SIZE_GATE_32 (uint8_t)0x08

#define IDT_GATE_TYPE_INTERRUPT (uint8_t)0x06
#define IDT_GATE_TYPE_TRAP (uint8_t)0x07

typedef struct idt_entry_t {
  uint16_t low_offset;
  uint16_t segment_sel;
  uint8_t zero_byte;
  uint8_t gate_type_and_flags;
  uint16_t high_offset;
} __attribute__((packed)) idt_entry_t;

typedef struct idtr_t {
  uint16_t limit;
  uint32_t offset;
} __attribute__((packed)) idtr_t;

#endif // KERNEL_IDT_IDT_H
