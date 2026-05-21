// =====================================================================
// Project 2 — Skeleton
// Module  : datapath
// Description : Glues together regfile, ALU, PC update logic.
//               Handles delay slots for J / BR.
//
// THIS IS THE HARDEST MODULE. Work through it section by section.
//
// Pipeline timing for a branch:
//   Cycle N    : fetch BR/J at PC=A.  Compute target. Set branch_pending=1.
//                Save target into branch_target_reg. PC updates to A+4.
//   Cycle N+1  : fetch instruction at A+4 (the DELAY SLOT). It executes
//                normally. branch_pending is still 1, so PC will load
//                branch_target_reg next.
//   Cycle N+2  : fetch instruction at branch_target_reg (the actual jump).
//
// Datapath layout:
//
//   instruction[26:22] → ra_addr (regfile)
//   instruction[21:17] → rb_addr (regfile)
//   instruction[16:12] → rc_addr (regfile)
//
//   alu_a = mux(R[rb], R[rc], 32'h0)         — by alu_src_a
//   alu_b = mux(R[rc], signExt17, zeroExt17, shift_amt)  — by alu_src_b
//
//   wr_data = mux(alu_result, dmem_rdata)    — by wb_src
//   wr_addr = ra (instruction[26:22])
//
//   dmem write data = R[ra]   (because ST stores R[ra])
//   dmem address    = alu_result (computed as base + imm or 0 + abs_imm)
// =====================================================================

`include "alu.v"
`include "regfile.v"

