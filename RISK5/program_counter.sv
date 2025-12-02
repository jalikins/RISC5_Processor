module program_counter(
    input logic clk,
    input logic PCWrite,
    input logic result,
    output logic[31:0] current_pc
);
    always_comb begin
        if (PCWrite) begin
            current_pc <= result;
        end
    end

endmodule