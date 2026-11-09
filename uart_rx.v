module uart_rx #(
    parameter integer CLKS_PER_BIT = 16
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    output reg [7:0] rx_data,
    output reg rx_done,
    output reg framing_error
);
    localparam IDLE=2'd0, START=2'd1, DATA=2'd2, STOP=2'd3;
    reg [1:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            shift_reg <= 0;
            rx_data <= 0;
            rx_done <= 0;
            framing_error <= 0;
        end else begin
            rx_done <= 0;
            framing_error <= 0;
            case (state)
                IDLE: if (!rx) begin
                    state <= START;
                    clk_count <= 0;
                end
                START: begin
                    if (clk_count == (CLKS_PER_BIT/2)) begin
                        if (!rx) begin
                            clk_count <= 0;
                            bit_index <= 0;
                            state <= DATA;
                        end else state <= IDLE;
                    end else clk_count <= clk_count + 1'b1;
                end
                DATA: begin
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        shift_reg[bit_index] <= rx;
                        if (bit_index == 7) state <= STOP;
                        else bit_index <= bit_index + 1'b1;
                    end else clk_count <= clk_count + 1'b1;
                end
                STOP: begin
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        if (rx) begin
                            rx_data <= shift_reg;
                            rx_done <= 1;
                        end else framing_error <= 1;
                        state <= IDLE;
                    end else clk_count <= clk_count + 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
