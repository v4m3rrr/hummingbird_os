#include <stdint.h>

int kernel_main()
{
    uint8_t* VIDEO_MEM = (uint8_t*)0xb8000;
    *VIDEO_MEM++='F';
    *VIDEO_MEM++=0x0A;

    *VIDEO_MEM++='A';
    *VIDEO_MEM++=0x0A;

    *VIDEO_MEM++='D';
    *VIDEO_MEM++=0x0A;

    *VIDEO_MEM++='E';
    *VIDEO_MEM++=0x0A;
    return 0;
}