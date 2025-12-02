module register_file(
    input logic clk,
    input logic rw, // reg write
    input logic [4:0] rs1, rs2, rd, // source reg 1, source reg 2, destination reg
    input logic [31:0] wd, // write destination
    output logic [31:0] rd1, rd2 // read data 1, read data 2
);

logic [31:0] registers [31:0]; // make 32 registers, each 32 bits wide

// set all register values to be 0 initially
integer i;
initial begin
    for (i = 0; i < 32; i = i+1)
        registers[i] = 32'b0;
    end


always_ff @(posedge clk) begin
    else if (rw && rd != 5'b00000) begin
        registers[rd] <= wd;
    end
end

always_ff @(posedge clk) begin
    else if (rs1 != 5'b00000 || rs2 != 5'b00000) begin
        rd1 <= (rs1 == 5'b00000) ? 32'b0 : registers[rs1];
        rd2 <= (rs2 == 5'b00000) ? 32'b0 : registers[rs2];
    end
end

endmodule
