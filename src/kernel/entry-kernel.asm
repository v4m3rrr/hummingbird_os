[bits 32]

[extern kernel_main]

entry_kernel:
cld ; to work with C clears direction bit
cli
call kernel_main

cli
hlt
