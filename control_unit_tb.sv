`timescale 1ns/1ps
`include "control_unit.sv"

module control_unit_tb;

    logic [1:0] PCSrc;
    logic [1:0] ResultSrc;
    logic MemWrite, ALUSrc, RegWrite;
    logic [4:0] ALUControl;
    logic [2:0] ImmSrc;
    logic [31:0] Instr;
    logic Zero, Negative;
    
    control_unit dut (PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite,
    ALUControl, ImmSrc, Instr, Zero, Negative);
    
    initial begin
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);
        
        // Test 1: R-type add instruction
        // R-type add: opcode = 7'b0110011, funct3 = 3'b000, funct7 = 7'b0000000
        Instr = 32'd0;
        Instr[6:0]    = 7'b0110011;
        Instr[14:12]  = 3'b000;
        Instr[31:25]  = 7'b0000000;
        Zero = 0; 
        Negative = 0;
        #20;
        $display("Test 1 (R-type add): PCSrc=%b, ResultSrc=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, ALUControl=%b, ImmSrc=%b", 
                PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc);
        
        // Test 2: I-type andi instruction
        // I-type: opcode = 7'b0010011, funct3 = 3'b111
        Instr[6:0]    = 7'b0010011;
        Instr[14:12]  = 3'b111;
        #20;
        $display("Test 2 (I-type andi): PCSrc=%b, ResultSrc=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, ALUControl=%b, ImmSrc=%b", 
                PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc);
        
        // Test 3: S-type sw instruction
        // sw: opcode = 7'b0100011, funct3 = 3'b010
        Instr[6:0]    = 7'b0100011;
        Instr[14:12]  = 3'b010;
        #20;
        $display("Test 3 (S-type sw): PCSrc=%b, ResultSrc=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, ALUControl=%b, ImmSrc=%b", 
                PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc);
        
        // Test 4: B-type beq instruction
        // Branch: opcode = 7'b1100011, funct3 = 3'b000
        Instr[6:0]    = 7'b1100011;
        Instr[14:12]  = 3'b000;
        // Set the Zero flag to simulate equality (thus branch taken)
        Zero = 1; 
        Negative = 0;
        #20;
        $display("Test 4 (B-type beq): PCSrc=%b, ResultSrc=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, ALUControl=%b, ImmSrc=%b", 
                PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc);
        
        // Test 5: J-type jal instruction
        // jal: opcode = 7'b1101111. No funct3/funct7 required.
        Instr[6:0]    = 7'b1101111;
        #20;
        $display("Test 5 (J-type jal): PCSrc=%b, ResultSrc=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, ALUControl=%b, ImmSrc=%b", 
                PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc);
        
        // Test 6: U-type lui instruction
        // lui: opcode = 7'b0110111. For lui, the immediate is loaded directly.
        Instr[6:0]    = 7'b0110111;
        // In this case, funct3/funct7 are not used.
        #20;
        $display("Test 6 (U-type lui): PCSrc=%b, ResultSrc=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, ALUControl=%b, ImmSrc=%b", 
                PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc);
    

        $finish;
    end
    
endmodule
