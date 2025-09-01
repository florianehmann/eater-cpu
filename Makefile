sim:
	iverilog -o sim.vvp src/*.v testbenches/*.v
	vvp sim.vvp

clean:
	rm *.vvp *.vcd