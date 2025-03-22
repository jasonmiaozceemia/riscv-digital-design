`timescale 1ns/1ps
`include "alu.sv"

module alu_tb;
    logic signed [31:0] ALUResult;
    logic Zero, Negative;
    logic signed [31:0] SrcA, SrcB;
    logic [4:0] ALUControl;
    
    alu dut (ALUResult, Zero, Negative, SrcA, SrcB, ALUControl);
    
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
        
        // Test 1: Addition (ALUControl = 5'b00010)
        SrcA = 32'sd10;
        SrcB = 32'sd20;
        ALUControl = 5'b00010;
        #20;
        $display("Test 1 (Addition): SrcA = %0d, SrcB = %0d, ALUResult = %0d, Zero = %0b, Negative = %0b", 
                SrcA, SrcB, ALUResult, Zero, Negative);
        
        // Test 2: Subtraction (ALUControl = 5'b01010)
        SrcA = 32'sd20;
        SrcB = 32'sd10;
        ALUControl = 5'b01010;
        #20;
        $display("Test 2 (Subtraction): SrcA = %0d, SrcB = %0d, ALUResult = %0d, Zero = %0b, Negative = %0b", 
                SrcA, SrcB, ALUResult, Zero, Negative);
        
        // Test 3: Bitwise OR (ALUControl = 5'b00111)
        SrcA = 32'h0F0F0F0F;
        SrcB = 32'hF0F0F0F0;
        ALUControl = 5'b00111;
        #20;
        $display("Test 3 (Bitwise OR): SrcA = %08h, SrcB = %08h, ALUResult = %08h", 
                SrcA, SrcB, ALUResult);
        
        // Test 4: Bitwise AND (ALUControl = 5'b00011)
        SrcA = 32'h0F0F0F0F;
        SrcB = 32'hF0F0F0F0;
        ALUControl = 5'b00011;
        #20;
        $display("Test 4 (Bitwise AND): SrcA = %08h, SrcB = %08h, ALUResult = %08h", 
                SrcA, SrcB, ALUResult);
        
        // Test 5: Shift Left Logical (SLL) (ALUControl = 5'b00000)
        SrcA = 32'h00000001;
        // For shift, only the lower 5 bits of SrcB are used; here we shift by 2.
        SrcB = 32'd2;
        ALUControl = 5'b00000;
        #20;
        $display("Test 5 (Shift Left Logical): SrcA = %08h, SrcB = %08d, ALUResult = %08h", 
                SrcA, SrcB, ALUResult);
        
        // Test 6: Shift Right Logical (SRL) (ALUControl = 5'b10000)
        SrcA = 32'h80000000; // Negative value in 2's complement, for observing the shift.
        SrcB = 32'd2;
        ALUControl = 5'b10000;
        #20;
        $display("Test 6 (Shift Right Logical): SrcA = %08h, SrcB = %08d, ALUResult = %08h", 
                SrcA, SrcB, ALUResult);
        
        // Test 7: Set Less Than (SLT) when SrcA < SrcB (ALUControl = 5'b00001)
        SrcA = 32'sd5;
        SrcB = 32'sd10;
        ALUControl = 5'b00001;
        #20;
        $display("Test 7 (SLT, SrcA < SrcB): SrcA = %0d, SrcB = %0d, ALUResult = %0d", 
                SrcA, SrcB, ALUResult);
        
        // Test 8: Set Less Than (SLT) when SrcA > SrcB (ALUControl = 5'b00001)
        SrcA = 32'sd10;
        SrcB = 32'sd5;
        ALUControl = 5'b00001;
        #20;
        $display("Test 8 (SLT, SrcA > SrcB): SrcA = %0d, SrcB = %0d, ALUResult = %0d", 
                SrcA, SrcB, ALUResult);
        
        $finish;
    end

endmodule