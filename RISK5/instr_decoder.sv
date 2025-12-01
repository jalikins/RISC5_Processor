module instr_decoder (
    input logic[31:0] current_instr,
    input logic clk,
    output logic[19:0] immed20
    output logic[11:0] immed12,
    output logic[6:0] op_code,
    output logic[6:0] funct7,
    output logic[2:0] funct3,
    output logic[2:0] rs2,
    output logic[2:0] rs1,
    output logic[2:0] rd
);
    // R-type
    parameter RTYPE_CODE = 7'b0110011;
    // Upper-immediate
    parameter LUI_CODE = 7'b0110111;
    parameter AUIPC_CODE = 7'b0010111;
    // Jump
    parameter JAL_CODE = 7'b1101111;
    // Jalr (actually i type)
    parameter JALR_CODE = 7'b1100111;
    // Branch
    parameter BRANCH_CODE = 7'b1100011;
    // I-type
    parameter LOAD_CODE = 7'b0000011;
    parameter LOGICI_CODE = 7'b0010011;
    // S-type
    parameter STORE_CODE = 7'b0100011;

    always_comb begin
        op_code = current_instr[25:31]

        case (op_code)
            RTYPE_CODE: begin
                funct7 = current_instr[0:6]
                funct3 = current_instr[17:19]
                rs2 = current_instr[7:11]
                rs1 = current_instr[12:16]
                rd = current_instr[20:24] // R-type instructions ???
            end
            LOGICI_CODE: begin
                immed12 = current_instr[0:11]
                funct3 = current_instr[17:19]
                rs1 = current_instr[12:16]
                rd = current_instr[20:24]
            end
            LOAD_CODE: begin
                immed12 = current_instr[0:11]
                funct3 = current_instr[17:19]
                rs1 = current_instr[12:16]
                rd = current_instr[20:24]
            end
            BRANCH_CODE: begin
                immed12 = {current_instr[0], current_instr[24], current_instr[1:6], current_instr[20:23]}
                funct3 = current_instr[17:19]
                rs2 = current_instr[7:11]
                rs1 = current_instr[12:16]
            end
            STORE_CODE: begin
                immed12 = {current_instr[0], current_instr[24], current_instr[1:6], current_instr[20:23]}
                funct3 = current_instr[17:19]
                rs2 = current_instr[7:11]
                rs1 = current_instr[12:16]
            end
            LUI_CODE: begin
                immed12 = current_instr[0:19]
                rd = current_instr[20:24]
            end
            AUIPC_CODE: begin
                immed12 = current_instr[0:19]
                rd = current_instr[20:24]
            end
        endcase
    end
endmodule