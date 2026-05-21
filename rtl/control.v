// =====================================================================
// Project 2 — Skeleton
// Module  : control
// Description : Decodes RISC-Toy opcode and rb-field-31-sentinel into
//               control signals for the datapath.
//
// Opcode reference (5-bit, from manual):
//   0  ADD     8  ORI    16 JL     24 STIP
//   1  ADDI    9  XOR    17 BR
//   2  SUB    10  LSR    18 BRL
//   3  NEG    11  ASR    19 ST
//   4  NOT    12  SHL    20 STR
//   5  AND    13  ROR    21 LD
//   6  ANDI   14  MOVI   22 LDR
//   7  OR     15  J      23 LDIP
//
// IMPORTANT: All output signals must be assigned for every opcode.
//            Use a default branch in your case statement to avoid latches.
// =====================================================================

module control (
    input  wire [4:0] opcode,
    input  wire [4:0] rb_field,    // instruction[21:17] — needed for ST/LD abs detection

    // Write enables
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,

    // ALU controls
    output reg [3:0]  alu_op,
    output reg [1:0]  alu_src_a,    // 00=R[rb], 01=R[rc], 10=32'h0
    output reg [1:0]  alu_src_b,    // 00=R[rc], 01=signExt(imm17), 10=zeroExt(imm17), 11=shift_amount

    // Write-back source
    output reg [1:0]  wb_src,       // 00=ALU result, 01=DMEM read data

    // Branch / jump signals
    output reg        is_jump,      // J (always taken; target = PC+4 + signExt(imm22))
    output reg        is_branch,    // BR (conditional; target = R[rb])

    // Optional bonus signals (set to 0 for required-only implementation)
    output reg        is_link,      // for JL, BRL — write PC+4 to R[ra]
    output reg        is_pc_rel     // for STR, LDR
);

    // Opcodes
    localparam OP_ADD  = 5'd0;
    localparam OP_ADDI = 5'd1;
    localparam OP_SUB  = 5'd2;
    localparam OP_NEG  = 5'd3;
    localparam OP_NOT  = 5'd4;
    localparam OP_AND  = 5'd5;
    localparam OP_ANDI = 5'd6;
    localparam OP_OR   = 5'd7;
    localparam OP_ORI  = 5'd8;
    localparam OP_XOR  = 5'd9;
    localparam OP_LSR  = 5'd10;
    localparam OP_ASR  = 5'd11;
    localparam OP_SHL  = 5'd12;
    localparam OP_ROR  = 5'd13;
    localparam OP_MOVI = 5'd14;
    localparam OP_J    = 5'd15;
    localparam OP_JL   = 5'd16;
    localparam OP_BR   = 5'd17;
    localparam OP_BRL  = 5'd18;
    localparam OP_ST   = 5'd19;
    localparam OP_STR  = 5'd20;
    localparam OP_LD   = 5'd21;
    localparam OP_LDR  = 5'd22;

    // ALU op encoding — must match alu.v
    localparam ALU_ADD   = 4'b0000;
    localparam ALU_SUB   = 4'b0001;
    localparam ALU_NEG   = 4'b0010;
    localparam ALU_NOT   = 4'b0011;
    localparam ALU_AND   = 4'b0100;
    localparam ALU_OR    = 4'b0101;
    localparam ALU_XOR   = 4'b0110;
    localparam ALU_LSR   = 4'b0111;
    localparam ALU_ASR   = 4'b1000;
    localparam ALU_SHL   = 4'b1001;
    localparam ALU_ROR   = 4'b1010;
    localparam ALU_PASSB = 4'b1111;

    // Detect absolute addressing: rb == 31 in ST/LD
    wire is_abs_addr = (rb_field == 5'b11111);

    always @(*) begin
        // Safe defaults — all signals must be set for every path
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        alu_op     = ALU_ADD;
        alu_src_a  = 2'b00;
        alu_src_b  = 2'b00;
        wb_src     = 2'b00;
        is_jump    = 1'b0;
        is_branch  = 1'b0;
        is_link    = 1'b0;
        is_pc_rel  = 1'b0;

        case (opcode)
            // ===== R-type arithmetic / logical =====
            OP_ADD: begin
                reg_write = 1'b1;
                alu_op = ALU_ADD;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b00;  // R[rc]
            end
            OP_SUB: begin
                reg_write = 1'b1;
                alu_op = ALU_SUB;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b00;  // R[rc]
            end
            OP_AND: begin
                reg_write = 1'b1;
                alu_op = ALU_AND;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b00;  // R[rc]
            end
            OP_OR: begin
                reg_write = 1'b1;
                alu_op = ALU_OR;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b00;  // R[rc]
            end
            OP_XOR: begin
                reg_write = 1'b1;
                alu_op = ALU_XOR;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b00;  // R[rc]
            end

            // ===== R-type unary (operand on rc) =====
            OP_NEG: begin
                reg_write = 1'b1;
                alu_op = ALU_NEG;
                alu_src_a = 2'b01;  // R[rc]
                alu_src_b = 2'b00;  // R[rc] (unused for NEG)
            end
            OP_NOT: begin
                reg_write = 1'b1;
                alu_op = ALU_NOT;
                alu_src_a = 2'b01;  // R[rc]
                alu_src_b = 2'b00;  // R[rc] (unused for NOT)
            end

            // ===== I-type with imm17 =====
            OP_ADDI: begin
                reg_write = 1'b1;
                alu_op = ALU_ADD;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b01;  // signExt(imm17)
            end
            OP_ANDI: begin
                reg_write = 1'b1;
                alu_op = ALU_AND;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b01;  // signExt(imm17)
            end
            OP_ORI: begin
                reg_write = 1'b1;
                alu_op = ALU_OR;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b01;  // signExt(imm17)
            end

            // ===== Shifts =====
            OP_LSR: begin
                reg_write = 1'b1;
                alu_op = ALU_LSR;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b11;  // shift_amount
            end
            OP_ASR: begin
                reg_write = 1'b1;
                alu_op = ALU_ASR;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b11;  // shift_amount
            end
            OP_SHL: begin
                reg_write = 1'b1;
                alu_op = ALU_SHL;
                alu_src_a = 2'b00;  // R[rb]
                alu_src_b = 2'b11;  // shift_amount
            end

            // ===== Move immediate =====
            OP_MOVI: begin
                reg_write = 1'b1;
                alu_op = ALU_PASSB;
                alu_src_a = 2'b00;  // unused
                alu_src_b = 2'b01;  // signExt(imm17)
            end

            // ===== Jump =====
            OP_J: begin
                is_jump = 1'b1;
            end

            // ===== Branch =====
            OP_BR: begin
                is_branch = 1'b1;
            end

            // ===== Store =====
            OP_ST: begin
                mem_write = 1'b1;
                alu_op = ALU_ADD;
                if (is_abs_addr) begin
                    alu_src_a = 2'b10;  // 0
                    alu_src_b = 2'b10;  // zeroExt(imm17)
                end else begin
                    alu_src_a = 2'b00;  // R[rb]
                    alu_src_b = 2'b01;  // signExt(imm17)
                end
            end

            // ===== Load =====
            OP_LD: begin
                mem_read = 1'b1;
                reg_write = 1'b1;
                wb_src = 2'b01;     // dmem_rdata
                alu_op = ALU_ADD;
                if (is_abs_addr) begin
                    alu_src_a = 2'b10;  // 0
                    alu_src_b = 2'b10;  // zeroExt(imm17)
                end else begin
                    alu_src_a = 2'b00;  // R[rb]
                    alu_src_b = 2'b01;  // signExt(imm17)
                end
            end

            // ===== Optional bonus =====
            // OP_ROR, OP_JL, OP_BRL, OP_STR, OP_LDR: leave for bonus

            default: begin
                // No-op: defaults already set above
            end
        endcase
    end

endmodule
