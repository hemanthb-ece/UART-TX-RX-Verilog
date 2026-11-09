SIM=uart_sim
all:
	iverilog -g2012 -o $(SIM) uart_tx.v uart_rx.v uart_tb.v
	vvp $(SIM)
wave: all
	gtkwave uart.vcd
clean:
	rm -f $(SIM) uart.vcd
