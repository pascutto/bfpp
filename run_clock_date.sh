#!/bin/bash

python3 format_date.py > tmp && cat clock/clock_date_realtime_zero.bfpp >> tmp && mv tmp clock/clock_date.bfpp

./create_rom.sh clock/clock_date.bfpp
./sim/netlist_sim.byte -mem proc/rom.mem -steps 0 -net proc/proc.net | python3 sexy_printer_with_date.py
