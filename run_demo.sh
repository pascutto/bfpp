#!/bin/bash

./create_rom.sh $1
	
./sim/netlist_sim.byte -mem cpu/rom.mem -steps 0 -net cpu/proc.net | python3 clk/sexy_printer.py
