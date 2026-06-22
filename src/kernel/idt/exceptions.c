#include "kernel/idt/exceptions.h"

#include "kernel/drivers/vga.h"

void divide_error_handler() {
  vga_clear();
  vga_write("Division by 0");
  while (1)
    __asm__ volatile("cli;hlt");
  __builtin_unreachable();
}

void panic_handler() {
  vga_clear();
  vga_write("Kernel panic, abort. Restart of the system is necessary");
  while (1)
    __asm__ volatile("cli;hlt");
  __builtin_unreachable();
}
