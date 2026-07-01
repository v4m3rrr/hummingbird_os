#include <stdint.h>

#include "kernel/drivers/bmp.h"
#include "kernel/drivers/vga.h"
#include "kernel/gdt/gdt.h"
#include "kernel/idt/idt.h"

extern uint8_t _binary_images_welcome_bmp_start[];

// Enable NMI and sti
int kernel_main() {
  gdt_init_32_proc_mode();
  idt_init_32_proc_mode();
  vga_init();

  bmp_t bmp = {0};
  if (bmp_load(_binary_images_welcome_bmp_start, &bmp) == BMP_FAILURE) {
    // If it fails, fill the screen with RED and halt!
    uint8_t *vram = (uint8_t *)0xA0000;
    for (int i = 0; i < 320 * 200; i++) {
      vram[i] = 4; // 4 is standard VGA Red
    }
    while (1)
      __asm__ volatile("hlt"); // Stop her
  }

  bmp_draw(&bmp);
  return 0;
  // const char *humBird = "Hummingbird OS";
  // vga_write(humBird);

  int a = 0;
  int b = 10;
  int result = b / a;

  return 0;
}
