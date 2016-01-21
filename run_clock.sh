#!/bin/bash

./create_rom.sh clock/clock.bfpp
./sim/netlist_sim.byte -mem proc/rom.mem -steps $1 -net proc/proc.net | python3 printer.py
