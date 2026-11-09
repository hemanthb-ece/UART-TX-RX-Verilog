`timescale 1ns/1ps
module uart_tb;
    localparam CLKS_PER_BIT = 8;
    reg clk, rst, tx_start;
    reg [7:0] tx_data;
    wire tx, tx_busy;
    wire [7:0] rx_data;
    wire rx_done, framing_error;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) tx_unit(
        .clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx), .tx_busy(tx_busy)
    );
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_unit(
        .clk(clk), .rst(rst), .rx(tx), .rx_data(rx_data),
        .rx_done(rx_done), .framing_error(framing_error)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);
        clk=0; rst=1; tx_start=0; tx_data=8'h00;
        #20 rst=0;
        @(negedge clk);
        tx_data=8'hA5; tx_start=1;
        @(negedge clk);
        tx_start=0;
        wait(rx_done);
        #1;
        if (rx_data !== 8'hA5)
            $display("FAIL: expected A5, received %h", rx_data);
        else
            $display("PASS: UART loopback received %h", rx_data);
        if (framing_error) $display("FAIL: framing error detected");
        #20 $finish;
    end

    initial begin
        #5000;
        $display("TIMEOUT: UART test did not complete");
        $finish;
    end
endmodule
