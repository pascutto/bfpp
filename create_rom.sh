#!/bin/bash

filename=`echo "$1" | cut -d'.' -f1`
bfpp="$filename".bfpp
bin="$filename".bin

./asm/assembler $bfpp
cp cpu/instr_rom.mem cpu/romtmp.mem
cat $bin >> cpu/romtmp.mem
sed -e '$a\' cpu/romtmp.mem > cpu/rom.mem
rm -f cpu/romtmp.mem
