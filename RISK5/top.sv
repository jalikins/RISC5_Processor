`include "memory.sv" 
`include "program_counter.sv" 
`include "register_file.sv" 
`include "alu.sv"


module top(
    input logic     clk, 
    output logic    RGB_R, 
    output logic    RGB_G,
    output logic    RGB_B,
    output logic    LED
);

    parameter RTYPECODE = 7'b0110011;

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
    ) u1(
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

    always_ff @(posedge clk) begin
        if (load_new == 1) begin
            op_code = current_instr[25:31]
            funct3 = current_instr[17:19]
            if (op_code == RTYPECODE) begin
                funct7 = current_instr[0:6]
                rs2 = current_instr[7:11]
                rs1 = current_instr[12:16]
                rd = current_instr[20:24] // R-type instructions ???
            end
        end
    end

endmodule
