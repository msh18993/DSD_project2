# Project2 Description - CPU Design

- **Course:** EE361 디지털회로설계및언어
- **University:** Kyung Hee University
- **Instructor:** Suwan Kim (`suwankim@khu.ac.kr`)
- **Project:** Project2 - CPU Design
- **Goal:** Custom 32-bit RISC-style CPU를 Verilog로 구현

---

## 1. Project2 Overview

### 목표

Project2에서는 **custom 32-bit RISC-style CPU**를 Verilog로 구현한다.

### 구현 대상

각 모듈 파일의 `TODO` 부분을 구현해야 한다.

- 필요하다면 새로운 signal 또는 variable을 추가할 수 있다.
- 단, 테스트벤치와 flow 관련 파일은 수정하면 안 된다.

### 제한 사항

다음 항목은 수정 금지이다.

- `tb`
- `sim`
- `syn`
- `pnr`
- `sta`
- scripts

---

## 2. RISC 개념

### RISC: Reduced Instruction Set Computer

RISC는 CPU 명령어 수를 줄여 구조를 단순화하는 컴퓨터 설계 방식이다.

### CISC: Complex Instruction Set Computer

CISC 방식에서는 하나의 instruction이 여러 개의 내부 instruction으로 실행될 수 있다.

예시:

```asm
Add A, B
```

의미:

```text
메모리 A와 B의 값을 더해서 메모리 A에 저장한다.
```

### RISC 방식 예시

RISC에서는 하나의 instruction이 하나의 단순한 동작을 수행한다.

```asm
Load  r1, A       ; 메모리 A의 값을 레지스터 r1으로 불러온다
Load  r2, B       ; 메모리 B의 값을 레지스터 r2로 불러온다
Add   r3, r1, r2  ; r1과 r2를 더해서 r3에 저장한다
Store r3, A       ; 최종값을 다시 메모리 A에 저장한다
```

---

## 3. CPU 실행 구조

명령어 실행 과정은 크게 두 단계로 나눌 수 있다.

### 3.1 Fetch Stage

Instruction memory로부터 명령어를 읽어오는 단계이다.

### 3.2 Execute Stage

읽어온 명령어에 맞는 동작을 실행하는 단계이다.

### 3.3 주요 구성 요소

| 구성 요소 | 역할 |
|---|---|
| Control Unit | instruction을 해석하고 control signal 생성 |
| Registers | 빠른 임시 저장 공간 |
| Program Memory | instruction 저장 |
| Data Memory | load/store 대상 데이터 저장 |
| ALU | 산술 및 논리 연산 수행 |

---

## 4. CPU Design Module Hierarchy

`cpu_top.v`를 제외한 각 module의 `TODO` 부분을 구현해야 한다.

```text
cpu_top.v
├── control.v
├── datapath.v
│   ├── regfile.v
│   └── alu.v
├── imem.v
└── dmem.v
```

### Module Description

| File | Description |
|---|---|
| `cpu_top.v` | Top-level wrapper |
| `alu.v` | Combinational 32-bit ALU |
| `control.v` | Opcode-to-control-signals decoder |
| `datapath.v` | Register file, ALU muxes, PC update, delay slot 처리 |
| `regfile.v` | 32 x 32-bit register file |
| `imem.v` | 1024 x 32-bit instruction ROM |
| `dmem.v` | 1024 x 32-bit data RAM |

---

## 5. Detailed Dataflow Diagram 요약

### 5.1 `cpu_top.v`

Top-level wrapper이며 pure wiring 역할을 한다.

### 5.2 `datapath.v`

다음 기능을 담당한다.

- PC update
- Register access
- ALU mux 선택
- Writeback
- Delay-slot handling

### 5.3 `imem.v`

- 1024 x 32-bit instruction ROM
- `IADDR(pc)`를 입력으로 받아 `INSTR` 출력
- `IREQ = 1`

### 5.4 `control.v`

