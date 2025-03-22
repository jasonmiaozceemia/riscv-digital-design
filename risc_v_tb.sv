`timescale 1ns/1ps
`include "risc_v.sv"

module risc_v_tb;

    logic [31:0] CPUOut;
    logic CLK, Reset;
    logic [31:0] CPUIn;

    risc_v dut (CPUOut, CLK, Reset, CPUIn);

    // Clock generation: 20 ns period
    initial begin
        CLK = 0;
        forever #10 CLK = ~CLK;
    end

    initial begin
        $dumpfile("risc_v_tb.vcd");
        $dumpvars(0, risc_v_tb);

        Reset = 1;
        CPUIn = 32'h0000001F;
        #10; 
        Reset = 0;

        #1000;
        $finish;
    end

    initial begin
        $monitor("Time=%0t | Reset=%b | CPUIn=%h | CPUOut=%h", 
                $time, Reset, CPUIn, CPUOut);
    end

endmodule
