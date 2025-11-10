module instr_decoder (
    input [31:0] current_instr,
    output [11:0] immed12,
    output [6:0] op_code,
    output [6:0] funct7,
    output [2:0] funct3,
    output [2:0] rs2,
    output [2:0] rs1,
    output [2:0] rd,
);
    parameter RTYPECODE = 7'b0110011;
    parameter ITYPECODE = 7'b0010011;
    parameter BTYPECODE = 7'b1100011;

    always_comb begin
        op_code = current_instr[25:31]
        funct3 = current_instr[17:19]
        if (op_code == RTYPECODE) begin
            funct7 = current_instr[0:6]
            rs2 = current_instr[7:11]
            rs1 = current_instr[12:16]
            rd = current_instr[20:24] // R-type instructions ???
        end else if (op_code == ITYPECODE) begin
            immed12 = current_instr[0:11]
            rs1 = current_instr[12:16]
            rd = current_instr[20:24]
        end else if (op_code == BTYPECODE) begin
            immed12 = {current_instr[0], current_instr[24], current_instr[1:6], current_instr[20:23]}
            rs2 = current_instr[7:11]
            rs1 = current_instr[12:16]
        end
    end
endmodule