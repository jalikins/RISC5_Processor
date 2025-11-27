`include "memory.sv" 
`include "program_counter.sv" 
`include "register_file.sv" 
`include "alu.sv"
`include "instr_decoder.sv"


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
        .pc_sel         (pc_sel),
        .result         (result),
        .pc             (pc)
    );

    register_file u3 (
        .clk            (clk), 
        .rst            (rst),
        .rw             (rw),
        .rs1            (rs1),
        .rs2            (rs2),
        .rd             (rd),
        .wd             (wd),
        .rd1            (rd1),
        .rd2            (rd2)
    );

    alu u4 (
        .clk            (clk), 
        .rs1_data       (rs1_data),
        .rs2_data       (rs2_data),
        .immed12        (immed12),
        .pc             (pc), // for jump/branch
        .funct3         (funct3),
        .funct7         (funct7),
        .result         (result)
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


    always_ff @(posedge clk) begin
        if (IRWrite == 1) begin
            // get a new current_instr
            // feed inputs into ALU
            // update register file
            // update pc
        end
    end

endmodule
