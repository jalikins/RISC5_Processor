module program_counter(
    parameter INCREMENT = 4
)(
    input logic clk,
    input logic pc_sel,
    input logic[31:0] result,
    output logic[31:0] pc
);
    always_comb begin
        pc = (pc_sel == 0) ? (pc + INCREMENT) : result;
    end

endmodule