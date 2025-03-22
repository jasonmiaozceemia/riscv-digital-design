module program_counter (output logic [31:0] PC, PCPlus4,
                        input logic [31:0] PCTarget, ALUResult,
                        input logic [1:0] PCSrc, 
                        input logic Reset, CLK);

    logic [31:0] PCNext;
    assign PCPlus4 = PC + 32'd4;

    always_comb begin
      case (PCSrc)
          2'b00: PCNext = PCPlus4;
          2'b01: PCNext = PCTarget;
          2'b10: PCNext = ALUResult;
          default: PCNext = PCPlus4;
      endcase
    end

    always_ff @(posedge CLK) begin
      if (Reset)
          PC <= 32'h0000_0000;
      else
          PC <= PCNext;
    end

endmodule
