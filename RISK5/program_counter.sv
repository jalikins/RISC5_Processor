module program_counter(
    input logic PCWrite,
    input logic[31:0] result,
    input logic[31:0] old_pc,
    output logic[31:0] current_pc
);

    initial begin
        current_pc = 32'b0;// lowest point in instr memory
    end
    
    always_comb begin
        if (PCWrite) begin
            current_pc = result;
        end else begin
            current_pc = old_pc;
        end
    end

endmodule