module uart_tx #(
    parameter integer CLKS_PER_BIT = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);
    reg [15:0] clk_count;
    reg [3:0] bit_index;
    reg [9:0] frame;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1;
            tx_busy <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
            frame <= 10'h3FF;
        end else begin
            if (tx_start && !tx_busy) begin
                frame <= {1'b1, tx_data, 1'b0}; // stop, data[7:0], start
                tx_busy <= 1'b1;
                clk_count <= 0;
                bit_index <= 0;
                tx <= 1'b0;
            end else if (tx_busy) begin
                if (clk_count == CLKS_PER_BIT-1) begin
                    clk_count <= 0;
                    if (bit_index == 9) begin
                        tx_busy <= 1'b0;
                        tx <= 1'b1;
                        bit_index <= 0;
                    end else begin
                        bit_index <= bit_index + 1'b1;
                        tx <= frame[bit_index + 1'b1];
                    end
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end
        end
    end
endmodule
