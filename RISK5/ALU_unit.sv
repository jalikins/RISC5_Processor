module ALU_unit(
    input logic clk,
    input logic[1:0] ALUSrcA,
    input logic[1:0] ALUSrcB,
    input logic[31:0] rs1_data,
    input logic[31:0] rs2_data,
    input logic[31:0] immed_ext,
    input logic[31:0] old_pc,
    input logic[31:0] current_pc,
    input logic[3:0] ALU_control,
    output logic zero,
    output logic sign,
    output logic[31:0] ALU_result
);

    logic [31:0] A;
    logic [31:0] B;

    always_comb begin
        case (ALUSrcA)
            2'b00: A = current_pc;
            2'b01: A = old_pc;
            2'b10: A = rs1_data;
        endcase
        case (ALUSrcB)
            2'b00: B = rs2_data;
            2'b01: B = immed_ext;
            2'b10: B = 4;
        endcase
        case (ALU_control)
            4'b0000: ALU_result = $signed(A + B); // ADD (signed)
            4'b0110: ALU_result = $signed(A - B); // SUBTRACT
            4'b0010: ALU_result = A | B; // OR
            4'b0001: ALU_result = A & B; // AND
            4'b0100: ALU_result = A << B[4:0]; // SLL
            4'b0101: ALU_result = A >> B[4:0]; // SRL
            4'b0111: ALU_result = $signed(A) >>> B[4:0]; // SRA
            4'b1001: ALU_result = (A < B) ? 32'b1 : 32'b0; // SET LESS THAN Unsinged
            4'b1010: ALU_result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT signed
            4'b1100: ALU_result = ~(A | B); // NOR
            4'b1101: ALU_result = A - B; // Subtract unsigned
        endcase
        zero = (ALU_result == 32'b0) ? 1'b1 : 1'b0;
        if (ALU_result[0] == 1'b0) begin
            sign = 1'b0;
        end else begin
            sign = 1'b1;
        end
    end


endmodule