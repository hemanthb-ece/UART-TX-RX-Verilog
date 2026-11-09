# Major Project 2 – UART Transmitter and Receiver

## Objective
Design and simulate UART serial transmission and reception using Verilog. The transmitter and receiver are connected in a loopback testbench.

## UART frame
- 1 start bit (logic 0)
- 8 data bits, least-significant bit first
- 1 stop bit (logic 1)
- No parity bit in this implementation

## Files
- `uart_tx.v` – UART transmitter.
- `uart_rx.v` – UART receiver with mid-start-bit validation and stop-bit check.
- `uart_tb.v` – loopback testbench; sends byte `0xA5` and checks the received byte.
- `Makefile` – compile, run and waveform targets.

## Baud-rate parameter
`CLKS_PER_BIT` is the number of system-clock cycles per serial bit. For a 50 MHz clock and 9600 baud, use approximately 5208. The RTL default and testbench use a small value (16 and 8 respectively) to keep simulation quick; set the parameter to match your actual clock and baud rate for hardware use.

## Run
```bash
make
make wave
```

Manual commands:

```bash
iverilog -g2012 -o uart_sim uart_tx.v uart_rx.v uart_tb.v
vvp uart_sim
gtkwave uart.vcd
```

This is a simulation-level loopback design. FPGA pin constraints, synthesis and hardware testing are separate optional steps.
