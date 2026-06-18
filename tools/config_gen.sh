#!/bin/bash

while IFS='=' read -r left right; do
  [ -z "$left" ] && continue
  #right=${right//;/\/\/}
  echo "$left equ $right"
done < src/config.txt > src/config.inc

while IFS='=' read -r left right; do
  [ -z "$left" ] && continue
  right=${right//;/\/\/}
  echo "#define $left $right"
done < src/config.txt > src/config.h