Instruction의 opcode와 register field를 바탕으로 다음 control signal을 생성한다.

- `reg_write`
- `mem_read`
- `mem_write`
- `alu_op`
- `alu_src_a`
- `alu_src_b`
- `wb_src`
- `is_jump`
- `is_branch`
- `is_link`
- `is_pc_rel`

### 5.5 `regfile.v`

- 32 x 32-bit register file
- ALU operand를 제공하고 writeback 결과를 저장한다.

### 5.6 `alu.v`

- 32-bit combinational ALU
- 산술, 논리, shift, rotate 연산 수행

### 5.7 `dmem.v`

- 1024 x 32-bit data RAM
- `DADDR`, `DWDATA`, `DREQ`, `DRW`, `DRDATA` interface 사용

---

## 6. Instruction Formats

각 instruction은 **32-bit word**이다.

### 6.1 Field Terminology

| Field | Bits | Description |
|---|---:|---|
| `opcode` | `instr[31:27]` | Instruction 선택 |
| `ra` | `instr[26:22]` | Destination register 또는 store data |
| `rb` | `instr[21:17]` | Source register, address base, branch target |
| `rc` | `instr[16:12]` | Source register 또는 branch condition value |
| `imm17` | `instr[16:0]` | 17-bit signed immediate |
| `imm22` | `instr[21:0]` | 22-bit PC-relative jump offset |
| `i_bit` | `instr[5]` | Shift amount selector |
| `shamt` | `instr[4:0]` | Immediate shift amount |
| `cond` | `instr[2:0]` | Branch condition selector |

---

## 7. Instruction Type별 동작

## 7.1 R-type

### Format

```text
opcode[31:27] | ra[26:22] | rb[21:17] | rc[16:12] | unused[11:0]
```

Unary instruction의 경우 `rb` field는 사용하지 않는다.

```text
opcode[31:27] | ra[26:22] | unused[21:17] | rc[16:12] | unused[11:0]
```

### 예시

```asm
ADD ra, rb, rc
```

동작:

```text
R[ra] <- R[rb] + R[rc]
```

대상 instruction:

- `ADD`
- `SUB`
- `AND`
- `OR`
- `XOR`
- Unary: `NEG`, `NOT`

### FSM transition 예시

```text
if IMEM[PC] == ADD ra rb rc:
    R[ra] <- R[rb] + R[rc]
    PC <- PC + 4
```

---

## 7.2 I-type

### Format

```text
opcode[31:27] | ra[26:22] | rb[21:17] | imm17[16:0]
```

`MOVI`처럼 `rb`가 필요 없는 경우:

```text
opcode[31:27] | ra[26:22] | unused[21:17] | imm17[16:0]
```

### 예시

```asm
ADDI ra, rb, imm17
```

동작:

```text
R[ra] <- R[rb] + sign_ext(imm17)
```

대상 instruction:

- `ADDI`
- `ANDI`
- `ORI`
- `MOVI`

### MOVI 동작

```text
R[ra] <- sign_ext(imm17)
```

### FSM transition 예시

```text
if IMEM[PC] == ADDI ra rb imm17:
    R[ra] <- R[rb] + sign_ext(imm17)
    PC <- PC + 4
```

---

## 7.3 Load / Store

### Format

```text
opcode[31:27] | ra[26:22] | rb[21:17] | imm17[16:0]
```

### Assembly examples

```asm
LD ra, imm17(rb)
ST ra, imm17(rb)
```

### 동작

```text
LD: R[ra] <- DMEM[addr]
ST: DMEM[addr] <- R[ra]
```

### Address calculation rule

```text
if rb == 5'b11111:
    addr <- zero_ext(imm17)
else:
    addr <- R[rb] + sign_ext(imm17)
```

### FSM transition

```text
if IMEM[PC] == LD ra rb imm17:
    R[ra] <- DMEM[addr]
    PC <- PC + 4

if IMEM[PC] == ST ra rb imm17:
    DMEM[addr] <- R[ra]
    PC <- PC + 4
```

