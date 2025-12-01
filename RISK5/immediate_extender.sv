module immediate_extender(
    input logic[11:0] immed12;
    input logic[19:0] immed20;
    input logic[1:0] ImmSrc;
    output logic immed_ext
);
    always_comb begin
        case(ImmSrc)
            2'b00: immed_ext = {{21{immed12[0]}}, {immed12[1:11]}}; // Sign-extend immed 12
            2'b01: immed_ext = {{13{immed20[0]}}, {immed20[1:19]}}; // Sign-extend immed 20
            2'b10: immed_ext = {{20{0}}, immed12}; // 0 extend immed 12
            2'b11: immed_ext = {{12{0}}, immed20}; // 0 extend immed 20
        endcase
    end
endmodule