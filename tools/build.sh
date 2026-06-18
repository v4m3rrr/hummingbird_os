#!/bin/sh
if [ "$1" = "rebuild" ]; then
  make clean
fi

bear -- make all