---

## 7.4 J-type

### Format

```text
opcode[31:27] | unused[26:22] | imm22[21:0]
```

### 예시

```asm
J imm22
```

### FSM transition

```text
if IMEM[PC] == J imm22:
    branch_target_reg <- PC + 4 + sign_ext(imm22)
    branch_pending <- 1
    PC <- PC + 4
```

Jump target으로 바로 이동하지 않고 **delay slot**을 먼저 실행한 뒤 이동한다.

---

## 7.5 JL-type: Jump and Link

### Format

```text
opcode[31:27] | ra[26:22] | imm22[21:0]
```

### 예시

```asm
JL ra, imm22
```

### FSM transition

```text
if IMEM[PC] == JL ra imm22:
    R[ra] <- PC + 4
    branch_target_reg <- PC + 4 + sign_ext(imm22)
    branch_pending <- 1
    PC <- PC + 4
```

`JL`은 jump와 동시에 link register 역할로 `R[ra]`에 `PC + 4`를 저장한다.

---

## 7.6 Branch

### Format

```text
opcode[31:27] | unused[26:22] | rb[21:17] | rc[16:12] | unused[11:3] | cond[2:0]
```

### 예시

```asm
BR rb, rc, cond
```

### FSM transition

```text
if IMEM[PC] == BR rb rc cond:
    if condition(cond, R[rc]) is true:
        branch_target_reg <- R[rb]
        branch_pending <- 1
    PC <- PC + 4
```

Branch target은 `R[rb]`이다.

---

## 7.7 Branch and Link

### Format

```text
opcode[31:27] | ra[26:22] | rb[21:17] | rc[16:12] | unused[11:3] | cond[2:0]
```

### 예시

```asm
BRL ra, rb, rc, cond
```

### FSM transition

```text
if IMEM[PC] == BRL ra rb rc cond:
    R[ra] <- PC + 4
    if condition(cond, R[rc]) is true:
        branch_target_reg <- R[rb]
        branch_pending <- 1
    PC <- PC + 4
```

`BRL`은 branch와 동시에 `R[ra]`에 `PC + 4`를 저장한다.

---

## 8. PC Update and Delay Slot

### Normal instruction

```text
PC <- PC + 4
```

### Taken J / JL

```text
branch_target_reg <- PC + 4 + sign_ext(imm22)
branch_pending <- 1
PC <- PC + 4
```

### Taken BR / BRL

```text
branch_target_reg <- R[rb]
branch_pending <- 1
PC <- PC + 4
```

### Delay slot 이후 redirect

```text
When branch_pending == 1:
    PC <- branch_target_reg
    branch_pending <- 0
```

즉, jump 또는 branch가 taken되어도 다음 instruction 한 개는 먼저 실행되고, 그 다음 cycle에서 target으로 이동한다.

---

## 9. Opcodes

### 공통 규칙

#### Shift amount rule

```text
shift_amt = R[rc][4:0]  when instr[5] == 1'b1
shift_amt = shamt       otherwise
```

#### ST / LD address rule

```text
if rb == 5'b11111:
    addr = zero_ext(imm17)              // absolute addressing
else:
    addr = R[rb] + sign_ext(imm17)      // register-relative addressing
```

#### Reserved opcodes

- Opcode ID `20`: `STR` reserved, not decoded
- Opcode ID `22`: `LDR` reserved, not decoded

### Opcode Table

