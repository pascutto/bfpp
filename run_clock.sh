#!/bin/bash

if [[ $1 = "fast" ]]
then 
	./create_rom.sh clk/clock_zero.bfpp
else
	python3 clk/format_date.py > tmp && cat clk/clock_realtime_init.bfpp >> tmp && mv tmp clk/clock_realtime.bfpp
	./create_rom.sh clk/clock_realtime.bfpp
fi 
	
./sim/netlist_sim.byte -mem cpu/rom.mem -steps 0 -net cpu/proc.net | python3 clk/sexy_printer.py
