steps?=1

all:
	./mjc/mjc.byte cpu/proc.mj
	cd sim && make
	cd asm && make

sim: FORCE
	cd sim && make

asm: FORCE
	cd asm && make

cpu: FORCE
	./mjc/mjc.byte cpu/proc.mj

run: FORCE
	./sim/netlist_sim.byte -steps $(steps) -mem cpu/rom.mem -net cpu/proc.net

FORCE:

clean: 
	cd sim && make clean
	cd asm && make clean
	rm cpu/proc.net
	rm cpu/rom.mem
	rm clk/*.bin
	rm clk/clock_realtime.bfpp
