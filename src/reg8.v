module reg8 (
    input  wire       clk,
    input  wire       load,     // load from the bus
    input  wire       enable,   // put value on the bus
    input  wire       clear,    // clears the stored data
    input  wire [7:0] bus,      // input from bus
    output wire [7:0] bus_out,  // drives the bus
    output wire [7:0] data_out  // permanent output of register data
);

    reg [7:0] data;

    assign bus_out = (enable) ? data : 8'bz;
    assign data_out = data;

    always @(posedge clk) begin
        if (load)
            data <= bus;
    end

    always @(*) begin
        if (clear)
            data = 0;
    end

endmodule