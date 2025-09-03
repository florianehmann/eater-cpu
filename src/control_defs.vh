`ifndef CONTROL_DEFS_VH
`define CONTROL_DEFS_VH

module CW;
    parameter FLAGS_IN          = 0;
    parameter JUMP              = 1;
    parameter COUNTER_OUT       = 2;
    parameter COUNTER_ENABLE    = 3;
    parameter OUTPUT_IN         = 4;
    parameter B_IN              = 5;
    parameter SUBTRACT          = 6;
    parameter SUM_OUT           = 7;

    parameter A_OUT             = 8;
    parameter A_IN              = 9;
    parameter INSTRUCTION_IN    = 10;
    parameter INSTRUCTION_OUT   = 11;
    parameter RAM_OUT           = 12;
    parameter RAM_IN            = 13;
    parameter MEMORY_ADDRESS_IN = 14;
    parameter HALT              = 15;
endmodule

module OPCODE;
    parameter NOP = 4'd0;
    parameter LDA = 4'd1;
    parameter ADD = 4'd2;
    parameter SUB = 4'd3;
    parameter STA = 4'd4;
    parameter LDI = 4'd5;
    parameter JMP = 4'd6;
    parameter OUT = 4'd7;
    parameter HLT = 4'd8;
endmodule

`endif