module datapath (
    input  wire        clk,
    input  wire        rstn,

    // Instruction from imem
    input  wire [31:0] instr,
    output wire [31:0] pc,           // current PC, drives imem

    // To/from dmem
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    input  wire [31:0] dmem_rdata,

    // Control signals from control unit
    input  wire        reg_write,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [3:0]  alu_op,
    input  wire [1:0]  alu_src_a,
    input  wire [1:0]  alu_src_b,
    input  wire [1:0]  wb_src,
    input  wire        is_jump,
    input  wire        is_branch,
    input  wire        is_link,    // for bonus
    input  wire        is_pc_rel,  // for bonus

    // To control unit
    output wire [4:0]  opcode,
    output wire [4:0]  rb_field
);

    // ===== Instruction Field Extraction =====
    assign opcode    = instr[31:27];
    wire [4:0] ra    = instr[26:22];
    wire [4:0] rb    = instr[21:17];
    wire [4:0] rc    = instr[16:12];
    wire [16:0] imm17 = instr[16:0];
    wire [21:0] imm22 = instr[21:0];
    wire        i_bit = instr[5];
    wire [4:0]  shamt = instr[4:0];
    wire [2:0]  cond  = instr[2:0];

    assign rb_field = rb;

    // Sign / zero extensions
    wire [31:0] sign_ext_imm17 = {{15{imm17[16]}}, imm17};
    wire [31:0] zero_ext_imm17 = {15'b0, imm17};
    wire [31:0] sign_ext_imm22 = {{10{imm22[21]}}, imm22};

    // ===== Register File =====
    wire [31:0] ra_data, rb_data, rc_data;
    wire [31:0] wb_data;        // value to write back

    regfile u_regfile (
        .clk     (clk),
        .rstn    (rstn),
        .ra_addr (ra),
        .rb_addr (rb),
        .rc_addr (rc),
        .ra_data (ra_data),
        .rb_data (rb_data),
        .rc_data (rc_data),
        .we      (reg_write),
        .wr_addr (ra),           // ra is always the destination for instructions that write
        .wr_data (wb_data)
    );

    // ===== Shift Amount Computation =====
    // i=0: use shamt (instruction[4:0])
    // i=1: use rc_data[4:0]
    wire [4:0] shift_amount;
    assign shift_amount = i_bit ? rc_data[4:0] : shamt;

    // ===== ALU Input Muxes =====
    reg [31:0] alu_a, alu_b;

    // alu_src_a:
    //   2'b00 : rb_data
    //   2'b01 : rc_data        (NEG, NOT)
    //   2'b10 : 32'h0          (absolute address)
    always @(*) begin
        case (alu_src_a)
            2'b00: alu_a = rb_data;
            2'b01: alu_a = rc_data;
            2'b10: alu_a = 32'h0;
            default: alu_a = 32'h0;
        endcase
    end

    // alu_src_b:
    //   2'b00 : rc_data
    //   2'b01 : sign_ext_imm17
    //   2'b10 : zero_ext_imm17
    //   2'b11 : {27'h0, shift_amount}
    always @(*) begin
        case (alu_src_b)
            2'b00: alu_b = rc_data;
            2'b01: alu_b = sign_ext_imm17;
            2'b10: alu_b = zero_ext_imm17;
            2'b11: alu_b = {27'h0, shift_amount};
            default: alu_b = 32'h0;
        endcase
    end

    // ===== ALU =====
    wire [31:0] alu_result;
    alu u_alu (
        .a      (alu_a),
        .b      (alu_b),
        .alu_op (alu_op),
        .result (alu_result)
    );

    // ===== Write-back Mux =====
    // wb_src:
    //   2'b00 : alu_result
    //   2'b01 : dmem_rdata
    //   2'b10 : pc + 4         (for JL / BRL link, bonus)
    assign wb_data = (wb_src == 2'b01) ? dmem_rdata : 
                     (wb_src == 2'b10) ? (pc_reg + 32'd4) : 
                     alu_result;

    // ===== Data Memory Address =====
    // The ALU computes the address; just route it out
    assign dmem_addr  = alu_result;
    assign dmem_wdata = ra_data;     // ST stores R[ra]

    // ===== Branch Condition =====
    // For BR (and BRL): cond[2:0] determines whether to take the branch
    //   000 never    : never
    //   001 always   : always
    //   010 zero     : R[rc] == 0
    //   011 nonzero  : R[rc] != 0
    //   100 plus     : R[rc] >= 0  (signed: bit31 == 0)
    //   101 minus    : R[rc] < 0   (signed: bit31 == 1)
    reg branch_cond_met;
    always @(*) begin
        case (cond)
            3'b000:  branch_cond_met = 1'b0;
            3'b001:  branch_cond_met = 1'b1;
            3'b010:  branch_cond_met = (rc_data == 32'h0);
            3'b011:  branch_cond_met = (rc_data != 32'h0);
            3'b100:  branch_cond_met = (rc_data[31] == 1'b0);
            3'b101:  branch_cond_met = (rc_data[31] == 1'b1);
            default: branch_cond_met = 1'b0;
        endcase
    end

    // ===== PC Update with Delay Slot =====
    reg [31:0] pc_reg;
    reg [31:0] branch_target_reg;
    reg        branch_pending;

    assign pc = pc_reg;

    // pc_plus4: next sequential PC
    wire [31:0] pc_plus4 = pc_reg + 32'd4;

    // Compute branch target THIS cycle (when current instruction is the branch)
    wire [31:0] jump_target   = pc_plus4 + sign_ext_imm22;   // for J / JL
    wire [31:0] branch_target = rb_data;                      // for BR / BRL

    wire taking_jump   = is_jump;
    wire taking_branch = is_branch & branch_cond_met;

    // Determine the *next* PC value
    reg [31:0] pc_next;
    always @(*) begin
        if (branch_pending) begin
            pc_next = branch_target_reg;
        end else begin
            pc_next = pc_plus4;
        end
    end

    // PC update + branch_pending state machine
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pc_reg            <= 32'h0;
            branch_pending    <= 1'b0;
            branch_target_reg <= 32'h0;
        end else begin
            pc_reg <= pc_next;

            if (branch_pending) begin
                // This cycle is the delay slot — clear pending after taking the jump
                branch_pending <= 1'b0;
            end else if (taking_jump) begin
                // Latch jump target and set pending
                branch_target_reg <= jump_target;
                branch_pending <= 1'b1;
            end else if (taking_branch) begin
                // Latch branch target and set pending
                branch_target_reg <= branch_target;
                branch_pending <= 1'b1;
            end
        end
    end

endmodule
