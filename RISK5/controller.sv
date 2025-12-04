module controller (
    input logic clk,
    input logic[6:0] op_code,
    input logic fun7,
    input logic[2:0] funct3,
    input logic zero, // checks if ALU out is 0
    input logic sign,

    output logic[3:0] ALU_control,
    output logic[1:0] ALUSrcA,
    output logic[1:0] ALUSrcB,
    output logic[1:0] ImmSrc,
    output logic[1:0] ResultSrc,
//    output logic decode,
    output logic PCUpdate,
    output logic AdrSrc,
    output logic MemWrite,
    output logic IRWrite,
    output logic RegWrite
);
// not done brah

    // R-type
    parameter RTYPE_CODE = 7'b0110011;
    // Upper-immediate
    parameter LUI_CODE = 7'b0110111;
    parameter AUIPC_CODE = 7'b0010111;
    // Jump
    parameter JAL_CODE = 7'b1101111;
    // Jalr (actually i type)
    parameter JALR_CODE = 7'b1100111;
    // Branch
    parameter BRANCH_CODE = 7'b1100011;
    // I-type
    parameter LOAD_CODE = 7'b0000011;
    parameter LOGICI_CODE = 7'b0010011;
    // S-type
    parameter STORE_CODE = 7'b0100011;

    typedef enum logic [3:0] { // set up fsm--will need to expand by instruction
        FETCH  = 4'b0000,
        DECODE   = 4'b0001,
        MEMADR = 4'b0010,
        MEMREAD = 4'b0011,
        MEMWB = 4'b0100,
        MEMWRITE = 4'b0101, // textbook uses memwrite twice in two different ways, all caps is for fsm
        EXECUTER = 4'b0111,
        ALUWB = 4'b1000,
        BRANCH = 4'b1001,
        EXECUTEI = 4'b1010,
        JAL = 4'b1011,
        JALR = 4'b1100,
        LUI = 4'b1101,
        AUIPC = 4'b1110
    } state_t;

    state_t state, next_state;

    initial begin
        state = FETCH;
        next_state = FETCH;
        AdrSrc = 1'b0;
        IRWrite = 1'b0;
        MemWrite = 1'b0;
    end

    always_ff@(posedge clk) begin // not sure if should be alwayscomb or posedge
        state <= next_state;
        case (state)

            FETCH: begin
                next_state = DECODE; // write pc to old_pc
                AdrSrc <= 1'b0; // fetch adress from pc
                IRWrite <= 1'b1; // writes to instruction reg
                ALUSrcA <= 2'b00; // updating the pc --> choose pc as src 1 for alu
                ALUSrcB <= 2'b10; // alu src b is the constant 4
                ALU_control <= 4'b0000; // alu control is 0 --> add
                PCUpdate <= 1'b1;
                ImmSrc <= 2'b00; // immediate extender gets 12 bit sign extended for branching
                ResultSrc <= 2'b10;
                // we should be updating current instr right here
            end

            DECODE: begin
                //update the current instruction
                // always calculate the branch target as though the instruction were a branch
                ALUSrcA = 2'b01; // Should be OldPC
                ALUSrcB = 2'b01; // immedext
                ALU_control = 4'b0000; // Addition
                case (op_code)
                    LOAD_CODE: begin
                        next_state = MEMADR; // if we are in a lb/lh/lw instr we go to MEM_ADR
                    end
                    STORE_CODE: begin
                        next_state = MEMADR;
                    end
                    RTYPE_CODE: begin
                        next_state = EXECUTER; // state for R-type instructions
                    end
                    BRANCH_CODE: begin
                        next_state = BRANCH;
                    end
                    LOGICI_CODE: begin
                        next_state = EXECUTEI;
                    end
                    JAL_CODE: begin
                        next_state = JAL;
                    end
                    JALR_CODE: begin
                        next_state = JALR;
                    end
                    LUI_CODE: begin
                        next_state = LUI;
                    end
                    AUIPC_CODE: begin
                        next_state = AUIPC;
                    end
                endcase
            end 

            MEMADR: begin // get memory adress to read from
                ALUSrcA <= 2'b10; // Set ALU signals rs1 and immed12
                ALUSrcB <= 2'b01;
                ALU_control <= 4'b0000; // ALU set to add mode
                case (op_code)
                    LOAD_CODE: begin
                        next_state = MEMREAD; // if we are in a lb/lh/lw instr we go to MEMREAD
                    end
                    STORE_CODE: begin
                        next_state = MEMWRITE; // if we are saving a w/h/b we go to mem write
                    end
                endcase
            end

            MEMREAD: begin // send ALU_out as input to mem adress port to read from that adress
                next_state = MEMWB; // if we are in a lb/lh/lw instr we go to MEM_ADR
                ResultSrc <= 2'b00; // routes ALUout through result mux
                AdrSrc <= 1'b0; // routes ALUout through data adress
                ALU_control <= 4'b1111;
                // data is read from ALUout adress
                // data is stored in data register
            end

            MEMWB: begin // Writes the loaded word stored in data reg to the reg file
                next_state = FETCH;
                ResultSrc <= 2'b01; // Selects the data as the result
                RegWrite <= 1'b1; // Writing data to the register file
                ALU_control <= 4'b1111;
            end

            MEMWRITE: begin
                next_state = FETCH;
                ResultSrc <= 2'b00;
                AdrSrc <= 1'b1;
                MemWrite <= 1'b1;
                ALU_control <= 4'b1111;
            end

            EXECUTER: begin 
                next_state = ALUWB;
                ALUSrcA <= 2'b10; // rs1
                ALUSrcB <= 2'b00; // rs2
                case({fun7, funct3})
                    {1'b0, 3'b000}: ALU_control = 4'b0000; // ADD !!! In textbook add is 000
                    {1'b1, 3'b000}: ALU_control = 4'b0110; // SUB
                    {1'b0, 3'b111}: ALU_control = 4'b0001; // AND
                    {1'b0, 3'b110}: ALU_control = 4'b0010; // OR
                    {1'b0, 3'b100}: ALU_control = 4'b0011; // XOR
                    {1'b0, 3'b001}: ALU_control = 4'b0100; // SLL
                    {1'b0, 3'b101}: ALU_control = 4'b0101; // SRL
                    {1'b1, 3'b101}: ALU_control = 4'b0111; // SRA
                    {1'b0, 3'b010}: ALU_control = 4'b1010; // SLT Signed
                    {1'b0, 3'b011}: ALU_control = 4'b1001; // SLT Unsigned