| ID | Mnemonic | Operation |
|---:|---|---|
| 0 | `ADD` | `R[ra] <= R[rb] + R[rc]` |
| 1 | `ADDI` | `R[ra] <= R[rb] + sign_ext(imm17)` |
| 2 | `SUB` | `R[ra] <= R[rb] - R[rc]` |
| 3 | `NEG` | `R[ra] <= -R[rc]` |
| 4 | `NOT` | `R[ra] <= ~R[rc]` |
| 5 | `AND` | `R[ra] <= R[rb] & R[rc]` |
| 6 | `ANDI` | `R[ra] <= R[rb] & sign_ext(imm17)` |
| 7 | `OR` | `R[ra] <= R[rb] | R[rc]` |
| 8 | `ORI` | `R[ra] <= R[rb] | sign_ext(imm17)` |
| 9 | `XOR` | `R[ra] <= R[rb] ^ R[rc]` |
| 10 | `LSR` | `R[ra] <= R[rb] >> shift_amt`, logical |
| 11 | `ASR` | `R[ra] <= $signed(R[rb]) >>> shift_amt` |
| 12 | `SHL` | `R[ra] <= R[rb] << shift_amt` |
| 13 | `ROR` | `R[ra] <= rotate_right(R[rb], shift_amt)` |
| 14 | `MOVI` | `R[ra] <= sign_ext(imm17)` |
| 15 | `J` | `PC <= pc + 32'd4 + sign_ext(imm22)` after delay slot |
| 16 | `JL` | Same as `J`, plus `R[ra] <= pc + 32'd4` |
| 17 | `BR` | If condition met: `PC <= R[rb]` after delay slot |
| 18 | `BRL` | Same as `BR`, plus `R[ra] <= pc + 32'd4` |
| 19 | `ST` | `dmem[addr] <= R[ra]` |
| 20 | `STR` | Reserved, not decoded |
| 21 | `LD` | `R[ra] <= dmem[addr]` |
| 22 | `LDR` | Reserved, not decoded |

---

## 10. `imem.v` - Instruction Memory

### Purpose

현재 PC address에 해당하는 instruction을 제공한다.

### Memory organization

- 1024 entries
- 각 entry는 32-bit
- `MEM_FILE`을 이용해 `$readmemh`로 로드

### Read behavior

- Asynchronous read
- `iaddr`가 바뀌면 `instr`이 즉시 update된다.

### Addressing rule

- `PC` / `iaddr`는 byte address이다.
- `mem[]`은 word-indexed이다.
- instruction 하나는 4 bytes이다.
- 따라서 memory index로 `iaddr[31:2]`를 사용한다.

### Ports

| Type | Signal | Description |
|---|---|---|
| Input | `iaddr` 32-bit | Program counter에서 온 byte address |
| Output | `instr` 32-bit | 요청한 address의 instruction word |

---

## 11. `dmem.v` - Data Memory

### Purpose

`LD`와 `ST` instruction을 위한 program data를 저장한다.

### Write behavior

Synchronous write:

```text
if dreq == 1'b1 and drw == 1'b1:
    mem[daddr[31:2]] <- dwdata
```

### Read behavior

Asynchronous read:

```text
Drdata = mem[daddr[31:2]]
```

### Addressing rule

- `daddr`는 byte address이다.
- `mem[]`은 word-indexed이다.
- word 하나는 4 bytes이다.
- 따라서 memory index로 `daddr[31:2]`를 사용한다.

### Ports

| Type | Signal | Description |
|---|---|---|
| Input | `clk` 1-bit | Clock |
| Input | `daddr` 32-bit | Byte address |
| Input | `dreq` 1-bit | Load 또는 store 진행 시 asserted |
| Input | `drw` 1-bit | `1'b1` = write/store, `1'b0` = read/load |
| Input | `dwdata` 32-bit | Store 시 write할 word |
| Output | `drdata` 32-bit | Byte address에 대한 asynchronous read 결과 |

---

## 12. `control.v` - Control Unit

### Purpose

Opcode를 decode하여 datapath control signal을 생성한다.

### Behavior

- Pure combinational logic
- Safe default로 시작한 뒤 `case(opcode)`에서 필요한 signal만 override한다.

### Safe defaults

