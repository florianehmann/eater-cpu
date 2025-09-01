`timescale 1ns/1ns

module bus_stimulus (
    output reg [7:0] bus
);

    initial begin
        bus = 8'bz;

        #10 bus = 8'hfe;
        #10 bus = 8'bz;

        #30 bus = 8'h69;
        #10 bus = 8'bz;
    end

endmodule

module reg8_tb;

    reg load, enable, clk, clear;
    wire [7:0] bus;

    bus_stimulus stimmy (.bus(bus));

    reg8 r0 (
        .clk(clk),
        .load(load),
        .enable(enable),
        .clear(clear),
        .bus(bus),
        .bus_out(bus)
    );

    initial begin
        $dumpfile("reg8_tb.vcd");
        $dumpvars(0, reg8_tb);

        clk = 0;
        enable = 0;
        load = 0;
        clear = 1;

        // load data from bus
        #10 clear = 0;
        #0 load = 1;
        #10 load = 0;

        // output data onto bus
        #10 enable = 1;
        #10 enable = 0;

        // read new data from the bus
        #10 load = 1;
        #10 load = 0;

        // clear register
        #10 clear = 1;
        #10 clear = 0;

        #10 $finish;
    end

    always #5 clk = ~clk;

endmodule