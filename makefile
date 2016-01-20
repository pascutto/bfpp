
steps?=1

all:
	./minijazz/mjc.byte proc/proc.mj
	cd sim && make
	cd assembler && make

sim: FORCE
	cd sim && make

asm: FORCE
	cd assembler && make

proc: FORCE
	./minijazz/mjc.byte proc/proc.mj

run: FORCE
	./sim/netlist_sim.byte -steps $(steps) -mem proc/rom.mem -net proc/proc.net

FORCE:

clean: 
	cd sim && make clean
	cd assembler && make clean
	rm proc/proc.net*