- Register write 없음
- Memory read/write 없음
- Jump 또는 branch 없음
- ALU default operation은 `ADD`
- Mux select default는 `0`

### Main decoding rules

| Instruction type | Decoding rule |
|---|---|
| R-type | `R[ra]`에 write, ALU는 `R[rb]`, `R[rc]` 사용 |
| I-type | `R[ra]`에 write, ALU는 `R[rb]`, `sign_ext(imm17)` 사용 |
| Unary | `R[ra]`에 write, ALU는 `R[rc]` 사용 |
| Shift | `R[ra]`에 write, ALU는 `R[rb]`, `shift_amount` 사용 |
| MOVI | `R[ra]`에 `sign_ext(imm17)` write |
| LD | Memory read, `R[ra]`에 write, ALU가 address 계산 |
| ST | Memory write, ALU가 address 계산 |
| J / JL | Jump request, `JL`은 `PC + 4`도 write |
| BR / BRL | Branch request, `BRL`은 `PC + 4`도 write |

### LD/ST address mode

```text
if rb_field == 5'b11111:
    addr = zero_ext(imm17)
else:
    addr = R[rb] + sign_ext(imm17)
```

### Control Signal Ports

| Type | Signal | Description |
|---|---|---|
| Input | `opcode` 5-bit | `instr[31:27]`, opcode field |
| Input | `rb_field` 5-bit | `instr[21:17]`, LD/ST absolute addressing 판단용 |
| Output | `reg_write` 1-bit | 현재 instruction이 destination register `ra`에 write하는지 여부 |
| Output | `mem_read` 1-bit | 현재 instruction이 `LD`인지 여부 |
| Output | `mem_write` 1-bit | 현재 instruction이 `ST`인지 여부 |
| Output | `alu_op` 4-bit | ALU operation selector |
| Output | `alu_src_a` 2-bit | ALU input `a` 선택 |
| Output | `alu_src_b` 2-bit | ALU input `b` 선택 |
| Output | `wb_src` 2-bit | Writeback data 선택 |
| Output | `is_jump` 1-bit | `J` 또는 `JL`일 때 asserted |
| Output | `is_branch` 1-bit | `BR` 또는 `BRL`일 때 asserted |
| Output | `is_link` 1-bit | `JL` 또는 `BRL`일 때 asserted |
| Output | `is_pc_rel` 1-bit | Future PC-relative branch용 reserved signal, `1'b0`에 tie |

---

## 13. `datapath.v` - Datapath

### Purpose

Register file, ALU, write-back logic, data memory interface, PC update logic을 연결하여 instruction을 실행한다.

### Main tasks

1. Instruction field 추출
   - `opcode`
   - `ra`
   - `rb`
   - `rc`
   - `imm17`
   - `imm22`
   - `i_bit`
   - `shamt`
   - `cond`

2. Register file read/write
   - `R[ra]`, `R[rb]`, `R[rc]` read
   - `reg_write = 1`이면 `wb_data`를 `R[ra]`에 write

3. ALU input 선택
   - `alu_src_a`: `R[rb]`, `R[rc]`, `0` 중 선택
   - `alu_src_b`: `R[rc]`, `sign_ext(imm17)`, `zero_ext(imm17)`, `shift_amount` 중 선택

4. Write-back data 선택
   - `wb_src`: ALU result, dmem read data, `PC + 4` 중 선택

5. Data memory interface drive
   - `dmem_addr = alu_result`
   - `dmem_wdata = R[ra]`

6. PC update
   - Normal: `PC <- PC + 4`
   - Branch/jump: delay slot 실행 후 saved target으로 redirect

---

## 14. Datapath Mux Encodings

`control.v`가 select signal을 생성하고, `datapath.v`가 이를 사용하여 ALU operand와 write-back data를 선택한다.

### 14.1 `alu_src_a`

ALU input `a`에 들어갈 값을 선택한다.

