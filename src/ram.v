module ram (
    input  wire       clk,
    input  wire       clear,
    input  wire       load_address,
    input  wire       ram_in,
    input  wire       ram_out,
    input  wire [7:0] bus_in,
    output wire [7:0] bus_out
);
    reg [3:0] address;
    reg [7:0] ram [0:15];
    wire [7:0] ram_byte;

    assign ram_byte = ram[address];
    assign bus_out = (ram_out) ? ram_byte : 8'bz;

    // address register
    always @(posedge clk or posedge clear) begin
        if (clear)
            address <= 0;
        else
            if (load_address)
                address <= bus_in[3:0];
    end

    // reading from bus
    always @(posedge clk) begin
        if (ram_in)
            ram[address] = bus_in;
    end

endmodule