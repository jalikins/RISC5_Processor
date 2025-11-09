module ALU_unit(
    input [31:0] A,
    input [31:0] B,
    input [3:0] alu_control,
    output reg zero,
    output reg[31:0] alu_result
);
    always_comb begin
        case (alu_control)
            4'b0000: alu_result = A & B; // AND
            4'b0001: alu_result = A | B; // OR
            4'b0010: alu_result = A + B; // ADD
            4'b0110: alu_result = A - B; // SUBTRACT
            4'b0111: alu_result = (A < B) ? 1 : 0; // SET LESS THAN
            4'b1100: alu_result = ~(A | B); // NOR
            default: alu_result = 32'b0; // DEFAULT
        endcase

        zero = (alu_result == 32'b0) ? 1'b1 : 1'b0;
    end


endmodule