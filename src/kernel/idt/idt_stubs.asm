[bits 32]

extern test_handler
extern panic_handler

%macro isr_stub 1
isr_stub_%+%1:
  call panic_handler
  iret
%endmacro

%macro isr_stub_error 1
isr_stub_error_%+%1:
  call panic_handler

  pop eax
  iret
%endmacro

isr_stub 0
isr_stub 1
isr_stub 2
isr_stub 3
isr_stub 4
isr_stub 5
isr_stub 6
isr_stub 7
isr_stub_error 8
isr_stub 9
isr_stub_error 10
isr_stub_error 11
isr_stub_error 12
isr_stub_error 13
isr_stub_error 14
isr_stub 15
isr_stub 16
isr_stub_error 17
isr_stub 18
isr_stub 19
isr_stub 20
isr_stub_error 21
isr_stub 22
isr_stub 23
isr_stub 24
isr_stub 25
isr_stub 26
isr_stub 27
isr_stub 28
isr_stub 29
isr_stub 30
isr_stub 31

global isr_stub_table
isr_stub_table:
  dd isr_stub_0
  dd isr_stub_1
  dd isr_stub_2
  dd isr_stub_3
  dd isr_stub_4
  dd isr_stub_5
  dd isr_stub_6
  dd isr_stub_7
  dd isr_stub_error_8
  dd isr_stub_9
  dd isr_stub_error_10
  dd isr_stub_error_11
  dd isr_stub_error_12
  dd isr_stub_error_13
  dd isr_stub_error_14
  dd isr_stub_15
  dd isr_stub_16
  dd isr_stub_error_17
  dd isr_stub_18
  dd isr_stub_19
  dd isr_stub_20
  dd isr_stub_error_21
  dd isr_stub_22
  dd isr_stub_23
  dd isr_stub_24
  dd isr_stub_25
  dd isr_stub_26
  dd isr_stub_27
  dd isr_stub_28
  dd isr_stub_29
  dd isr_stub_30
  dd isr_stub_31
