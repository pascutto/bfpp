#!/bin/bash

sec=$((60 - `date +%S`))
min=$((60 - `date +%M`))
hour=$((24 - `date +%H`))


sed "1i\\$sec+>$min+>$hour+" clock/clock_realtime_zero.bfpp > clock/clock.bfpp

./create_rom.sh clock/clock.bfpp
./sim/netlist_sim.byte -mem proc/rom.mem -steps 0 -net proc/proc.net | python3 sexy_printer.py
