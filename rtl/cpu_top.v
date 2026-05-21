// =====================================================================
// Project 2 — Skeleton
// Module  : cpu_top
// Description : RISC-Toy CPU top level.
//
// External interface follows the manual:
//   CLK, RSTN  — clock and active-low reset
//   IADDR, IREQ, INSTR  — instruction memory interface (master)
//   DADDR, DREQ, DRW, DWDATA, DRDATA  — data memory interface (master)
//   CONSIG  — custom IP control (unused in required-only design)
// =====================================================================

`include "control.v"
`include "datapath.v"

module cpu_top (
    input  wire        CLK,
    input  wire        RSTN,

    // Instruction memory interface
    output wire [31:0] IADDR,
    output wire        IREQ,
    input  wire [31:0] INSTR,

    // Data memory interface
    output wire [31:0] DADDR,
    output wire        DREQ,
    output wire        DRW,         // 1 = write, 0 = read
    output wire [31:0] DWDATA,
    input  wire [31:0] DRDATA,

    // Custom IP (unused for required-only)
    output wire        CONSIG
);

    // Internal signals
    wire [4:0]  opcode;
    wire [4:0]  rb_field;

    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire [3:0]  alu_op;
    wire [1:0]  alu_src_a;
    wire [1:0]  alu_src_b;
    wire [1:0]  wb_src;
    wire        is_jump;
    wire        is_branch;
    wire        is_link;
    wire        is_pc_rel;

    wire [31:0] pc;

    // Instruction fetch
    assign IADDR = pc;
    assign IREQ  = 1'b1;     // always fetching

    // Data memory request
    assign DREQ = mem_read | mem_write;
    assign DRW  = mem_write;

    assign CONSIG = 1'b0;    // not used

    // ===== Instantiate Control Unit =====
    control u_ctrl (
        .opcode    (opcode),
        .rb_field  (rb_field),
        .reg_write (reg_write),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .alu_op    (alu_op),
        .alu_src_a (alu_src_a),
        .alu_src_b (alu_src_b),
        .wb_src    (wb_src),
        .is_jump   (is_jump),
        .is_branch (is_branch),
        .is_link   (is_link),
        .is_pc_rel (is_pc_rel)
    );

    // ===== Instantiate Datapath =====
    datapath u_dp (
        .clk        (CLK),
        .rstn       (RSTN),
        .instr      (INSTR),
        .pc         (pc),
        .dmem_addr  (DADDR),
        .dmem_wdata (DWDATA),
        .dmem_rdata (DRDATA),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .alu_op     (alu_op),
        .alu_src_a  (alu_src_a),
        .alu_src_b  (alu_src_b),
        .wb_src     (wb_src),
        .is_jump    (is_jump),
        .is_branch  (is_branch),
        .is_link    (is_link),
        .is_pc_rel  (is_pc_rel),
        .opcode     (opcode),
        .rb_field   (rb_field)
    );

endmodule
