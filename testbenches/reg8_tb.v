`timescale 1ns/1ns

module reg8_tb2;

    reg load, enable, clk, clear;
    reg bus_override;
    reg [7:0] bus_override_word;
    wire [7:0] bus;

    assign bus = bus_override ? bus_override_word : 8'bz;

    task write_to_register;
        input [7:0] data;
        begin
            bus_override_word = data;
            bus_override = 1;
            load = 1;
            #10;
            load = 0;
            #1;
            bus_override = 0;
            bus_override_word = 8'bz;
            #1;
        end
    endtask

    reg8 r0 (
        .clk(clk),
        .load(load),
        .enable(enable),
        .clear(clear),
        .bus(bus),
        .bus_out(bus)
    );

    initial begin
        $dumpfile("reg8_tb.vcd");
        $dumpvars(0, reg8_tb2);

        bus_override = 0;
        clk = 0;
        enable = 0;
        load = 0;
        clear = 1;
        #1 clear = 0;
        if (r0.data != 0) $error(1, "Test failed: expected clear register, got %h at time %0t", r0.data, $time);

        // load data from bus
        write_to_register(8'hfe);
        if (r0.data !== 8'hFE) $error(1, "Test failed: expected 0xFE, got %h at time %0t", r0.data, $time);
        
        // output data onto bus
        #10 enable = 1;
        #1 if (bus !== 8'hFE) $error(3, "Test failed: expected register to output 0xFE onto the bus, got %h at time %0t", bus, $time);
        #9 enable = 0;

        // read new data from the bus
        write_to_register(8'h69);
        if (r0.data !== 8'h69) $error(4, "Test failed: expected 0x69, got %h at time %0t", r0.data, $time);

        // clear register
        #10 clear = 1;
        #10 clear = 0;
        if (r0.data != 0) $error(1, "Test failed: expected clear register, got %h at time %0t", r0.data, $time);

        #10 $finish;
    end

    always #5 clk = ~clk;

endmodule