module program_counter (
    input  wire       clk,
    input  wire       clear,
    input  wire       counter_enable,
    input  wire       counter_out,
    input  wire       jump,
    input  wire [7:0] bus_in,
    output wire [7:0] bus_out
);
    reg [3:0] counter;

    assign bus_out = (counter_out) ? {4'b0, counter} : 8'bz;

    always @(posedge clk or posedge clear) begin
        if (clear)
            counter <= 0;
        else
            if (jump)
                counter <= bus_in[3:0];
            else
                if (counter_enable)
                    counter <= counter + 1;
    end

endmodule