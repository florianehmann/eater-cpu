`timescale 1ns/1ps

module alu8_tb;
    reg load, enable, clk, clear, sum_out, subtract;
    reg  [7:0] a, b;
    wire [1:0] flags;
    wire [7:0] bus;

    alu8 alu (
        .clk(clk),
        .load(load),
        .clear(clear),
        .sum_out(sum_out),
        .subtract(subtract),
        .a(a),
        .b(b),
        .bus(bus),
        .flags(flags)
    );

    initial begin
        $dumpfile("alu8_tb.vcd");
        $dumpvars(0, alu8_tb);

        {load, enable, clk, clear, sum_out, subtract, a, b} = 0;

        // reset flags register
        clear = 1;
        #1 clear = 0;

        // simple add
        a = 8'b01010101;
        b = 8'b10101010;
        #1 sum_out = 1;
        if (alu.data !== 8'hFF) $error(1);
        #1 if (bus !== 8'hFF) $error(1);

        // add with carry
        a = 8'b10000000;
        b = 8'b10000000;
        load = 1;
        #11 if (flags !== 2'b11) $error(1);
        load = 0;

        // subtract
        a = 224;
        b = 53;
        subtract = 1;
        #1;
        if (alu.data !== 171) $error(1);

        // subtract with borrow
        a = 123;
        b = 124;
        subtract = 1;
        load = 1;
        #11;
        if (flags[1] !== 1) $error(1);
        if (alu.data !== 8'hff) $error(1);

        // clear
        load = 0;
        clear = 1;
        #1;
        clear = 0;
        #1;
        if (flags !== 0) $error(1);

        #10 $finish;
    end

    always #5 clk = ~clk;
endmodule
