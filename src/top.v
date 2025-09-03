`include "src/control_defs.vh"

`timescale 1ns/1ps

module top;

    reg clk;
    reg clk_;
    reg clear;
    wire [7:0] bus;
    wire [7:0] data_a;
    wire [7:0] data_b;
    wire [1:0] flags;
    wire [15:0] control_word;

    always @(*) begin
        if (control_word[CW.HALT] === 1)
            clk = 0;
        else
            clk = clk_;
    end

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
        .bus(bus),
        .flags(flags)
    );

    ram ram (
        .clk(clk),
        .clear(clear),
        .load_address(control_word[CW.MEMORY_ADDRESS_IN]),
        .ram_in(control_word[CW.RAM_IN]),
        .ram_out(control_word[CW.RAM_OUT]),
        .bus_in(bus),
        .bus_out(bus)
    );

    instruction_decoder instruction_decoder (
        .clk(clk),
        .clear(clear),
        .enable(1'b1),  // always have instruction decoder in control
        .flag_register(flags),
        .bus_in(bus),
        .bus_out(bus),
        .control_word_in(control_word),
        .control_word_out(control_word)
    );

    program_counter program_counter (
        .clk(clk),
        .clear(clear),
        .counter_enable(control_word[CW.COUNTER_ENABLE]),
        .counter_out(control_word[CW.COUNTER_OUT]),
        .jump(control_word[CW.JUMP]),
        .bus_in(bus),
        .bus_out(bus)
    );

    reg8 out (
        .clk(clk),
        .load(control_word[CW.OUTPUT_IN]),
        .enable(0),
        .clear(clear),
        .bus(bus)
    );

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, top);
        $readmemh("programs/hello_world.hex", ram.ram);

        clk_ = 0;
        clear = 1; #1 clear = 0;

        #500 $finish;
    end

    always #5 clk_ = ~clk_;
endmodule