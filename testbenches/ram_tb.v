`timescale 1ns/1ps

module ram_tb;

    reg        clk, clear, load_address, ram_in, ram_out;
    reg        bus_override;
    reg  [7:0] bus_override_word;
    wire [7:0] bus;
    integer i;

    assign bus = (bus_override) ? bus_override_word : 8'bz;

    ram ram (
        .clk(clk),
        .clear(clear),
        .load_address(load_address),
        .ram_in(ram_in),
        .ram_out(ram_out),
        .bus_in(bus),
        .bus_out(bus)
    );

    task write_address;
        input [3:0] address;
        begin
            bus_override = 1;
            load_address = 1;
            bus_override_word = {4'b0, address};
            #11;
            load_address = 0;
            #1 bus_override = 0;
            if (ram.address !== address) $error;
        end
    endtask

    task sta;
        input [3:0] address;
        input [7:0] data;
        begin
            write_address(address);
            bus_override = 1;
            bus_override_word = data;
            ram_in = 1;
            #11;
            ram_in = 0;
            #1 bus_override = 0;
            if (ram.ram_byte !== data) $error;
        end
    endtask;

    task lda;
        input [3:0] address;
        input [7:0] data;
        begin
            write_address(address);
            ram_out = 1;
            #1 if (bus !== data) $error;
            ram_out = 0;
        end
    endtask

    initial begin
        $dumpfile("ram_tb.vcd");
        $dumpvars(0, ram_tb);

        {clk, clear, load_address, ram_in, ram_out, bus_override} = 0;
        for (i = 0; i < 16; i = i + 1)
            ram.ram[i] = 8'b0;

        // test writing to memory address register
        #1 write_address(4'd1);
        #1 write_address(4'd15);
        clear = 1; #1 clear = 0;

        // write to ram
        #1 sta(4'd0, 8'hfe);
        sta(4'd15, 8'h69);        

        // verify memory contents
        lda(4'd0, 8'hfe);
        lda(4'd15, 8'h69);

        // check loading from file
        $readmemh("testbenches/mem_tb.hex", ram.ram);
        lda(4'd0, 8'h01);
        lda(4'd7, 8'hef);
        lda(4'd8, 8'h01);
        lda(4'd15, 8'hef);

        #1 $finish;
    end

    always #5 clk = ~clk;

endmodule