| Encoding | Meaning |
|---|---|
| `2'b00` | `R[rb]` |
| `2'b01` | `R[rc]` |
| `2'b10` | `32'h0` |
| default | `32'h0` |

### 14.2 `alu_src_b`

ALU input `b`에 들어갈 값을 선택한다.

| Encoding | Meaning |
|---|---|
| `2'b00` | `R[rc]` |
| `2'b01` | `sign_ext(imm17)` |
| `2'b10` | `zero_ext(imm17)` |
| `2'b11` | `{ 27'h0, shift_amount }` |
| default | `32'h0` |

### 14.3 `wb_src`

Register write data를 선택한다.

| Encoding | Meaning |
|---|---|
| `2'b00` | `alu_result` |
| `2'b01` | `dmem_rdata` |
| `2'b10` | `pc_reg + 32'd4` |
| default | `alu_result` |

---

## 15. `datapath.v` Port Summary

| Type | Signal | Description |
|---|---|---|
| Input | `clk` 1-bit | Clock |
| Input | `rstn` 1-bit | Active-low asynchronous reset |
| Input | `instr` 32-bit | Current instruction from imem |
| Input | `dmem_rdata` 32-bit | Data memory에서 읽은 word |
| Input | `reg_write` 1-bit | Register file write enable |
| Input | `mem_read` 1-bit | `LD`일 때 asserted, top-level에서 `DREQ` drive에 사용 |
| Input | `mem_write` 1-bit | `ST`일 때 asserted, top-level에서 `DREQ`, `DRW` drive에 사용 |
| Input | `alu_op` 4-bit | ALU operation selector |
| Input | `alu_src_a` 2-bit | ALU input `a` 선택 |
| Input | `alu_src_b` 2-bit | ALU input `b` 선택 |
| Input | `wb_src` 2-bit | Register writeback data 선택 |
| Input | `is_jump` 1-bit | `J` 또는 `JL`일 때 asserted |
| Input | `is_branch` 1-bit | `BR` 또는 `BRL`일 때 asserted |
| Input | `is_link` 1-bit | `JL` 또는 `BRL`일 때 asserted, informational |
| Input | `is_pc_rel` 1-bit | Future PC-relative branch용 reserved signal |
| Output | `pc` 32-bit | Program counter, top-level의 `IADDR` drive |
| Output | `dmem_addr` 32-bit | Data memory address, top-level의 `DADDR` drive |
| Output | `dmem_wdata` 32-bit | Store 시 write할 word, top-level의 `DWDATA` drive |
| Output | `opcode` 5-bit | `instr[31:27]`, control에 전달 |
| Output | `rb_field` 5-bit | `instr[21:17]`, control에 전달 |

---

## 16. `alu.v` - ALU

### Purpose

32-bit combinational ALU이다.

### Ports

| Type | Signal | Description |
|---|---|---|
| Input | `a` 32-bit | Operand A |
| Input | `b` 32-bit | Operand B |
| Input | `alu_op` 4-bit | Operation selector |
| Output | `result` 32-bit | Combinational result |

### ALU Operation Encoding

| `alu_op` | Name | Meaning |
|---|---|---|
| `4'b0000` | `ALU_ADD` | `a + b` |
| `4'b0001` | `ALU_SUB` | `a - b` |
| `4'b0010` | `ALU_NEG` | Negation of `a` |
| `4'b0011` | `ALU_NOT` | Bitwise NOT of `a` |
| `4'b0100` | `ALU_AND` | `a & b` |
| `4'b0101` | `ALU_OR` | `a | b` |
| `4'b0110` | `ALU_XOR` | `a ^ b` |
| `4'b0111` | `ALU_LSR` | Logical right shift of `a` by `b[4:0]` |
| `4'b1000` | `ALU_ASR` | Arithmetic right shift of `a` by `b[4:0]` |
| `4'b1001` | `ALU_SHL` | Logical left shift of `a` by `b[4:0]` |
| `4'b1010` | `ALU_ROR` | Rotate `a` right by `b[4:0]` |
| `4'b1111` | `ALU_PASSB` | Pass `b` through unchanged |
| default | - | `32'h0` |

