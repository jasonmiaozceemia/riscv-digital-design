module risc_v (output logic [31:0] CPUOut,
                input  logic CLK, Reset,
                input  logic [31:0] CPUIn);

    // Program counter
    logic [31:0] PC, PCPlus4;
    logic [31:0] PCTarget, ALUResult;
    logic [1:0] PCSrc;
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

    // Instruction memory
    logic [31:0] Instr;
    logic [7:0] IM [0:255];
    logic [31:0] prog [0:63];
    logic [31:0] PC_divided_by_4;

    initial
    $readmemh ("test_21.txt", prog);
    assign Instr = prog[PC_divided_by_4];
    assign PC_divided_by_4 = PC/4;

    // Control unit
    logic [1:0] ResultSrc;
    logic MemWrite, ALUSrc, RegWrite;
    logic [4:0] ALUControl;
    logic [2:0] ImmSrc;
    logic Zero, Negative;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    assign opcode = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7 = Instr[31:25];

    always_comb begin
        PCSrc     = 2'b00;
        ResultSrc = 2'b00;
        MemWrite  = 1'b0;
        ALUSrc    = 1'b0;
        RegWrite  = 1'b0;
        ALUControl = 5'b00000;
        ImmSrc    = 3'b000;
        
        case (opcode)
            7'b0110011: begin
                RegWrite  = 1;
                ALUSrc    = 0;
                MemWrite  = 0;
                ResultSrc = 2'b01;
                PCSrc     = 2'b00;
                ImmSrc    = 3'b000;
                case (funct3)
                    3'b000: begin
                    if (funct7 == 7'b0000000)
                        ALUControl = 5'b00010;
                    else
                        ALUControl = 5'b01010;
                    end
                    3'b110: ALUControl = 5'b00111;
                    3'b111: ALUControl = 5'b00011;
                    3'b001: ALUControl = 5'b00000;
                    3'b101: ALUControl = 5'b10000;
                    3'b010: ALUControl = 5'b00001;
                    default: ALUControl = 5'b00000;
                endcase
            end
            
            7'b0010011: begin
                RegWrite  = 1;
                ALUSrc    = 1;
                MemWrite  = 0;
                ResultSrc = 2'b01;
                PCSrc     = 2'b00;
                ImmSrc    = 3'b000;
                case (funct3)
                    3'b000: ALUControl = 5'b00010;
                    3'b110: ALUControl = 5'b00111;
                    3'b111: ALUControl = 5'b00011;
                    3'b001: ALUControl = 5'b00000;
                    3'b101: ALUControl = 5'b10000;
                    3'b010: ALUControl = 5'b00001;
                    default: ALUControl = 5'b00000;
                endcase
            end

            7'b0000011: begin
                RegWrite  = 1;
                ALUSrc    = 1;
                MemWrite  = 0;
                ResultSrc = 2'b10;
                PCSrc     = 2'b00;
                ImmSrc    = 3'b000;
                ALUControl = 5'b00010;
            end

            7'b0100011: begin
                RegWrite  = 0;
                ALUSrc    = 1;
                MemWrite  = 1;
                ResultSrc = 2'b00;
                PCSrc     = 2'b00;
                ImmSrc    = 3'b001;
                ALUControl = 5'b00010;
            end

            7'b1100011: begin
                RegWrite  = 0;
                ALUSrc    = 0;
                MemWrite  = 0;
                ImmSrc    = 3'b010;
                ALUControl = 5'b01010;
                case (funct3)
                    3'b000: PCSrc = (Zero)      ? 2'b01 : 2'b00;
                    3'b001: PCSrc = (!Zero)     ? 2'b01 : 2'b00;
                    3'b100: PCSrc = (Negative)  ? 2'b01 : 2'b00;
                    3'b101: PCSrc = (!Negative) ? 2'b01 : 2'b00;
                    default: PCSrc = 2'b00;
                endcase
                ResultSrc = 2'b00;
            end

            7'b1101111: begin
                RegWrite  = 1;
                ALUSrc = 0;
                MemWrite  = 0;
                ResultSrc = 2'b11;
                PCSrc     = 2'b01;
                ImmSrc    = 3'b100;
                ALUControl = 5'b00000;
            end

            7'b1100111: begin
                RegWrite  = 1;
                ALUSrc    = 1;
                MemWrite  = 0;
                ResultSrc = 2'b11;
                PCSrc     = 2'b10;
                ImmSrc    = 3'b000;
                ALUControl = 5'b00010;
            end

            7'b0110111: begin
                RegWrite  = 1;
                ALUSrc = 0;
                MemWrite  = 0;
                ResultSrc = 2'b00;
                PCSrc     = 2'b00;
                ImmSrc    = 3'b011;
                ALUControl = 5'b00000;
            end

            default: begin
                PCSrc     = 2'b00;
                ResultSrc = 2'b00;
                MemWrite  = 0;
                ALUSrc    = 0;
                RegWrite  = 0;
                ALUControl = 5'b00000;
                ImmSrc    = 3'b000;
            end
        endcase
    end

    // Reg file
    logic [31:0] RD1, RD2;
    logic [31:0] WD3;
    logic [4:0] A1, A2, A3;
    logic WE3;
    logic [31:0] RF [0:31];

    assign A1 = Instr[19:15];
    assign A2 = Instr[24:20];
    assign A3 = Instr[11:7];
    assign WE3 = RegWrite;
    assign WD3 = Result;
    assign RD1 = (A1==5'b0) ? 32'b0 : RF[A1];
    assign RD2 = (A2==5'b0) ? 32'b0 : RF[A2];

    always_ff @ (posedge CLK)
    if (WE3) RF[A3] <= WD3;

    // Extend
    logic [31:0] ImmExt;
    logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;

    assign i_imm = { {20{Instr[31]}}, Instr[31:20] };
    assign s_imm = { {20{Instr[31]}}, Instr[31:25], Instr[11:7] };
    assign b_imm = { {19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0 };
    assign u_imm = { Instr[31:12], 12'b0 };
    assign j_imm = { {12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0 };

    assign ImmExt = (ImmSrc == 3'b000) ? i_imm :
                   (ImmSrc == 3'b001) ? s_imm :
                   (ImmSrc == 3'b010) ? b_imm :
                   (ImmSrc == 3'b011) ? u_imm :
                   (ImmSrc == 3'b100) ? j_imm : 32'd0;
    
    assign PCTarget = PC + ImmExt;

    // ALU
    logic signed [31:0] SrcA, SrcB;
    assign SrcA = RD1;
    assign SrcB = (ALUSrc) ? ImmExt : RD2;

    logic signed [31:0] add_result, sub_result, or_result, and_result;
    logic signed [31:0] sll_result, srl_result, slt_result;
    
    assign add_result = SrcA + SrcB;
    assign sub_result = SrcA - SrcB;
    assign or_result = SrcA | SrcB;
    assign and_result = SrcA & SrcB;
    assign sll_result = SrcA << SrcB[4:0];
    assign srl_result = SrcA >> SrcB[4:0];
    assign slt_result = (SrcA < SrcB) ? 32'sd1 : 32'sd0;
    
    assign ALUResult = (ALUControl == 5'b00010) ? add_result :
                       (ALUControl == 5'b01010) ? sub_result :
                       (ALUControl == 5'b00111) ? or_result :
                       (ALUControl == 5'b00011) ? and_result :
                       (ALUControl == 5'b00000) ? sll_result :
                       (ALUControl == 5'b10000) ? srl_result :
                       (ALUControl == 5'b00001) ? slt_result : 32'sd0;
    
    assign Zero = (ALUResult == 32'sd0);
    assign Negative = ALUResult[31];

    // Data memory and io
    logic [31:0] RD;
    logic [31:0] A, WD;
    logic WE;
    assign A = ALUResult;
    assign WD = RD2;
    assign WE = MemWrite;

    logic [7:0] DM [0:1023];
    logic RDsel, WEM, WEOut;

    assign RDsel = (A == 32'h7FFFFFFC) ? 1 : 0; 

    assign RD = (RDsel) ? CPUIn : {DM[A+3], DM[A+2], DM[A+1], DM[A]};

    always_comb
    begin
    if ((WE) & (A == 32'h7FFFFFFC)) begin
            WEOut = 1;
            WEM = 0;
        end
        else if ((WE) & (A != 32'h7FFFFFFC)) begin
            WEOut = 0;
            WEM = 1;
        end
        else begin
            WEOut = 0;
            WEM = 0;
        end        
    end

    always_ff @ (posedge CLK)
    begin
        if (WEM)  {DM [A+3], DM [A+2], DM [A+1], DM [A]} <= WD;
        if (WEOut) CPUOut <= WD;
    end

    logic [31:0] Result;
    always_comb begin
        case(ResultSrc)
            2'b00: Result = ImmExt;
            2'b01: Result = ALUResult;
            2'b10: Result = RD;
            2'b11: Result = PCPlus4;
            default: Result = ImmExt;
        endcase
    end

endmodule
