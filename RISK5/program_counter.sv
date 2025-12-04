module program_counter(
    input logic clk,
    input logic PCUpdate,
    input logic[31:0] result,
    output logic[31:0] old_pc,
    output logic[31:0] current_pc
);

    initial begin
        current_pc = 32'b0; // lowest point in instr memory
    end
    
    always @(result) begin
        if (PCUpdate) begin
            old_pc = current_pc;
            current_pc = result;
        end
    end

endmodule
