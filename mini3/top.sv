`include "values.sv" 
`include "ws2812b.sv" // drives the ws2812b led strip
`include "controller.sv" // finite state machine to control the data flow

// led_matrix top level module

module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT, 
    output logic    _48b, 
    output logic    _45a
);
    // three data buses
    logic [7:0] read_data;

    logic [5:0] pixel;
    logic newframe; 

    // green red blue
    logic [23:0] shift_reg = 24'd0; // going to put pixe
    logic load_sreg;
    logic transmit_pixel;
    logic shift; 
    logic ws2812b_out;



    // my stuff

    logic [63:0] pixel_control = 64'b0;
    logic [63:0] next_pixel_control; // next state of the array 

    logic [5:0] pixel_index = 3'b0; // pixel index to light up

    logic [1:0] flipper = 2'b00; // controls which color is being loaded
    
    
    

    // Instance sample memory for red channel
    values u1 (
        .clk         (clk), 
        .rst_n       (SW), // <-- FIX: Connect the reset port!
        .newframe    (newframe), 
        .pixel        (pixel),
        .read_data     (read_data)
    );

    // Instance the WS2812B output driver
    ws2812b u4 ( // this is the controller 
        .clk            (clk), 
        .serial_in      (shift_reg[23]), // produces for one ck period
        .transmit       (transmit_pixel), // goes high for 15 * 24 clk cycles cause that timing workes so it does not lock
        .ws2812b_out    (ws2812b_out), //
        .shift          (shift)
    );

    // Instance the controller
    controller u5 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel),// goes high for 15 * 24 clk cycles cause that timing workes so it does not lock 
        .pixel          (pixel), // pixel address
        .newframe          (newframe) // fram address
    );

    always_ff @(posedge clk) begin
        if(newframe) begin
            flipper = flipper + 1;
            if (flipper == 2'b11) begin
                flipper = 2'b00;
            end
        end
        if (load_sreg) begin // if shift reg is high
            unique case (flipper)
                2'b00:
                    shift_reg <= { read_data, 16'd0 };
                2'b01:
                    shift_reg <= { 8'd0, read_data, 8'd0 };
                2'b10:
                    shift_reg <= { 16'd0, read_data };
                2'b11: // this is the default case
                    shift_reg <= { 16'd0, read_data };
            endcase
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 }; 
        end
    end


    assign _48b = ws2812b_out; // output
    assign _45a = ~ws2812b_out; // complementary output

endmodule
