module immediate_extender(
    input logic clk,
    input logic[11:0] immed12,
    input logic[19:0] immed20,
    input logic[1:0] ImmSrc,
    output logic[31:0] immed_ext
);
    always_ff@(posedge clk) begin
        case(ImmSrc)
            2'b00: immed_ext = {{21{immed12[12]}}, {immed12[11:1]}}; // Sign-extend immed 12
            2'b01: immed_ext = {{13{immed20[20]}}, {immed20[19:1]}}; // Sign-extend immed 20
            2'b10: immed_ext = {{20'b0}, immed12[11:0]}; // 0 extend immed 12
            2'b11: immed_ext = {{12'b0}, immed20[19:0]}; // 0 extend immed 20
        endcase
    end
endmodule