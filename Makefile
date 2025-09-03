sim:
	iverilog -o sim.vvp src/*.v testbenches/ram_tb.v
	vvp sim.vvp

clean:
	rm *.vvp *.vcd