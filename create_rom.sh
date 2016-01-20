#!/bin/bash

filename=`echo "$1" | cut -d'.' -f1`
bfpp="$filename".bfpp
bin="$filename".bin

./assembler/assembler $bfpp
cp proc/instr_rom.mem proc/romtmp.mem
cat $bin >> proc/romtmp.mem
sed -e '$a\' proc/romtmp.mem > proc/rom.mem
rm -f proc/romtmp.mem
