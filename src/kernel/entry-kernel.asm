[bits 32]

[extern kernel_main]

entry_kernel:
    call kernel_main

    cli
    hlt