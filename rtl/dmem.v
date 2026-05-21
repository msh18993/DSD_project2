// =====================================================================
// Project 2 — Skeleton
// Module  : dmem
// Description : Data memory (read/write, 1024 x 32-bit)
//
// - Byte-addressable interface, but only word (32-bit) accesses occur
// - Synchronous write on posedge clk when drw=1 and dreq=1
// - Asynchronous read when drw=0 (can also be gated by dreq)
// =====================================================================

module dmem (
    input  wire        clk,
    input  wire [31:0] daddr,    // byte address
    input  wire        dreq,     // memory access enable
    input  wire        drw,      // 1 = write, 0 = read
    input  wire [31:0] dwdata,   // write data
    output wire [31:0] drdata    // read data
);

    reg [31:0] mem [0:1023];

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h0;
    end

    // TODO: synchronous write
    //   on posedge clk, if (dreq && drw) write dwdata to mem[daddr[?:?]]

    // TODO: asynchronous read
    //   assign drdata to read from mem at the same word-aligned address

endmodule