---

## 17. `regfile.v` - Register File

### Purpose

CPU의 임시 값을 저장하는 32개의 general-purpose register를 구현한다.

### Memory organization

- 32 entries
- 각 entry는 32-bit

### Reset

- Active-low asynchronous reset
- `rstn = 0`이면 모든 register를 `32'h0`으로 clear

### Read behavior

Asynchronous read:

```text
ra_data = R[ra_addr]
rb_data = R[rb_addr]
rc_data = R[rc_addr]
```

### Write behavior

Synchronous write on positive edge of `clk`:

```text
if we == 1 and wr_addr != 0:
    R[wr_addr] <- wr_data
```

### R0 read/write rule

`R0`은 constant zero register이다.

#### Read

```text
if addr == 5'h0:
    output 32'h0
else:
    output regs[addr]
```

#### Write

```text
if we == 1 and wr_addr != 5'h0:
    regs[wr_addr] <- wr_data

if wr_addr == 5'h0:
    ignore the write
```

### Ports

| Type | Signal | Description |
|---|---|---|
| Input | `clk` 1-bit | Clock |
| Input | `rstn` 1-bit | Active-low asynchronous reset |
| Input | `ra_addr` 5-bit | Read port A address |
| Input | `rb_addr` 5-bit | Read port B address |
| Input | `rc_addr` 5-bit | Read port C address |
| Input | `we` 1-bit | Write enable |
| Input | `wr_addr` 5-bit | Write port address |
| Input | `wr_data` 32-bit | Write data |
| Output | `ra_data` 32-bit | Asynchronous read at `ra_addr` |
| Output | `rb_data` 32-bit | Asynchronous read at `rb_addr` |
| Output | `rc_data` 32-bit | Asynchronous read at `rc_addr` |

---

## 18. `cpu_top.v` - Top-level Wrapper

### Purpose

`control.v`, `datapath.v`, imem interface, dmem interface를 연결한다.

`cpu_top.v`는 pure structural wiring 역할이며 수정하지 않는다.

### Ports

| Type | Signal | Description |
|---|---|---|
| Input | `CLK` 1-bit | Clock |
| Input | `RSTN` 1-bit | Active-low asynchronous reset |
| Input | `INSTR` 32-bit | `IADDR`에 대해 imem에서 반환된 instruction |
| Input | `DRDATA` 32-bit | `DADDR`에 대해 dmem에서 반환된 word |
| Output | `IADDR` 32-bit | 다음 instruction fetch를 위한 byte address, datapath 내부 PC가 직접 drive |
| Output | `IREQ` 1-bit | Instruction fetch strobe, skeleton에서는 `1'b1`로 tie |
| Output | `DADDR` 32-bit | Data memory access byte address, datapath 내부 ALU result가 drive |
| Output | `DREQ` 1-bit | 현재 instruction이 data memory access, 즉 `LD` 또는 `ST`를 수행하면 asserted |
| Output | `DRW` 1-bit | `DREQ`와 함께 쓰는 read/write direction bit, `1'b1` = write/ST, `1'b0` = read/LD |
| Output | `DWDATA` 32-bit | Store 시 data memory에 write할 32-bit word, `R[ra]`와 동일 |
| Output | `CONSIG` 1-bit | Future status bit, skeleton에서는 `1'b0`로 tie |

---

## 19. Evaluation: Tentative, Revised 26.05.21

세 가지 metric이 독립적으로 평가된다.

### Score formula per metric

```text
score_X = S * (X_max - X_yours) / (X_max - X_min)
```

### Metrics

