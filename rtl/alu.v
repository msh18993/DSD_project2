// =====================================================================
// Project 2 — Skeleton
// Module  : alu
// Description : 32-bit ALU for RISC-Toy
//
// Operations (alu_op encoding):
//   4'b0000 ADD   : a + b
//   4'b0001 SUB   : a - b
//   4'b0010 NEG   : -a            (operand on input a)
//   4'b0011 NOT   : ~a            (operand on input a)
//   4'b0100 AND   : a & b
//   4'b0101 OR    : a | b
//   4'b0110 XOR   : a ^ b
//   4'b0111 LSR   : a >> b[4:0]   (logical)
//   4'b1000 ASR   : a >>> b[4:0]  (arithmetic)
//   4'b1001 SHL   : a << b[4:0]
//   4'b1010 ROR   : (a >> b[4:0]) | (a << (32 - b[4:0]))   [optional]
//   4'b1111 PASSB : b             (used for MOVI: pass signExt(imm17))
//
// Note: For NEG/NOT, the datapath places the operand on input a (it selects
//       R[rc] for the NEG/NOT case).
//
// PERFORMANCE NOTE:
//   The "+" operator below leaves architecture choices to the synthesizer.
//   For better timing, you may replace the addition path with a custom
//   structural adder (e.g., carry-lookahead, carry-select, prefix adder).
//   See the optimization hints section in Project2_Description.md.
// =====================================================================

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_op,
    output reg  [31:0] result
);

    // ALUOp opcodes
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

    // ===== Result =====
    always @(*) begin
        case (alu_op)
            ALU_ADD:   result = a + b;
            ALU_SUB:   result = a - b;
            ALU_NEG:   result = -a;
            ALU_NOT:   result = ~a;
            ALU_AND:   result = a & b;
            ALU_OR:    result = a | b;
            ALU_XOR:   result = a ^ b;
            ALU_LSR:   result = a >> b[4:0];
            ALU_ASR:   result = $signed(a) >>> b[4:0];
            ALU_SHL:   result = a << b[4:0];
            ALU_ROR:   result = (a >> b[4:0]) | (a << (32 - b[4:0]));
            ALU_PASSB: result = b;
            default:   result = 32'h0;
        endcase
    end

endmodule
