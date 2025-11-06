`timescale 1ns/1ns
`include "top.sv"

module mini3_tb;

    logic clk;
    logic rst_n;  
    logic _48b, _45a;
    logic [63:0] grid_state;
    integer frame_count;

    initial begin // this stoped my bugs
        clk = 0;
        frame_count = 0;
        rst_n = 0;  
        #10 rst_n = 1;  
    end

    top u0 (
        .clk            (clk),
        .SW             (rst_n),  
        ._48b           (_48b), 
        ._45a           (_45a)
    );

    // Monitor the grid state
    always @(posedge clk) begin
        grid_state = u0.u1.debug_grid;
        if (u0.newframe) begin
            frame_count = frame_count + 1;
            
            // Print frame header
            $display("\nFrame %0d:", frame_count);
            
            // Print debug info
            $display("Reset: %b, Newframe: %b", rst_n, u0.newframe);
            

            $display("+--------+");
            for (int row = 0; row < 8; row++) begin
                logic [7:0] row_bits;

                row_bits = grid_state[row*8 +: 8];
                $write("|");
                for (int col = 0; col < 8; col++) begin

                    $write("%s", row_bits[col] ? "O" : ".");
                end
                $display("|");
            end
            $display("+--------+");
            

            $display("Grid (hex): %h", grid_state);
            
            $write("Live cells: ");
            for (int i = 0; i < 64; i++) begin
                if (grid_state[i]) begin
                    $write("[%0d,%0d] ", i/8, i%8);
                end
            end
            $display("\n");
        end
    end

    initial begin
        $dumpfile("mini3.vcd");
        $dumpvars(0, mini3_tb);
        #800000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

