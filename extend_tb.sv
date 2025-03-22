`timescale 1ns/1ps
`include "extend.sv"

module extend_tb;

    logic [31:0] ImmExt;
    logic [31:0] Instr;
    logic [2:0]  ImmSrc;

    extend dut (ImmExt, Instr, ImmSrc);
    
    initial begin
        $dumpfile("extend_tb.vcd");
        $dumpvars(0, extend_tb);
        
        // Test 1: I-Type immediate extension (ImmSrc = 3'b000)
        // Expect sign extension of Instr[31:20]
        Instr = 32'hFFF12345;  // For example, negative immediate value.
        ImmSrc = 3'b000;
        #20;
        $display("Test 1 (I-Type): Instr = %h, ImmExt = %h, ImmSrc = %b", Instr, ImmExt, ImmSrc);
        
        // Test 2: S-Type immediate extension (ImmSrc = 3'b001)
        // Immediate formed by {Instr[31:25], Instr[11:7]} with sign extension.
        Instr = 32'd0;
        Instr[31:25] = 7'b1010101;
        Instr[11:7]  = 5'b01010;
        ImmSrc = 3'b001;
        #20;
        $display("Test 2 (S-Type): Instr = %h, ImmExt = %h, ImmSrc = %b", Instr, ImmExt, ImmSrc);
        
        // Test 3: B-Type immediate extension (ImmSrc = 3'b010)
        // Expected immediate: { {19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0 }
        Instr = 32'd0;
        Instr[31]    = 1;       // Negative offset
        Instr[7]     = 0;
        Instr[30:25] = 6'b111100;
        Instr[11:8]  = 4'b1010;
        ImmSrc = 3'b010;
        #20;
        $display("Test 3 (B-Type): Instr = %h, ImmExt = %h, ImmSrc = %b", Instr, ImmExt, ImmSrc);
        
        // Test 4: U-Type immediate extension (ImmSrc = 3'b011)
        // Expected immediate: {Instr[31:12], 12'b0}
        Instr = 32'hABCDEF00;
        ImmSrc = 3'b011;
        #20;
        $display("Test 4 (U-Type): Instr = %h, ImmExt = %h, ImmSrc = %b", Instr, ImmExt, ImmSrc);
        
        // Test 5: J-Type immediate extension (ImmSrc = 3'b100)
        // Expected immediate: { {12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0 }
        Instr = 32'd0;
        Instr[31]    = 1;
        Instr[19:12] = 8'h5A;
        Instr[20]    = 1;
        Instr[30:21] = 10'b1010101010;
        ImmSrc = 3'b100;
        #20;
        $display("Test 5 (J-Type): Instr = %h, ImmExt = %h, ImmSrc = %b", Instr, ImmExt, ImmSrc);
        
        $finish;
  end

endmodule