| Metric | Max score S | Source |
|---|---:|---|
| Performance | 30 | `sta/reports/*_clock.rpt`의 clock period, `sta/reports/*_timing.rpt`의 timing result |
| Power | 15 | `sta/reports/*_power.rpt`의 Total Power |
| Area | 15 | `sta/reports/*_qor.rpt`의 Total cell area |

### Timing note

- Setup timing violation은 없어야 한다.
- Hold time violation은 허용된다.

---

## 20. Presentation

### Logistics

| Item | Requirement |
|---|---|
| Time | Team당 5분 |
| Presenter | Team당 1명 |
| Slides | PDF 또는 PPTX |
| Due | Group2: 6/9, Group1: 6/11 |

### 포함해야 할 내용

1. Architecture choice
   - 무엇을 만들었는지
   - 왜 그렇게 설계했는지

2. Experimental results
   - Verilog simulation 결과: pass 또는 fail
   - STA 이후 timing report: setup timing violation 없음
   - Critical path analysis
   - Performance, Power, Area 값

3. Difficulties
   - Verilog implementation 과정에서 겪은 어려움

---

## 21. Report

### 필수 사항

- **DC-Compiler screenshot 포함 필수**
- **IC-Compiler II screenshot 포함 필수**
- Page limit 없음
- Due: **June 12th**

### Report에 포함해야 할 내용

1. Architecture description
2. RTL design choices
3. PPA value
   - Presentation과 동일해야 함
4. Critical path analysis
5. Verilog implementation 중 겪은 difficulties

---

## 22. Submission

### Due

- **June 12th**

### 제출 항목

1. Presentation file
2. Report
3. Final logs in `sta/reports`
4. RTL files

---

## 23. 구현 체크리스트

### RTL 구현

- [ ] `alu.v`의 ALU operation 구현
- [ ] `control.v`의 opcode decode 및 control signal 생성 구현
- [ ] `datapath.v`의 instruction field 추출 구현
- [ ] `datapath.v`의 ALU mux 구현
- [ ] `datapath.v`의 writeback mux 구현
- [ ] `datapath.v`의 PC update 및 delay-slot 처리 구현
- [ ] `regfile.v`의 asynchronous read 구현
- [ ] `regfile.v`의 active-low reset 구현
- [ ] `regfile.v`의 R0 constant zero rule 구현
- [ ] `imem.v`의 word-indexed asynchronous read 구현
- [ ] `dmem.v`의 synchronous write 및 asynchronous read 구현

### 검증 및 제출

- [ ] Verilog simulation pass 확인
- [ ] Synthesis 수행
- [ ] PnR 수행
- [ ] STA 수행
- [ ] Setup timing violation 없음 확인
- [ ] Critical path 분석
- [ ] Performance / Power / Area 값 정리
- [ ] DC-Compiler screenshot 저장
- [ ] IC-Compiler II screenshot 저장
- [ ] Presentation 작성
- [ ] Report 작성
- [ ] `sta/reports` final logs 정리
- [ ] RTL files 제출 준비

---

## 24. 핵심 구현 포인트 요약

- Instruction은 32-bit word이며 `opcode = instr[31:27]`이다.
- PC와 memory address는 byte address이지만, instruction/data memory는 word-indexed이므로 `[31:2]`를 index로 사용한다.
- Register file은 32 x 32-bit이며 `R0`은 항상 `0`으로 읽혀야 하고 write는 무시해야 한다.
- `LD/ST`에서 `rb == 5'b11111`이면 absolute addressing으로 `zero_ext(imm17)`을 사용한다.
- Jump와 branch는 delay slot을 가진다.
- `J/JL` target은 `PC + 4 + sign_ext(imm22)`이다.
- `BR/BRL` target은 `R[rb]`이다.
- `JL/BRL`은 link 동작으로 `R[ra] <- PC + 4`를 수행한다.
- `control.v`는 combinational decoder이며 safe defaults를 먼저 설정해야 한다.
- `datapath.v`는 ALU operand mux, writeback mux, memory interface, PC update를 담당한다.

