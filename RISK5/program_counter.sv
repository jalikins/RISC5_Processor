module program_counter(
    input logic clk,
    input logic PCWrite,
    input logic result,
    output logic[31:0] current_pc
);
    initial begin
        current_pc = 14'h00000000002000;// lowest point in instr memory
    end
    
    logic[31:0] current_pc_temp;
    always_comb begin
        if (PCWrite) begin
            current_pc <= result;
        end else begin
            current_pc <= current_pc_temp;
        end
    end

endmodule