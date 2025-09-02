sim:
	iverilog -o sim.vvp src/*.v testbenches/alu8_tb.v
	vvp sim.vvp

clean:
	rm *.vvp *.vcd