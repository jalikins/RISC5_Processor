module register_file(
    input logic clk,
    input logic RegWrite, // reg write
    input logic [4:0] rs1, rs2, rd, // source reg 1, source reg 2, destination reg
    input logic [31:0] result, // result
    output logic [31:0] rs1_data, rs2_data // read data 1, read data 2
);

    logic [31:0] registers [31:0]; // make 32 registers, each 32 bits wide
    logic [31:0] reg1;

    // set all register values to be 0 initially
    integer i;
    initial begin
        for (i = 0; i < 32; i = i+1)
            registers[i] = 32'b0;
            reg1 = 32'b0;
        end

    always @(result) begin
        if (RegWrite) begin
            registers[rd] <= result; // Writing to reg file
            reg1 = result;
        end
    end
    always_ff @(posedge clk) begin 
        rs1_data <= (rs1 == 5'b00000) ? 32'b0 : registers[rs1]; // Reading from register file
        rs2_data <= (rs2 == 5'b00000) ? 32'b0 : registers[rs2];
    end

endmodule
