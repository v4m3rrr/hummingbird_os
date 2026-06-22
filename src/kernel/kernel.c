#include <stdint.h>

#include "kernel/drivers/video.h"
#include "kernel/gdt/gdt.h"
#include "kernel/idt/idt.h"

// Enable NMI and sti
int kernel_main() {
  const char *humBird = "Hummingbird OS";
  print(humBird);
  gdt_init_32_proc_mode();
  idt_init_32_proc_mode();

  int a = 0;
  int b = 10;
  int result = b / a;

  return 0;
}
