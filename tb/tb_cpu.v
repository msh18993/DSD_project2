// =====================================================================
// Project 2 — DO NOT MODIFY (students)
// Testbench: tb_cpu
//
// Instantiates one CPU per test program (each with its own imem/dmem),
// runs them in parallel on a shared clock, and checks dmem[0] after
// enough cycles have elapsed for that test to halt in its J-loop.
//
// To run with iverilog:
//   iverilog -o sim tb_cpu.v ../skeleton/cpu_top.v
//   vvp sim
// (The .v files include their own dependencies via `include.)
// =====================================================================

`timescale 1ns/1ps
`include "cpu_top.v"
`include "imem.v"
`include "dmem.v"

module tb_cpu;

    reg clk, rstn;

    // ====== TEST 1: simple ======
    wire [31:0] iaddr1, daddr1, dwdata1, drdata1, instr1;
    wire        ireq1, dreq1, drw1, consig1;
    cpu_top dut1 (
        .CLK(clk), .RSTN(rstn),
        .IADDR(iaddr1), .IREQ(ireq1), .INSTR(instr1),
        .DADDR(daddr1), .DREQ(dreq1), .DRW(drw1),
        .DWDATA(dwdata1), .DRDATA(drdata1),
        .CONSIG(consig1)
    );
    imem #(.MEM_FILE("programs/test_simple.mem")) imem1 (.iaddr(iaddr1), .instr(instr1));
    dmem dmem1 (.clk(clk), .daddr(daddr1), .dreq(dreq1), .drw(drw1),
                .dwdata(dwdata1), .drdata(drdata1));

    // ====== TEST 2: fibonacci ======
    wire [31:0] iaddr2, daddr2, dwdata2, drdata2, instr2;
    wire        ireq2, dreq2, drw2, consig2;
    cpu_top dut2 (
        .CLK(clk), .RSTN(rstn),
        .IADDR(iaddr2), .IREQ(ireq2), .INSTR(instr2),
        .DADDR(daddr2), .DREQ(dreq2), .DRW(drw2),
        .DWDATA(dwdata2), .DRDATA(drdata2),
        .CONSIG(consig2)
    );
    imem #(.MEM_FILE("programs/test_fibonacci.mem")) imem2 (.iaddr(iaddr2), .instr(instr2));
    dmem dmem2 (.clk(clk), .daddr(daddr2), .dreq(dreq2), .drw(drw2),
                .dwdata(dwdata2), .drdata(drdata2));

    // ====== TEST 3: loadstore ======
    wire [31:0] iaddr3, daddr3, dwdata3, drdata3, instr3;
    wire        ireq3, dreq3, drw3, consig3;
    cpu_top dut3 (
        .CLK(clk), .RSTN(rstn),
        .IADDR(iaddr3), .IREQ(ireq3), .INSTR(instr3),
        .DADDR(daddr3), .DREQ(dreq3), .DRW(drw3),
        .DWDATA(dwdata3), .DRDATA(drdata3),
        .CONSIG(consig3)
    );
    imem #(.MEM_FILE("programs/test_loadstore.mem")) imem3 (.iaddr(iaddr3), .instr(instr3));
    dmem dmem3 (.clk(clk), .daddr(daddr3), .dreq(dreq3), .drw(drw3),
                .dwdata(dwdata3), .drdata(drdata3));

    // ====== TEST 4: logic_shift ======
    wire [31:0] iaddr4, daddr4, dwdata4, drdata4, instr4;
    wire        ireq4, dreq4, drw4, consig4;
    cpu_top dut4 (
        .CLK(clk), .RSTN(rstn),
        .IADDR(iaddr4), .IREQ(ireq4), .INSTR(instr4),
        .DADDR(daddr4), .DREQ(dreq4), .DRW(drw4),
        .DWDATA(dwdata4), .DRDATA(drdata4),
        .CONSIG(consig4)
    );
    imem #(.MEM_FILE("programs/test_logic_shift.mem")) imem4 (.iaddr(iaddr4), .instr(instr4));
    dmem dmem4 (.clk(clk), .daddr(daddr4), .dreq(dreq4), .drw(drw4),
                .dwdata(dwdata4), .drdata(drdata4));

    // ====== TEST 5: call ======
    wire [31:0] iaddr5, daddr5, dwdata5, drdata5, instr5;
    wire        ireq5, dreq5, drw5, consig5;
    cpu_top dut5 (
        .CLK(clk), .RSTN(rstn),
        .IADDR(iaddr5), .IREQ(ireq5), .INSTR(instr5),
        .DADDR(daddr5), .DREQ(dreq5), .DRW(drw5),
        .DWDATA(dwdata5), .DRDATA(drdata5),
        .CONSIG(consig5)
    );
    imem #(.MEM_FILE("programs/test_call.mem")) imem5 (.iaddr(iaddr5), .instr(instr5));
    dmem dmem5 (.clk(clk), .daddr(daddr5), .dreq(dreq5), .drw(drw5),
                .dwdata(dwdata5), .drdata(drdata5));

    // ====== TEST 6: addr_modes ======
    wire [31:0] iaddr6, daddr6, dwdata6, drdata6, instr6;
    wire        ireq6, dreq6, drw6, consig6;
    cpu_top dut6 (
        .CLK(clk), .RSTN(rstn),
        .IADDR(iaddr6), .IREQ(ireq6), .INSTR(instr6),
        .DADDR(daddr6), .DREQ(dreq6), .DRW(drw6),
        .DWDATA(dwdata6), .DRDATA(drdata6),
        .CONSIG(consig6)
    );
    imem #(.MEM_FILE("programs/test_addr_modes.mem")) imem6 (.iaddr(iaddr6), .instr(instr6));
    dmem dmem6 (.clk(clk), .daddr(daddr6), .dreq(dreq6), .drw(drw6),
                .dwdata(dwdata6), .drdata(drdata6));

    // ====== Clock ======
    initial clk = 0;
    always #5 clk = ~clk;     // 100 MHz

    // ====== Stimulus ======
    integer pass_count, fail_count;
    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, tb_cpu);

        pass_count = 0;
        fail_count = 0;

        // Reset
        rstn = 1'b0;
        #20;
        rstn = 1'b1;

        // ===== Run TEST 1 =====
        $display("=========================================");
        $display(" TEST 1: test_simple.mem");
        $display(" Expected: dmem[0] == 0x00000008");
        repeat (60) @(posedge clk);
        if (dmem1.mem[0] === 32'h00000008) begin
            $display(" PASS: dmem[0] = 0x%08h", dmem1.mem[0]);
            pass_count = pass_count + 1;
        end else begin
            $display(" FAIL: dmem[0] = 0x%08h (expected 0x00000008)", dmem1.mem[0]);
            fail_count = fail_count + 1;
        end
        $display("=========================================");

        // ===== Run TEST 2 =====
        $display(" TEST 2: test_fibonacci.mem");
        $display(" Expected: dmem[0] == 0x00000022");
        repeat (200) @(posedge clk);
        if (dmem2.mem[0] === 32'h00000022) begin
            $display(" PASS: dmem[0] = 0x%08h", dmem2.mem[0]);
            pass_count = pass_count + 1;
        end else begin
            $display(" FAIL: dmem[0] = 0x%08h (expected 0x00000022)", dmem2.mem[0]);
            fail_count = fail_count + 1;
        end
        $display("=========================================");

        // ===== Run TEST 3 =====
        $display(" TEST 3: test_loadstore.mem");
        $display(" Expected: dmem[0] == 0x00000055");
        repeat (60) @(posedge clk);
        if (dmem3.mem[0] === 32'h00000055) begin
            $display(" PASS: dmem[0] = 0x%08h", dmem3.mem[0]);
            pass_count = pass_count + 1;
        end else begin
            $display(" FAIL: dmem[0] = 0x%08h (expected 0x00000055)", dmem3.mem[0]);
            fail_count = fail_count + 1;
        end
        $display("=========================================");

        // ===== Run TEST 4 =====
        $display(" TEST 4: test_logic_shift.mem");
        $display(" Expected: dmem[0] == 0xF0001121");
        repeat (180) @(posedge clk);
        if (dmem4.mem[0] === 32'hF0001121) begin
            $display(" PASS: dmem[0] = 0x%08h", dmem4.mem[0]);
            pass_count = pass_count + 1;
        end else begin
            $display(" FAIL: dmem[0] = 0x%08h (expected 0xF0001121)", dmem4.mem[0]);
            fail_count = fail_count + 1;
        end
        $display("=========================================");

        // ===== Run TEST 5 =====
        $display(" TEST 5: test_call.mem");
        $display(" Expected: dmem[0] == 0x00000011");
        repeat (100) @(posedge clk);
        if (dmem5.mem[0] === 32'h00000011) begin
            $display(" PASS: dmem[0] = 0x%08h", dmem5.mem[0]);
            pass_count = pass_count + 1;
        end else begin
            $display(" FAIL: dmem[0] = 0x%08h (expected 0x00000011)", dmem5.mem[0]);
            fail_count = fail_count + 1;
        end
        $display("=========================================");

        // ===== Run TEST 6 =====
        $display(" TEST 6: test_addr_modes.mem");
        $display(" Expected: dmem[0] == 0x000000AA");
        repeat (60) @(posedge clk);
        if (dmem6.mem[0] === 32'h000000AA) begin
            $display(" PASS: dmem[0] = 0x%08h", dmem6.mem[0]);
            pass_count = pass_count + 1;
        end else begin
            $display(" FAIL: dmem[0] = 0x%08h (expected 0x000000AA)", dmem6.mem[0]);
            fail_count = fail_count + 1;
        end
        $display("=========================================");

        // ===== Summary =====
        $display(" RESULT: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count == 0) $display(" *** ALL TESTS PASSED ***");
        else                 $display(" *** SOME TESTS FAILED -- see above ***");
        $display("=========================================");
        $finish;
    end

    // ====== Timeout safety net ======
    initial begin
        #20000;
        $display("[TIMEOUT] simulation ran too long");
        $finish;
    end

endmodule
