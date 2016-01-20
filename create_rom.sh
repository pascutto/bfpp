#!/bin/bash

filename=`echo "$1" | cut -d'.' -f1`
bfpp="$filename".bfpp
bin="$filename".bin

./assembler/assembler $bfpp
cp proc/instr_rom.mem proc/rom.mem
cat $bin >> proc/rom.mem
echo "\n" >> proc/rom.mem
