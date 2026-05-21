# DSD Project 2: 32-bit RISC-Style CPU Design

## Project Information

- **Course:** EE361 디지털회로설계및언어 (Digital Circuit Design & HDL)
- **University:** Kyung Hee University
- **Instructor:** Suwan Kim (`suwankim@khu.ac.kr`)
- **Project Name:** Project2 - CPU Design
- **Objective:** Design and implement a custom 32-bit RISC-style CPU using Verilog HDL

---

## Project Overview

This project involves implementing a **custom 32-bit RISC (Reduced Instruction Set Computer) style CPU** in Verilog. The implementation follows a classic pipeline-based CPU architecture with separate Fetch and Execute stages.

### Key Objectives
- Implement core CPU modules from scratch using Verilog HDL
- Complete TODO sections in module files
- Ensure all modules pass simulation tests
- Run through complete design flow: Simulation → Synthesis → Place & Route → Static Timing Analysis

### Design Constraints
- **DO NOT MODIFY:** Testbench files, simulation scripts, synthesis flow, PnR flow, STA flow, and scripts directory
- **CAN MODIFY:** Only RTL module implementations (TODO sections)
- **CAN ADD:** New signals or variables if required for implementation

---

## RISC Architecture Overview

### What is RISC?
RISC (Reduced Instruction Set Computer) simplifies CPU design by using a limited set of basic instructions. Each instruction performs a single, simple operation.

### RISC vs CISC
- **CISC:** One instruction = multiple internal operations (e.g., `Add Memory[A], Memory[B]`)
- **RISC:** One instruction = one simple operation
  - `Load R1, [A]` - Load value from memory address A into register R1
  - `Load R2, [B]` - Load value from memory address B into register R2
  - `Add R3, R1, R2` - Add R1 and R2, store result in R3
  - `Store R3, [A]` - Store R3 back to memory address A

### CPU Execution Stages

#### Fetch Stage
- Retrieve instruction from Instruction Memory (IMEM)
- Increment Program Counter (PC)

#### Execute Stage
- Decode instruction using Control Unit
- Perform ALU operations or memory access (Load/Store)
- Update registers or Program Counter

### Key Hardware Components

| Component | Function |
|-----------|----------|
| **Control Unit** | Decodes instructions and generates control signals |
| **Register File** | Fast temporary storage (registers R0-R31) |
| **ALU** | Performs arithmetic and logical operations |
| **Instruction Memory (IMEM)** | Stores program instructions |
| **Data Memory (DMEM)** | Stores program data (load/store target) |
| **Program Counter (PC)** | Tracks current instruction address |

---

## Module Hierarchy

### Top-Level Module
- **cpu_top.v** - Top-level CPU instance (integration only, no TODO)

### Core RTL Modules (TODO Implementation Required)
- **datapath.v** - Main datapath combining ALU, registers, and multiplexers
- **control.v** - Instruction decoder and control signal generator
- **alu.v** - Arithmetic and Logical Unit
- **regfile.v** - 32-register file (R0-R31)
- **imem.v** - Instruction Memory
- **dmem.v** - Data Memory

---

## File Tree Structure

```
DSD_project2/
├── RTL Design (rtl/)
│   ├── alu.v                          # ALU implementation (TODO)
│   ├── control.v                       # Control Unit (TODO)
│   ├── cpu_top.v                       # Top-level module
│   ├── datapath.v                      # Datapath unit (TODO)
│   ├── dmem.v                          # Data Memory (TODO)
│   ├── imem.v                          # Instruction Memory (TODO)
│   └── regfile.v                       # Register File (TODO)
│
├── Testbench (tb/)
│   └── tb_cpu.v                        # CPU testbench (DO NOT MODIFY)
│
├── Simulation (sim/)
│   └── run_sim.sh                      # Simulation runner script (DO NOT MODIFY)
│
├── Synthesis (syn/)
│   ├── synth.tcl                       # Synthesis script (DO NOT MODIFY)
│   ├── run_syn.sh                      # Synthesis runner (DO NOT MODIFY)
│   ├── cpu_top.sdc                     # Synthesis Design Constraints (DO NOT MODIFY)
│   ├── open_ddc.sh                     # Design Compiler script (DO NOT MODIFY)
│   └── work/                           # Synthesis working directory
│
├── Place & Route (pnr/)
│   ├── pnr.tcl                         # PnR script (DO NOT MODIFY)
│   ├── run_pnr.sh                      # PnR runner (DO NOT MODIFY)
│   ├── build_ndm.tcl                   # NDM builder (DO NOT MODIFY)
│   └── work/                           # PnR working directory
│
├── Static Timing Analysis (sta/)
│   ├── sta.tcl                         # STA script (DO NOT MODIFY)
│   └── run_sta.sh                      # STA runner (DO NOT MODIFY)
│
├── Test Programs (programs/)
│   ├── test_simple.mem                 # Simple arithmetic test
│   ├── test_loadstore.mem              # Load/Store operations test
│   ├── test_addr_modes.mem             # Addressing modes test
│   ├── test_logic_shift.mem            # Logic and shift operations test
│   ├── test_fibonacci.mem              # Fibonacci sequence test
│   └── test_call.mem                   # Function call test
│
├── Scripts (scripts/)
│   └── init_student_env.sh             # Environment initialization (DO NOT MODIFY)
│
├── Setup
│   ├── setup_saed32.sh                 # SAED32 library setup script
│   └── .git/                           # Git repository metadata
│
└── Documentation
    ├── PROJECT_OVERVIEW.md             # This file
    └── project2_cpu_design_markdown.md # Original project specification

```

