module alu8 (
    input  wire       clk,
    input  wire       load,       // signal to load flags into flag register
    input  wire       clear,      // signal to clear the flag register
    input  wire       sum_out,    // signal to output sum
    input  wire       subtract,   // signal to subtract instead of adding
    input  wire [7:0] a,          // data from accumulator register
    input  wire [7:0] b,          // data from base register
    output wire [7:0] bus,        // drive bus with result
    output reg  [1:0] flags       // output flag register flags[0] = zero, flags[1] = carry
);
    reg zero, carry;
    reg [7:0] data;

    assign bus = (sum_out) ? data : 8'bz;

    // arithmetic logic operations
    always @(*) begin
        if (subtract)
            {carry, data} = a - b;
        else
            {carry, data} = a + b;

        zero = (data == 0);
    end

    // flag register loading and clearing
    always @(posedge clk or posedge clear) begin
        if (clear)
            flags <= 0;
        else
            if (load)
                flags <= {carry, zero};
    end

endmodule