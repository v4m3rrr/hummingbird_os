#ifndef KERNEL_DRIVERS_BMP_H
#define KERNEL_DRIVERS_BMP_H

#include <stdint.h>

#define BMP_SIGNATURE 0x4D42 // Little endian ("BM" in reverse)
#define BMP_BPP_8 8
#define BMP_NO_COMPRESSION 0

#define BMP_SUCCESS 0
#define BMP_FAILURE 1

typedef struct bmp_header_t {
  uint16_t signature;
  uint32_t file_size;
  uint32_t reserved;
  uint32_t data_offset;
} __attribute__((packed)) bmp_header_t;

typedef struct bmp_info_header_t {
  uint32_t size;
  int32_t width;
  int32_t height;
  uint16_t planes;
  uint16_t bpp; // Bits per pixel
  uint32_t comp;
  uint32_t img_size;
  int32_t x_ppm;
  int32_t y_ppm;
  uint32_t color_used;
  uint32_t color_important;
} __attribute__((packed)) bmp_info_header_t;

typedef struct {
  bmp_header_t header;
  bmp_info_header_t info_header;
  uint8_t *color_pallete;
  uint8_t *data;
} bmp_t;

int bmp_load(uint8_t *file, bmp_t *out_bmp);
void bmp_draw(bmp_t *bmp);

#endif // KERNEL_DRIVERS_BMP_H
