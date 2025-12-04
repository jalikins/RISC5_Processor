`include "memory\memory.sv" 
`include "program_counter.sv" 
`include "register_file.sv" 
`include "ALU_unit.sv"
`include "instr_decoder.sv"
`include "immediate_extender.sv"
`include "controller.sv"


module top(
    input logic     clk, 
    output logic    RGB_R, 
    output logic    RGB_G,
    output logic    RGB_B,
    output logic    LED
);
    logic[31:0] current_instr;
    logic[6:0] op_code;
    logic[2:0] funct3;
    logic[6:0] funct7;
    logic[4:0] rs1;
    logic[4:0] rs2;
    logic[4:0] rd;
    logic[11:0] immed12;
    logic[19:0] immed20;

    logic[31:0] ALU_out;
    logic[31:0] data;
// mem vars
    logic[31:0] write_address;
    logic[31:0] write_data;
    logic[31:0] read_address;
    logic[31:0] read_data;
//pc vars
    logic PCUpdate;
    logic[31:0] result;
    logic[31:0] old_pc;
    logic[31:0] current_pc;
// reg vars
    logic[31:0] rs1_data;
    logic[31:0] rs2_data;
// ALU unit vars
    logic[31:0] immed_ext;
    logic[3:0] ALU_control;
    logic[31:0] ALU_result;
    logic zero;
    logic sign;
// ImmedExt vars
    logic[1:0] ImmSrc;
//controller vars
    logic[1:0] ALUSrcA;
    logic[1:0] ALUSrcB;
    logic[1:0] ResultSrc;
    logic AdrSrc;
    logic MemWrite;
    logic IRWrite;
    logic RegWrite;

    initial begin
        result = 32'b0; // lowest point in instr memory
    end


    memory #(
        .INIT_FILE      ("rv32i_test.txt") // Assign at some point
    ) u1 (
        .clk             (clk), 
        .write_mem       (write_mem),
        .funct3          (funct3), 
        .write_address   (write_address), 
        .write_data      (write_data), 
        .read_address    (read_address),
// output logic
        .read_data       (read_data),
        .led             (led),     
        .red             (red),            
        .green           (green),          
        .blue            (blue)
    );

    program_counter u2 (  
        .clk            (clk), 
        .PCUpdate       (PCUpdate),
        .result         (result),
        .old_pc         (old_pc),
        .current_pc     (current_pc)
    );

    register_file u3 (
        .clk            (clk), 
        .rs1            (rs1),
        .rs2            (rs2),
        .rd             (rd),
        .result         (result),
        .rs1_data       (rs1_data),
        .rs2_data       (rs2_data)
    );

    ALU_unit u4 (
        .clk            (clk),
        .ALUSrcA        (ALUSrcA),
        .ALUSrcB        (ALUSrcB), 
        .rs1_data       (rs1_data),
        .rs2_data       (rs2_data),
        .immed_ext      (immed_ext),
        .old_pc         (old_pc), // for jump/branch
        .current_pc     (current_pc),
        .ALU_control    (ALU_control),
        .zero           (zero),
        .ALU_result     (ALU_result),
        .sign           (sign)
    );

    instr_decoder u5 (
//        .clk            (clk), 
        .current_instr  (current_instr),
        .immed20        (immed20),
        .immed12        (immed12),
        .op_code        (op_code),
        .funct7         (funct7),
        .fun7           (fun7),
        .funct3         (funct3),
        .rs1            (rs1),
        .rs2            (rs2),
        .rd             (rd)
    );

    immediate_extender u6 (
        .clk            (clk),
        .immed12        (immed12),
        .immed20        (immed20),
        .ImmSrc         (ImmSrc),
        .immed_ext      (immed_ext)
    );

    controller u7 (
        .clk            (clk),
        .op_code        (op_code),
        .fun7           (fun7),
        .funct3         (funct3),
        .zero           (zero), // checks if ALU out is 0
        .sign           (sign),

        .ALU_control    (ALU_control),
        .ALUSrcA        (ALUSrcA),
        .ALUSrcB        (ALUSrcB),
        .ImmSrc         (ImmSrc),
        .ResultSrc      (ResultSrc),
        .PCUpdate       (PCUpdate),
        .AdrSrc         (AdrSrc),
        .MemWrite       (MemWrite),
        .IRWrite        (IRWrite),
        .RegWrite       (RegWrite)
    );

    always_ff @(posedge clk) begin
        if (MemWrite == 1'b0) begin
            case (AdrSrc) 
                1'b0: read_address = current_pc;
                1'b1: read_address = result;
            endcase
        end else if (MemWrite == 1'b1) begin
            case (AdrSrc) 
                1'b0: write_address = current_pc;
                1'b1: write_address = result;
            endcase
            write_data = rs2_data;
        end
        if (IRWrite) begin
            current_instr = read_data; // Current instruction is the data we read form instr mem
        end
        case (ResultSrc) 
            2'b00: result <= ALU_out;
            2'b01: result <= read_data;
            2'b10: result <= ALU_result;
            2'b11: result <= immed_ext;
        endcase
        ALU_out <= ALU_result;
        data <= read_data;
    end

endmodule
