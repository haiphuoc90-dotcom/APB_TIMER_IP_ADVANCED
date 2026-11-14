# APB Timer IP Design & Verification

## Overview
This repository contains the RTL design, testbench framework, and verification testcases for a 64-bit Timer IP with an ARM AMBA 3 APB Slave interface.

## Architecture
- **`rtl/timer_top.v`**: Top-level module integrating APB slave, register, counter control, counter, and interrupt blocks.
- **`rtl/apb_slave.v`**: AMBA 3 APB Slave interface supporting 1-cycle wait states and PSLVERR error handling.
- **`rtl/register.v`**: Memory-mapped register file (`TCR`, `TDR0`, `TDR1`, `TCMP0`, `TCMP1`, `TIER`, `TISR`, `THCSR`) with byte strobe (`tim_pstrb`) support.
- **`rtl/counter_control.v`**: Prescaler clock divider (divide by $2^{\text{div\_val}}$ for `div_val` = 0..8), auto-clear edge detection, and debug halt acknowledge.
- **`rtl/counter.v`**: 64-bit synchronous counter with clear, write-select, and enable priorities.
- **`rtl/interrupt.v`**: 64-bit comparator with RW1C (Read/Write 1 to Clear) interrupt status logic.

## Directory Structure
```text
code/
├── rtl/                # RTL Verilog source files
│   ├── apb_slave.v
│   ├── counter.v
│   ├── counter_control.v
│   ├── interrupt.v
│   ├── register.v
│   └── timer_top.v
├── tb/                 # Testbench & golden model
│   └── test_bench.v
├── testcases/          # Regression testcases
│   ├── apb_error_handling.v
│   ├── apb_protocol_chk.v
│   ├── apb_wait_state.v
│   ├── cnt_ctrl_chk.v
│   ├── cnt_halt_chk.v
│   ├── counter_chk.v
│   ├── interrupt_chk.v
│   ├── reg_1hot_chk.v
│   ├── reg_byte_access.v
│   ├── reg_init_chk.v
│   ├── reg_reserved_chk.v
│   └── reg_rw_chk.v
└── sim/                # Simulation scripts
    ├── compile.f
    ├── rtl.f
    ├── tb.f
    ├── pat.list
    ├── run.csh
    ├── report.csh
    └── Makefile
```

## How to Run Simulation

### 1. QuestaSim / ModelSim
```bash
cd sim
make all TESTNAME=counter_chk
```

### 2. Icarus Verilog
```bash
cd sim
cp ../testcases/counter_chk.v run_test.v
iverilog -g2012 -o sim_test.vvp -I. -f compile.f
vvp sim_test.vvp
```
