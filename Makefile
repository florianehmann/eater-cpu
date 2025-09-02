sim:
	iverilog -o sim.vvp src/*.v testbenches/
	vvp sim.vvp

clean:
	rm *.vvp *.vcd