//                  default: ALU_control = 4'b0000; // default to add    
                endcase
            end

            ALUWB: begin // Write ALU result to register file
                next_state = FETCH;
                ResultSrc <= 2'b00; // result from ALU
                RegWrite <= 1'b1; //writes to rd
                ALU_control <= 4'b1111;
            end

            BRANCH: begin
                next_state <= FETCH;
                ALUSrcA <= 2'b10; // rs1
                ALUSrcB <= 2'b00; // rs2
                ResultSrc <= 2'b00;
                case(funct3)
                    3'b110: ALU_control <= 4'b1101; // Sub unsigned
                    3'b111: ALU_control <= 4'b1101; // Sub unsigned
                    default: ALU_control <= 4'b0110;
                endcase
                case({funct3, sign, zero})
                    {3'b000, 1'b1, 1'b1}: PCUpdate <= 1'b1; // if ALU returns 0, we branch
                    {3'b001, 1'b1, 1'b0}: PCUpdate <= 1'b1; // if ALU doesn't return 0, we branch
                    {3'b001, 1'b0, 1'b0}: PCUpdate <= 1'b1; // if ALU doesn't return 0, we branch
                    {3'b100, 1'b0, 1'b0}: PCUpdate <= 1'b1; // blt - only branch if sign is negative
                    {3'b101, 1'b1, 1'b0}: PCUpdate <= 1'b1; // bge - only branch if sign is positive
                    {3'b110, 1'b0, 1'b0}: PCUpdate <= 1'b1;
                    {3'b111, 1'b1, 1'b0}: PCUpdate <= 1'b1;
                    default: PCUpdate <= 1'b0;
                endcase
            end

            EXECUTEI: begin
                next_state = ALUWB;
                ALUSrcA <= 2'b10;
                ALUSrcB <= 2'b01;
                case({fun7, funct3})
                    {1'b0, 3'b000}: ALU_control <= 4'b0000; // ADD !!! In textbook add is 000
                    {1'b0, 3'b111}: ALU_control <= 4'b0001; // AND
                    {1'b0, 3'b110}: ALU_control <= 4'b0010; // OR
                    {1'b0, 3'b100}: ALU_control <= 4'b0011; // XOR
                    {1'b0, 3'b001}: ALU_control <= 4'b0100; // SLL
                    {1'b0, 3'b101}: ALU_control <= 4'b0101; // SRL __ 
                    {1'b1, 3'b101}: ALU_control <= 4'b0111; // SRA __ need a case statement in decoder to give a fun7 for these if funct3 is 101
                    {1'b0, 3'b010}: ALU_control <= 4'b1010; // SLT
                    {1'b0, 3'b011}: ALU_control <= 4'b1001; // SLTU
                endcase
            end

            JAL: begin
                next_state = ALUWB;
                ALUSrcA <= 2'b01; // OLD PC
                ALUSrcB <= 2'b10; // 4
                ALU_control <= 4'b0000; // ADD - we need to normalize these
                ResultSrc <= 2'b00;
                PCUpdate <= 1'b1;
            end

            JALR: begin
                next_state = ALUWB;
                ALUSrcA <= 2'b10; // Rrs1
                ALUSrcB <= 2'b01; // Signed offset
                ALU_control <= 4'b0000;
                ResultSrc <= 2'b00;
                PCUpdate <= 1'b1; // updates the pc with the new adress
            end

            LUI: begin
                next_state = ALUWB;
                RegWrite <= 1'b1;
                ResultSrc <= 2'b11; // Should be immediate generator
                ALU_control <= 4'b1111;
            end

            AUIPC: begin
                next_state = ALUWB;
                ALU_control <= 4'b0000; // ADDING
                ALUSrcA <= 2'b01; // Old PC
                ALUSrcB <= 2'b01; // Imm gen
                ResultSrc <= 2'b00; // Writes the previous ALU out ie. old PC to reg
            end
        endcase
    end
endmodule
//
//          4'b0010, 1'b0, 3'b000: ALU_control = 4'b0000; // ADD
//          4'b0010, 1'b1, 3'b000: ALU_control = 4'b0110; // SUB
//          4'b0010, 1'b0, 3'b111: ALU_control = 4'b0001; // AND
//          4'b0010, 1'b0, 3'b110: ALU_control = 4'b0010; // OR
//          4'b0010, 1'b0, 3'b100: ALU_control = 4'b0011; // XOR
//          4'b0010, 1'b0, 3'b001: ALU_control = 4'b0100; // SLL
//          4'b0010, 1'b0, 3'b101: ALU_control = 4'b0101; // SRL
//          4'b0010, 1'b1, 3'b101: ALU_control = 4'b0111; // SRA
//          4'b1001 // SET LESS THAN Unsinged
//          4'b1010 // SET LESS THAN SIGNED
//          4'b1100 // NOR
//          4'b1101 // Subtract unsigned
//          4'b1111 // nothing