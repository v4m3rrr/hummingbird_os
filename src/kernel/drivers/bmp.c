#include "kernel/drivers/bmp.h"
#include "kernel/drivers/vga.h"

int bmp_load(uint8_t *file, bmp_t *out_bmp) {
  uint8_t *file_begin = file;
  uint8_t *p_header = (uint8_t *)&out_bmp->header;
  for (int i = 0; i < sizeof(bmp_header_t); i++) {
    *p_header = *file;
    file++;
    p_header++;
  }

  if (out_bmp->header.signature != BMP_SIGNATURE) {
    goto error;
  }

  uint8_t *p_header_info = (uint8_t *)&out_bmp->info_header;
  for (int i = 0; i < sizeof(bmp_info_header_t); i++) {
    *p_header_info = *file;
    file++;
    p_header_info++;
  }

  if (out_bmp->info_header.bpp != BMP_BPP_8) {
    goto error;
  }

  if (out_bmp->info_header.comp != BMP_NO_COMPRESSION) {
    goto error;
  }

  if (out_bmp->info_header.color_used == 0) {
    out_bmp->info_header.color_used = 256;
  }

  out_bmp->data = file_begin + out_bmp->header.data_offset;
  out_bmp->color_pallete =
      file_begin + (out_bmp->info_header.size + sizeof(bmp_header_t));

  return BMP_SUCCESS;
error:
  return BMP_FAILURE;
}
void bmp_draw(bmp_t *bmp) {
  for (int i = 0; i < bmp->info_header.color_used; i++) {
    uint8_t b = bmp->color_pallete[i * 4 + 0];
    uint8_t g = bmp->color_pallete[i * 4 + 1];
    uint8_t r = bmp->color_pallete[i * 4 + 2];
    vga_set_color_palette(r, g, b, i);
  }

  int width = bmp->info_header.width;
  int height = bmp->info_header.height;

  int is_bottom_up = 1;
  if (height < 0) {
    height = -height;
    is_bottom_up = 0;
  }

  int stride = (width + 3) & ~3;

  uint8_t *vram = (uint8_t *)0xA0000;
  uint8_t *pixels = bmp->data;
  int screan_height = vga_get_screen_height();
  int screan_width = vga_get_screen_width();

  for (int y = 0; y < height && y < screan_height; y++) {
    uint8_t *src;
    if (is_bottom_up) {
      src = pixels + (height - 1 - y) * stride;
    } else {
      src = pixels + y * stride;
    }

    uint8_t *dst = vram + y * screan_width;

    for (int x = 0; x < width && x < screan_width; x++) {
      dst[x] = src[x];
    }
  }
}
