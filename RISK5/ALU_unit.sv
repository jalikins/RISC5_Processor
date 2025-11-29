module ALU_unit(
    input [31:0] A,
    input [31:0] B,
    input [3:0] alu_control,
    output reg zero,
    output reg[31:0] alu_result
);
    always_comb begin
        case (alu_control)
           4'b0010: alu_result = A + B; // ADD
           4'b0110: alu_result = A - B; // SUB
           4'b0000: alu_result = A & B; // AND
           4'b0001: alu_result = A | B; // OR
           4'b0011: alu_result = A ^ B; // XOR
           4'b0100: alu_result = A << B[4:0]; // SLL
           4'b0101: alu_result = A >> B[4:0]; // SRL
           4'b0111: alu_result = $signed(A) >>> B[4:0]; // SRA 
           4'b1100: alu_result = (A < B) ? 32'b1 : 32'b0; // SLT wrong need to figure out

            default: alu_result = 32'b0;
        endcase

        // zero flag
        zero = (alu_result == 32'b0) ? 1'b1 : 1'b0;
    end


endmodule