#include <stdint.h>

#include "kernel/drivers/video.h"
#include "kernel/gdt/gdt.h"

// Enable NMI and sti
int kernel_main() {
  const char *humBird = "Hummingbird OS";
  print(humBird);
  gdt_init_32_proc_mode();

  return 0;
}
