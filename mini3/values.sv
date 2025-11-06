module values (
    input logic       clk,
    input logic       rst_n,      
    input logic       newframe,   
    input logic [5:0] pixel,      
    output logic [7:0] read_data,
    output logic [63:0] debug_grid // Added for debugging/display
);

    logic [63:0] current_state;
    logic [63:0] next_state;
    logic [31:0] frame_counter;   
    logic update_frame;           // Internal frame update signal

   
    initial begin
        current_state = 64'h0000303810000000;  // Three cells in row 3 (bits 16,17,18)
    end

    // State update on clock edge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= 64'h0000303810000000;  // Three cells in row 3 (bits 16,17,18)
        end else if (newframe) begin
            current_state <= next_state;
        end
    end

   
    assign debug_grid = current_state;
        

// Game of Life rules implementation
always_comb begin 
    integer x_offset, y_offset;
    logic [5:0] neighbor_count[64];
    
    // Initialize next state
    next_state = 64'b0;

    if (newframe) begin
        // These local variables are fine here
        int neighbor_counter;
        logic [2:0] row;
        logic [2:0] col;
        logic is_alive;
        logic becomes_alive;

        
        for (int i = 0; i < 64; i++) begin

            neighbor_counter = 0;
            row = i / 8;  
            col = i % 8;  

            // Count living neighbors
            for (x_offset = -1; x_offset <= 1; x_offset = x_offset + 1) begin
                for (y_offset = -1; y_offset <= 1; y_offset = y_offset + 1) begin
                    if (!(x_offset == 0 && y_offset == 0)) begin
                        logic [5:0] neighbor_index;
                        logic [2:0] new_row, new_col;

                        // Handle wrapping at edges
                        if ((row + x_offset >= 0) && (row + x_offset < 8) &&
                            (col + y_offset >= 0) && (col + y_offset < 8)) begin
                            new_row = row + x_offset;
                            new_col = col + y_offset;
                            neighbor_index = new_row * 8 + new_col;
                        
                            if (current_state[neighbor_index]) begin
                                neighbor_counter = neighbor_counter + 1;
                            end
                        end
                        else begin
                            neighbor_index =0;
                            new_row = 0;
                            new_col = 0;
                        end
                    end
                end
            end

            is_alive = current_state[i];

            becomes_alive = (is_alive && (neighbor_counter == 2 || neighbor_counter == 3)) ||
                (!is_alive && (neighbor_counter == 3));

            next_state[i] = becomes_alive;
        end
    end
    else begin
        next_state = current_state; // No change if not a new frame
        x_offset = 0;
        y_offset = 0;
    end
end

always_comb begin
    if (current_state[pixel]) begin
        read_data = 8'hFF; // Alive
    end else begin
        read_data = 8'h00; // Dead
    end
end

endmodule