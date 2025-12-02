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
    logic[5:0] rs1;
    logic[5:0] rs2;
    logic[5:0] rd;
    logic[11:0] immed12;
    logic[19:0] immed20;

    logic load_new; // Signal to load a new instruction 

    memory#(
        .INIT_FILE      ("") // Assign at some point
    ) u1 (
        .clk         (clk), 
        .write_mem       (write_mem),
        .funct3          (funct3), 
        .write_address   (write_address), 
        .write_data      (write_data), 
        .read_address    (read_address),
        .read_data       (read_data),
        .led             (led),     
        .red             (red),            
        .green           (green),          
        .blue            (blue)
    );

    program_counter u2 (  
        .clk            (clk), 
        .PCWrite        (PCWrite),
        .result         (result),
        .current_pc     (current_pc),
    );

    register_file u3 (
        .clk            (clk), 
        .result         (result),
        .rs1            (rs1),
        .rs2            (rs2),
        .rd             (rd),
        .result         (result),
        .rs1_data       (rs1_data),
        .rs2_data       (rs2_data)
    );

    ALU_unit u4 (
        .clk            (clk), 
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
        .clk            (clk), 
        .current_instr  (current_instr),
        .immed20        (immed20),
        .immed12        (immed12),
        .op_code        (op_code),
        .funct7         (funct7),
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
        .PCWrite        (PCWrite),
        .AdrSrc         (AdrSrc),
        .MemWrite       (MemWrite),
        .IRWrite        (IRWrite),
        .RegWrite       (RegWrite),
    );

    always_ff @(posedge clk) begin
        if (PCWrite == 1'b1) begin
            old_pc <= current_pc;
            current_pc <= result;
        end
        if (memwrite == 1'b0) begin
            case (AdrSrc) 
                1'b0: read_address = current_pc;
                1'b1: read_address = result;
            endcase
        end else if (memwrite == 1'b1) begin
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
            2'b00: result = ALU_out;
            2'b01: result = data;
            2'b10: reult = result;
        endcase
        ALU_out <= ALU_result;
        data <= read_data;
    end

endmodule
