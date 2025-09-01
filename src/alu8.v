module alu8 (
    input  wire       clk,
    input  wire       load,       // signal to load flags into flag register
    input  wire       clear,      // signal to clear the flag register
    input  wire       sum_out,    // signal to output sum
    input  wire       subract,    // signal to subtract instead of adding
    input  wire [7:0] a,          // data from accumulator register
    input  wire [7:0] b,          // data from base register
    output reg  [7:0] bus_out,    // drive bus with result
    output reg  [7:0] data_out,   // permanently output data
    output reg  [1:0] flags_out,  // permanently output flags
);

    reg carry, zero;
    reg [1:0] flag_data;

    always @(*) begin
        if (subtract)
            {carry, data_out} = A - B;
        else
            {carry, data_out} = A + B;
        
        zero = (data_out == 8'h0);
        carry = (subtract) ? (A < B) : (A + B > 8'hff);

        flags_out = {zero, carry};
    end

endmodule