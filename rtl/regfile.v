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

    // Synchronous write and reset
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'h0;
        end else if (we && (wr_addr != 5'b0)) begin
            regs[wr_addr] <= wr_data;
        end
    end

    // Asynchronous reads (R0 always returns 0)
    assign ra_data = (ra_addr == 5'b0) ? 32'h0 : regs[ra_addr];
    assign rb_data = (rb_addr == 5'b0) ? 32'h0 : regs[rb_addr];
    assign rc_data = (rc_addr == 5'b0) ? 32'h0 : regs[rc_addr];

endmodule
