`timescale 1ns/1ps

module instruction_decoder_tb;

    reg         clk, clear, enable, bus_override;
    reg   [7:0] bus_override_word;
    reg   [1:0] flag_register;
    reg  [15:0] control_word_override_word;
    wire  [7:0] bus;
    wire [15:0] control_word;

    assign bus = (bus_override) ? bus_override_word : 8'bz;
    assign control_word = (~enable) ? control_word_override_word : 16'bz;

    instruction_decoder instruction_decoder (
        .clk(clk),
        .clear(clear),
        .enable(enable),
        .flag_register(flag_register),
        .bus_in(bus),
        .bus_out(bus),
        .control_word_in(control_word),
        .control_word_out(control_word)
    );

    task load_instruction;
        input [3:0] opcode;
        input [3:0] address;
        begin
            bus_override_word = {opcode, address};
            control_word_override_word = (1 << CW.INSTRUCTION_IN);
            enable = 0;
            bus_override = 1;
            #20;
            bus_override = 0;
            enable = 1;
            #1 if (instruction_decoder.instruction_register !== bus_override_word) $error;
        end
    endtask

    initial begin
        $dumpfile("instruction_decoder_tb.vcd");
        $dumpvars(0, instruction_decoder_tb);

        {clk, enable, bus_override} = 0;
        flag_register = 0;
        control_word_override_word = 0;
        clear = 1;
        #1 clear = 0;
        enable = 1;  // give control over system to instruction decoder

        load_instruction(OPCODE.LDI, 4'b0);

        #35 clear = 1; #1 clear = 0;

        #1 $finish;
    end

    always #5 clk = ~clk;

endmodule