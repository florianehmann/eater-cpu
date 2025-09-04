`include "src/control_defs.vh"

module instruction_decoder (
    input  wire        clk,
    input  wire        clear,
    input  wire        enable,                       // output control word
    input  wire  [1:0] flag_register,
    input  wire  [7:0] bus_in,
    input  wire [15:0] control_word_in,
    output wire  [7:0] bus_out,
    output wire [15:0] control_word_out
);
    wire        clk_n = ~clk;
    wire  [3:0] opcode;
    reg   [2:0] step;
    reg   [7:0] instruction_register;
    reg  [15:0] control_word;

    assign bus_out = (control_word_in[CW.INSTRUCTION_OUT]) ? {4'b0, instruction_register[3:0]} : 8'bz;
    assign control_word_out = (enable) ? control_word : 16'bz;
    assign opcode = instruction_register[7:4];

    initial begin
        step = 3'b0;
    end

    // instruction register
    always @(posedge clk or posedge clear) begin
        if (clear)
            instruction_register <= 0;
        else
            if (control_word_in[CW.INSTRUCTION_IN])
                instruction_register <= bus_in;
    end

    // microstep counter
    always @(posedge clk_n or posedge clear) begin
        if (clear)
            step <= 0;
        else
            step <= (step >= 3'd4) ? 0 : step + 1;
    end

    // decoder logic
    always @(*) begin
        control_word = 0;

        // fetch
        if (step < 2) begin
            case (step)
                3'd0: control_word = (1 << CW.COUNTER_OUT) | (1 << CW.MEMORY_ADDRESS_IN);
                3'd1: control_word = (1 << CW.RAM_OUT) | (1 << CW.INSTRUCTION_IN) | (1 << CW.COUNTER_ENABLE);
            endcase
        end
        
        // decode
        else begin
            case(opcode)
                OPCODE.NOP: control_word = 0;  // this is where we could output a signal to end the cycle prematurely
                OPCODE.LDA: begin
                    case (step)
                        3'd2: control_word = (1 << CW.MEMORY_ADDRESS_IN) | (1 << CW.INSTRUCTION_OUT);
                        3'd3: control_word = (1 << CW.RAM_OUT) | (1 << CW.A_IN);
                    endcase
                end
                OPCODE.ADD: begin
                    case (step)
                        3'd2: control_word = (1 << CW.MEMORY_ADDRESS_IN) | (1 << CW.INSTRUCTION_OUT);
                        3'd3: control_word = (1 << CW.RAM_OUT) | (1 << CW.B_IN);
                        3'd4: control_word = (1 << CW.A_IN) | (1 << CW.SUM_OUT) | (1 << CW.FLAGS_IN);
                    endcase
                end
                OPCODE.SUB: begin
                    case (step)
                        3'd2: control_word = (1 << CW.MEMORY_ADDRESS_IN) | (1 << CW.INSTRUCTION_OUT);
                        3'd3: control_word = (1 << CW.RAM_OUT) | (1 << CW.B_IN);
                        3'd4: control_word = (1 << CW.A_IN) | (1 << CW.SUM_OUT) | (1 << CW.SUBTRACT) | (1 << CW.FLAGS_IN);
                    endcase
                end
                OPCODE.STA: begin
                    case (step)
                        3'd2: control_word = (1 << CW.MEMORY_ADDRESS_IN) | (1 << CW.INSTRUCTION_OUT);
                        3'd3: control_word = (1 << CW.RAM_IN) | (1 << CW.A_OUT);
                    endcase
                end
                OPCODE.LDI: begin
                    case (step)
                        3'd2: control_word = (1 << CW.INSTRUCTION_OUT) | (1 << CW.A_IN);
                    endcase
                end
                OPCODE.JMP: begin
                    case (step)
                        3'd2: control_word = (1 << CW.INSTRUCTION_OUT) | (1 << CW.JUMP);
                    endcase
                end
                OPCODE.JC: begin
                    if (flag_register[1] === 1'b1) begin
                        case (step)
                            3'd2: control_word = (1 << CW.INSTRUCTION_OUT) | (1 << CW.JUMP);
                        endcase
                    end
                end
                OPCODE.JZ:
                    if (flag_register[0] === 1'b1)
                        case (step)
                            3'd2: control_word = (1 << CW.INSTRUCTION_OUT) | (1 << CW.JUMP);
                        endcase
                OPCODE.OUT: begin
                    case (step)
                        3'd2: control_word = (1 << CW.A_OUT) | (1 << CW.OUTPUT_IN);
                    endcase
                end
                OPCODE.HLT: begin
                    case (step)
                        3'd2: control_word = (1 << CW.HALT);
                    endcase
                end
            endcase
        end
    end

endmodule