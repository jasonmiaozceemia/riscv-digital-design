module control_unit (output logic [1:0] PCSrc, 
                    output logic [1:0] ResultSrc,
                    output logic MemWrite, ALUSrc, RegWrite,
                    output logic [4:0] ALUControl,
                    output logic [2:0] ImmSrc,
                    input logic [31:0] Instr,
                    input logic Zero, Negative);

    // Extract instruction fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    assign opcode = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7 = Instr[31:25];

    // Combinational block to generate control signals based on the instruction
    always_comb begin
        // Default safe values
        PCSrc     = 2'b00;
        ResultSrc = 2'b00;
        MemWrite  = 1'b0;
        ALUSrc    = 1'b0;
        RegWrite  = 1'b0;
        ALUControl = 5'b00000;
        ImmSrc    = 3'b000;
        
        // Decode based on opcode
        case (opcode)
            // R-type instructions (add, sub, or, and, sll, srl, slt)
            7'b0110011: begin
                RegWrite  = 1;         // Write result to register
                ALUSrc    = 0;         // Both operands from registers
                MemWrite  = 0;
                ResultSrc = 2'b01;      // Select ALU output
                PCSrc     = 2'b00;      // PC+4 (sequential)
                // Immediate is not used; set ImmSrc to a default value.
                ImmSrc    = 3'b000;
                case (funct3)
                    3'b000: begin       // add or sub
                    if (funct7 == 7'b0000000)
                        ALUControl = 5'b00010; // add (pattern: X0X10)
                    else
                        ALUControl = 5'b01010; // sub (pattern: X1X10)
                    end
                    3'b110: ALUControl = 5'b00111; // or  (pattern: XX111)
                    3'b111: ALUControl = 5'b00011; // and (pattern: XX011)
                    3'b001: ALUControl = 5'b00000; // sll (pattern: 0XX00)
                    3'b101: ALUControl = 5'b10000; // srl (pattern: 1XX00)
                    3'b010: ALUControl = 5'b00001; // slt (pattern: XXX01)
                    default: ALUControl = 5'b00000;
                endcase
            end
            
            // I-type arithmetic instructions (addi, ori, andi, slli, srli, slti)
            7'b0010011: begin
                RegWrite  = 1;
                ALUSrc    = 1;         // Second operand from immediate
                MemWrite  = 0;
                ResultSrc = 2'b01;
                PCSrc     = 2'b00;
                ImmSrc    = 3'b000;    // I-type immediate (Instr[31:20])
                case (funct3)
                    3'b000: ALUControl = 5'b00010; // addi
                    3'b110: ALUControl = 5'b00111; // ori
                    3'b111: ALUControl = 5'b00011; // andi
                    3'b001: ALUControl = 5'b00000; // slli
                    3'b101: ALUControl = 5'b10000; // srli
                    3'b010: ALUControl = 5'b00001; // slti
                    default: ALUControl = 5'b00000;
                endcase
            end
            
            // Load Word (lw)
            7'b0000011: begin
                RegWrite  = 1;         // Write loaded data to register
                ALUSrc    = 1;         // Use immediate for effective address
                MemWrite  = 0;
                ResultSrc = 2'b10;      // Data from memory
                PCSrc     = 2'b00;
                ImmSrc    = 3'b000;     // I-type immediate
                ALUControl = 5'b00010;  // Add to compute address
            end
            
            // Store Word (sw)
            7'b0100011: begin
                RegWrite  = 0;         // Do not write back to register file
                ALUSrc    = 1;         // Immediate for effective address
                MemWrite  = 1;         // Enable memory write
                ResultSrc = 2'b00;      // Don't care; assign default
                PCSrc     = 2'b00;
                ImmSrc    = 3'b001;     // S-type immediate
                ALUControl = 5'b00010;  // Addition to compute address
            end
            
            // Branch instructions (beq, bne, blt, bge)
            7'b1100011: begin
                RegWrite  = 0;
                ALUSrc    = 0;         // Compare two registers
                MemWrite  = 0;
                ImmSrc    = 3'b010;     // B-type immediate for branch offset
                ALUControl = 5'b01010;  // Use subtraction to compare operands
                // For branches, decide PCSrc based on branch condition:
                case (funct3)
                    3'b000: PCSrc = (Zero)      ? 2'b01 : 2'b00; // beq: branch if equal
                    3'b001: PCSrc = (!Zero)     ? 2'b01 : 2'b00; // bne: branch if not equal
                    3'b100: PCSrc = (Negative)  ? 2'b01 : 2'b00; // blt: branch if less than
                    3'b101: PCSrc = (!Negative) ? 2'b01 : 2'b00; // bge: branch if greater or equal (simple model)
                    default: PCSrc = 2'b00;
                endcase
                // ResultSrc is not used in branches.
                ResultSrc = 2'b00;
            end
            
            // Jump and Link (jal)
            7'b1101111: begin
                RegWrite  = 1;         // Write return address (PC+4) to register
                // ALUSrc is don't care here (not used)
                ALUSrc = 0;
                MemWrite  = 0;
                ResultSrc = 2'b11;
                PCSrc     = 2'b01;      // Jump target selected
                ImmSrc    = 3'b100;     // J-type immediate
                ALUControl = 5'b00000;  // Don’t care
            end
            
            // Jump and Link Register (jalr)
            7'b1100111: begin
                RegWrite  = 1;
                ALUSrc    = 1;         // Immediate used to compute target from rs1
                MemWrite  = 0;
                ResultSrc = 2'b11;
                PCSrc     = 2'b10;
                ImmSrc    = 3'b000;     // I-type immediate
                ALUControl = 5'b00010;
            end
            
            // Load Upper Immediate (lui)
            7'b0110111: begin
                RegWrite  = 1;
                // ALUSrc is don’t care (immediate value is directly output)
                ALUSrc = 0;
                MemWrite  = 0;
                ResultSrc = 2'b00;      // Result comes directly from the immediate extension
                PCSrc     = 2'b00;
                ImmSrc    = 3'b011;     // U-type immediate
                ALUControl = 5'b00000;  // Don’t care
            end
            
            // Default case: safe values for unsupported opcodes
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

endmodule