---

## Design Flow Stages

### 1. **RTL Design & Verification (RTL Simulation)**
- Implement Verilog modules in `rtl/`
- Run simulation with testbench in `tb/`
- Verify functionality against test programs in `programs/`
- **Script:** `sim/run_sim.sh`

### 2. **Synthesis**
- Convert RTL to gate-level netlist
- Target: SAED32 technology library
- **Script:** `syn/run_syn.sh`
- **Constraints:** `syn/cpu_top.sdc`

### 3. **Place & Route (PnR)**
- Place gates on silicon area
- Route interconnections
- **Script:** `pnr/run_pnr.sh`

### 4. **Static Timing Analysis (STA)**
- Verify timing constraints are met
- Check timing closure
- **Script:** `sta/run_sta.sh`

---

## Test Programs

The `programs/` directory contains MEM format test files for the CPU:

| Test File | Purpose |
|-----------|---------|
| `test_simple.mem` | Basic arithmetic operations (ADD, SUB, MUL) |
| `test_loadstore.mem` | Load/Store memory operations |
| `test_addr_modes.mem` | Different addressing modes |
| `test_logic_shift.mem` | Logical (AND, OR, XOR) and shift operations |
| `test_fibonacci.mem` | Fibonacci sequence computation |
| `test_call.mem` | Function call and branch operations |

---

## Implementation Requirements

### What to Implement (TODO Sections)
Each of the following RTL files contains `TODO` sections that must be implemented:

1. **alu.v** - Arithmetic Logic Unit
   - Implement arithmetic operations: ADD, SUB, MUL, DIV
   - Implement logical operations: AND, OR, XOR, NOT
   - Implement shift operations: SLL, SRL, SRA

2. **control.v** - Control Unit
   - Decode instruction opcode
   - Generate appropriate control signals for datapath
   - Handle different instruction types

3. **datapath.v** - Datapath
   - Multiplex ALU inputs and outputs
   - Connect register file, ALU, and memory
   - Handle data forwarding and pipeline stages

4. **regfile.v** - Register File
   - Implement 32 registers (R0-R31)
   - Support simultaneous read (2 ports) and write (1 port)
   - Handle register write enable

5. **imem.v** - Instruction Memory
   - Load instructions from program file
   - Provide instruction at given address

6. **dmem.v** - Data Memory
   - Load/store data operations
   - Support read and write operations

### What NOT to Modify
- `cpu_top.v` - Top-level integration (provided as-is)
- All testbench files in `tb/`
- All simulation/synthesis/PnR scripts
- Flow configuration files

---

## Instruction Format

The CPU supports a RISC instruction set with fixed 32-bit format. Typical instruction types include:

- **R-Type (Register):** `OPCODE RD RS1 RS2` - Register-to-register operations
- **I-Type (Immediate):** `OPCODE RD RS IMMEDIATE` - Register and immediate operations
- **M-Type (Memory):** `OPCODE RD ADDRESS` - Load/Store operations

---

## Getting Started

### 1. Setup Environment
```bash
cd DSD_project2
source scripts/init_student_env.sh
source setup_saed32.sh
```

### 2. Implement Modules
- Edit each TODO section in `rtl/*.v` files
- Add new signals/variables as needed
- Follow the module interface and port definitions

### 3. Simulate and Verify
```bash
cd sim
bash run_sim.sh
```

### 4. Run Full Flow (Optional)
```bash
# Synthesis
cd syn && bash run_syn.sh

# Place & Route
cd pnr && bash run_pnr.sh

# Static Timing Analysis
cd sta && bash run_sta.sh
```

---

## Directory Purposes Summary

| Directory | Purpose | Modifiable |
|-----------|---------|-----------|
| `rtl/` | RTL source code (Verilog modules) | ✅ YES (TODO sections only) |
| `tb/` | Testbench and test infrastructure | ❌ NO |
| `sim/` | Simulation scripts and tools | ❌ NO |
| `syn/` | Synthesis flow and scripts | ❌ NO |
| `pnr/` | Place & Route flow | ❌ NO |
| `sta/` | Static Timing Analysis | ❌ NO |
| `scripts/` | Setup and utility scripts | ❌ NO |
| `programs/` | Test program files (MEM format) | ✅ YES (reference only) |

---

## Key Technologies

- **HDL:** Verilog
- **Simulation:** VCS/ModelSim (determined by sim/run_sim.sh)
- **Synthesis:** Synopsys Design Compiler
- **PnR:** Cadence Innovus or Synopsys IC Compiler
- **STA:** Synopsys PrimeTime or similar
- **Technology:** SAED32 (32nm Educational Design Kit)

---

## Notes

- The project is a learning exercise in digital design fundamentals
- Each module has clear interface specifications
- Test programs verify different aspects of CPU functionality
- The complete design flow mimics industrial chip design workflow
- Proper Verilog coding practices should be followed
- All modules should be synthesizable and physical-design ready

---

## Additional Resources

Refer to `project2_cpu_design_markdown.md` for detailed:
- Instruction set specification
- Module-by-module implementation details
- Instruction encoding format
- Example instruction sequences
- Testing methodology

---

**Project Version:** DSD Project 2  
**Last Updated:** 2026  
**Status:** In Development
