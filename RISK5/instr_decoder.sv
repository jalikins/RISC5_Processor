module instr_decoder (
    input logic[31:0] current_instr,
    input logic clk,
    output logic[19:0] immed20,
    output logic[11:0] immed12,
    output logic[6:0] op_code,
    output logic[6:0] funct7,
    output logic fun7,
    output logic[2:0] funct3,
    output logic[4:0] rs2,
    output logic[4:0] rs1,
    output logic[4:0] rd
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

    initial begin
        funct3 = 3'b010;
    end

    always_comb begin
        op_code = current_instr[6:0];
        immed20 = '0;
        immed12 = '0;
//        op_code = current_instr[25:31];
        funct7  = '0;
        fun7    = '0;
//        funct3  = '0;
        rs2     = '0;
        rs1     = '0;
        rd      = '0;
        case (op_code)
            RTYPE_CODE: begin
//                funct7 = current_instr[0:6];
                funct7 = current_instr[31:25];
//                fun7 = current_instr[1];
                fun7 = current_instr[30];
//                funct3 = current_instr[17:19];
                funct3 = current_instr[14:12];
//                rs2 = current_instr[7:11];
                rs2 = current_instr[24:20];
//                rs1 = current_instr[12:16];
                rs1 = current_instr[19:15];
//                rd = current_instr[20:24]; // R-type instructions ???
                rd = current_instr[11:7];
            end
            LOGICI_CODE: begin
//                immed12 = current_instr[0:11];
              immed12 = current_instr[31:20];
//                funct3 = current_instr[17:19];
              funct3 = current_instr[14:12];
//                rs1 = current_instr[12:16];
              rs1 = current_instr[19:15];
//                rd = current_instr[20:24];
              rd = current_instr[11:7];
            end
            LOAD_CODE: begin
//                immed12 = current_instr[0:11];
              immed12 = current_instr[31:20];
//                funct3 = current_instr[17:19];
              funct3 = current_instr[14:12];
//                rs1 = current_instr[12:16];
              rs1 = current_instr[19:15];
//                rd = current_instr[20:24];
              rd = current_instr[11:7];
            end
            BRANCH_CODE: begin
//                immed12 = {current_instr[0], current_instr[24], current_instr[1:6], current_instr[20:23]};
                immed12 = {
                    current_instr[31],        // imm[12]
                    current_instr[7],         // imm[11]
                    current_instr[30:25],     // imm[10:5]
                    current_instr[11:8],      // imm[4:1]
                    1'b0                      // imm[0] = 0
                };
//                funct3 = current_instr[17:19];
                funct3 = current_instr[14:12];
//                rs2 = current_instr[7:11];
                rs2 = current_instr[24:20];
//                rs1 = current_instr[12:16];
                rs1 = current_instr[19:15];
            end
            STORE_CODE: begin
//                immed12 = {current_instr[0], current_instr[24], current_instr[1:6], current_instr[20:23]};
                immed12 = {current_instr[31:25], current_instr[11:7]};
//                funct3 = current_instr[17:19];
                funct3 = current_instr[14:12];
//                rs2 = current_instr[7:11];
                rs2 = current_instr[24:20];
//                rs1 = current_instr[12:16];
                rs1 = current_instr[19:15];
            end
            AUIPC_CODE,
            LUI_CODE: begin
//                immed20 = current_instr[0:19];
                immed20 = current_instr[31:12];
//                rd = current_instr[20:24];
                rd = current_instr[11:7];
            end
            JAL_CODE: begin
//                immed20 = current_instr[0:19];
                immed20 = current_instr[31:12];
//                rd = current_instr[20:24];
                rd = current_instr[11:7];
            end
            JALR_CODE: begin
//                immed12 = current_instr[0:11];
                immed12 = current_instr[31:20];
//                funct3 = current_instr[17:19];
                funct3 = current_instr[14:12];
//                rs1 = current_instr[12:16];
                rs1 = current_instr[19:15];
//                rd = current_instr[20:24];
                rd = current_instr[11:7];
            end
        endcase
    end
endmodule