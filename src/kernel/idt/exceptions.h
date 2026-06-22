#ifndef KERNEL_IDT_EXCEPTIONS_H
#define KERNEL_IDT_EXCEPTIONS_H

#include <stdint.h>

__attribute__((noreturn)) void panic_handler();

__attribute__((noreturn)) void divide_error_handler();

#endif // KERNEL_IDT_EXCEPTIONS_H
