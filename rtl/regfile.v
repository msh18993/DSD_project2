// =====================================================================
// Project 2 — Skeleton
// Module  : regfile
// Description : 32 x 32-bit register file with 3 read ports
//
// Why 3 read ports?
//   ST instruction needs to read R[ra] (data) AND R[rb] (base address)
//   simultaneously. Most other instructions need R[rb] and R[rc].
//   To handle both cleanly, we expose ra, rb, rc reads.
//
// Rules:
//   - R0 is hardwired to zero. Reads return 0 regardless of contents.
//   - Writes to R0 are silently discarded.
//   - Write is synchronous (posedge clk).
//   - Reads are asynchronous (combinational).
// =====================================================================

module regfile (
    input  wire        clk,
    input  wire        rstn,        // active low

    // Read ports
    input  wire [4:0]  ra_addr,
    input  wire [4:0]  rb_addr,
    input  wire [4:0]  rc_addr,
    output wire [31:0] ra_data,
    output wire [31:0] rb_data,
    output wire [31:0] rc_data,

    // Write port
    input  wire        we,           // write enable
    input  wire [4:0]  wr_addr,
    input  wire [31:0] wr_data
);

    reg [31:0] regs [0:31];

    integer i;
    // TODO: synchronous reset clears all regs to 0; synchronous write writes
    //       wr_data to regs[wr_addr] when we=1 and wr_addr != 0

    // TODO: asynchronous reads
    //   ra_data should be 0 when ra_addr == 0, else regs[ra_addr]
    //   Same for rb_data and rc_data

endmodule
