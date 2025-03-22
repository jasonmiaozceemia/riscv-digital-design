module alu (output logic signed [31:0] ALUResult,
            output logic Zero, Negative,
            input logic signed [31:0] SrcA, SrcB,
            input logic [4:0] ALUControl);

    // Use individual wires for each operation
    logic signed [31:0] add_result, sub_result, or_result, and_result;
    logic signed [31:0] sll_result, srl_result, slt_result;
    
    // Compute each operation using assign statements
    assign add_result = SrcA + SrcB;
    assign sub_result = SrcA - SrcB;
    assign or_result = SrcA | SrcB;
    assign and_result = SrcA & SrcB;
    assign sll_result = SrcA << SrcB[4:0];
    assign srl_result = SrcA >> SrcB[4:0];
    assign slt_result = (SrcA < SrcB) ? 32'sd1 : 32'sd0;
    
    // Mux to select the appropriate result based on ALUControl
    assign ALUResult = (ALUControl == 5'b00010) ? add_result :
                       (ALUControl == 5'b01010) ? sub_result :
                       (ALUControl == 5'b00111) ? or_result :
                       (ALUControl == 5'b00011) ? and_result :
                       (ALUControl == 5'b00000) ? sll_result :
                       (ALUControl == 5'b10000) ? srl_result :
                       (ALUControl == 5'b00001) ? slt_result : 32'sd0;
    
    // Compute flags based on the result
    assign Zero = (ALUResult == 32'sd0);
    assign Negative = ALUResult[31];

endmodule
