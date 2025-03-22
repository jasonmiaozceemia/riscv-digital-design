module extend (output logic [31:0] ImmExt,
                input logic [31:0] Instr,
                input logic [2:0] ImmSrc);

    // Use separate wires for each immediate type
    logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;
    
    // Calculate each immediate format using assign statements
    assign i_imm = { {20{Instr[31]}}, Instr[31:20] };
    assign s_imm = { {20{Instr[31]}}, Instr[31:25], Instr[11:7] };
    assign b_imm = { {19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0 };
    assign u_imm = { Instr[31:12], 12'b0 };
    assign j_imm = { {12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0 };
    
    // Use a mux to select the appropriate immediate
    assign ImmExt = (ImmSrc == 3'b000) ? i_imm :
                   (ImmSrc == 3'b001) ? s_imm :
                   (ImmSrc == 3'b010) ? b_imm :
                   (ImmSrc == 3'b011) ? u_imm :
                   (ImmSrc == 3'b100) ? j_imm : 32'd0;

endmodule
