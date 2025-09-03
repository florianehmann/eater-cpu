`include "src/control_defs.vh"

`timescale 1ns/1ps

module top;

    reg clk;
    reg clear;
    wire [7:0] bus;

    reg [15:0] control_word;

    wire [7:0] data_a;
    wire [7:0] data_b;

    reg8 a (
        .clk(clk),
        .load(control_word[CW.A_IN]),
        .enable(control_word[CW.A_OUT]),
        .clear(clear),
        .bus(bus),
        .bus_out(bus),
        .data_out(data_a)
    );

    reg8 b (
        .clk(clk),
        .load(control_word[CW.B_IN]),
        .enable(1'b0),
        .clear(clear),
        .bus(bus),
        .bus_out(bus),
        .data_out(data_b)
    );

    alu8 alu (
        .clk(clk),
        .load(control_word[CW.FLAGS_IN]),
        .clear(clear),
        .sum_out(control_word[CW.SUM_OUT]),
        .subtract(control_word[CW.SUBTRACT]),
        .a(data_a),
        .b(data_b),
        .bus(bus)
    );

    //initial begin
    //    $dumpfile("counter.vcd");
    //    $dumpvars(0, top);

    //    clk = 0;
    //    control_word = 16'b0;
    //    clear = 1;
    //    #1 clear = 0;

    //    b.data = 8'b1;
    //    control_word |= (1 << CW.SUM_OUT) | (1 << CW.A_IN);

    //    #5000 control_word |= (1 << CW.SUBTRACT);

    //    #5000 $finish;
    //end

    always #5 clk = ~clk;


endmodule