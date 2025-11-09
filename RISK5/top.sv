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
    );

endmodule
