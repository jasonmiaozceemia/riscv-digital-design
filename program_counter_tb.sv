`timescale 1ns/1ps
`include "program_counter.sv"

module program_counter_tb;

logic [31:0] PC, PCPlus4;
logic [31:0] PCTarget, ALUResult;
logic [1:0]  PCSrc;
logic Reset, CLK;

program_counter dut (PC, PCPlus4, PCTarget, ALUResult, PCSrc, Reset, CLK);

// Clock generation: a 10 ns period clock
initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
end


initial begin
    $dumpfile("program_counter_tb.vcd");
    $dumpvars(0, program_counter_tb);

    Reset     = 1;
    PCSrc     = 2'b00;          // Start with sequential PC (PC+4)
    PCTarget  = 32'h0000_0100;   // Example branch target
    ALUResult = 32'h0000_0200;   // Example jump target

    // Apply reset for one clock cycle
    #10;
    Reset = 0;

    // Allow PC to update in sequential mode for a few cycles
    #30;

    // Change PCSrc to branch target (01)
    PCSrc = 2'b01;
    #20;

    // Change PCSrc to ALUResult (jump target) (10)
    PCSrc = 2'b10;
    #20;

    // Go back to sequential mode (PC+4)
    PCSrc = 2'b00;
    #20;

    $finish;
end


initial begin
    $monitor("t=%3d | Reset=%b | CLK=%d | PC=%h | PCPlus4=%h | PCSrc=%b | PCTarget=%h | ALUResult=%h", 
            $time, Reset, CLK, PC, PCPlus4, PCSrc, PCTarget, ALUResult);
end

endmodule
