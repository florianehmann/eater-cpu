module top;

    wire clk, clear, enable, load;
    wire [7:0] bus;

    reg8 r0 (
        .clk(clk),
        .load(load),
        .enable(enable),
        .clear(clear),
        .bus(bus),
        .bus_out(bus)
    );


endmodule