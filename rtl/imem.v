// =====================================================================
// Project 2 — Skeleton
// Module  : imem
// Description : Instruction memory (read-only, 1024 x 32-bit)
//
// - Word-addressed internally; PC is byte-addressed externally
// - Asynchronous read: instruction = mem[addr[31:2]]
// - Loaded at simulation start from MEM_FILE
// =====================================================================

module imem #(
    parameter MEM_FILE = "test_simple.mem"
) (
    input  wire [31:0] iaddr,    // byte address from PC
    output wire [31:0] instr
);

    reg [31:0] mem [0:1023];

    initial begin
        $readmemh(MEM_FILE, mem);
    end

    // TODO: assign instr from mem using word-aligned indexing
    //       Hint: instr = mem[iaddr[?:?]]

endmodule
