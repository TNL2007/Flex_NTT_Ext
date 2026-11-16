# Architecture and source audit

## Data path

The selected Vivado project identifies `mlkem_ntt_fsm` as top and includes seven synthesizable files: controller, RBU, modular adder, modular subtractor, modular multiplier, coefficient memory, and twiddle-factor ROM. `mlkem_tf_mem_hexload.v` is an optional simulation-oriented ROM loader and is not in the Vivado top-level source list.

`mlkem_ntt_fsm` iterates the transform stages and schedules the RBU. The FSM reads coefficient pairs from `mlkem_coe_mem`, reads twiddles from `mlkem_tf_mem`, selects CT for forward NTT and GS for inverse NTT, waits for the RBU, checks its fault output, then writes coefficient results. The controller sets `mem_wr_en` only in its write states after the RBU completion check. On a detected fault, it suppresses writes and transitions to the done state.

`mlkem_rbu` latches operands and mode on `start`. Its modes are encoded 0=CT, 1=GS, 2=PWM, and 3=BASEMUL. CT and GS use the arithmetic units for the butterfly equations. PWM returns one modular product. BASEMUL reuses the multiplier across four products and combines them over the eight-cycle operation schedule. See RTL comments and `testbench/rbu/mlkem_rbu_tb.v` for the detailed protocol checks.

`mlkem_modmult` registers a 24-bit operand product, estimates the quotient using Barrett constant 20158 for q=3329, reduces the remainder, and registers a modulo-7 comparison between the registered product residue and the product residue predicted from the operand residues. The fault flag is sticky until reset in the RBU.

## Monitored invariants

For CT, `r0` and `r1` are checked against `(r0+r1) mod q = 2*a0 mod q`. For GS, `r0` is checked against `(a0+a1) mod q`. The controller uses the RBU fault output as a check-before-write gate for the NTT coefficient pair. It gates each coefficient write, which occurs in a separate cycle; this is not an atomic two-word memory transaction. The RBU does not implement the same pair invariant for PWM or BASEMUL; the multiplier residue checker remains in their shared multiplication path.

## Source inventory and dependencies

| Artifact files | Purpose | Dependencies / relevance |
|---|---|---|
| `rtl/controller/mlkem_ntt_fsm.v` | NTT/INTT scheduler and write control | Depends on RBU, coefficient memory, twiddle ROM, arithmetic units |
| `rtl/rbu/mlkem_rbu.v` | Reconfigurable CT/GS/PWM/BASEMUL datapath | Depends on modular adder, subtractor, multiplier |
| `rtl/arithmetic/mlkem_modadd.v`, `mlkem_modsub.v`, `mlkem_modmult.v` | q=3329 arithmetic and product integrity check | Clocked multiplier needs the provided pipeline-aware bench |
| `rtl/memory/mlkem_coe_mem.v`, `mlkem_tf_mem.v` | Coefficient memory and twiddle ROM | Used by controller; ROM bench checks entries |
| `rtl/memory/mlkem_tf_mem_hexload.v` | Hex-file ROM helper | Optional; used only by hex-load testbench |
| `testbench/arithmetic/*.v` | Add, subtract, multiply verification | Icarus; the multiplier bench copy was aligned to the pipeline latency |
| `testbench/rbu/mlkem_rbu_tb.v` | RBU modes, BASEMUL, protocol, randomized/exhaustive tests | Arithmetic modules; includes exhaustive PWM sweep |
| `testbench/controller/mlkem_ntt_fsm_tb.v` | NTT/INTT against supplied vectors | All top-level RTL, vectors under simulation input/expected dirs |
| `testbench/memory/*.v` | Coefficient/twiddle memory tests | Memory RTL and twiddle vectors |
| `testbench/security/tb_security_validation.v` | Nominal invariant, one direct product-register upset, and testbench-side invariant examples | RBU/arithmetic RTL; claims are qualified in verification notes |
| `simulation/scripts/golden_model.py` | NTT/INTT, BASEMUL, polynomial reference model | Python standard library; creates JSON output in current directory |
| `fault_injection/source/host_security_validation.py` | Seeded mathematical fault campaign | Python standard library; software-only model |
| `fpga/constraints/constraints.xdc` | Artix-7 I/O and timing constraints | Check board pin mapping before use |
| `fpga/vivado_scripts/reproduce_fpga.tcl` | Portable synthesis/place/route/report flow | Vivado 2026.1 used for the archived reports; fresh run requires Vivado |
| `fpga/reports/**/*.rpt` | Existing synthesis, placement, routing, timing, utilization, DRC, and methodology report text | Machine-specific header strings removed; report date/state retained |
| `results/*.csv` | Metric snapshots parsed from Vivado reports | Keeps the October 2 and October 23 observations separate |

The root project had 19 Verilog source files when generated `glbl.v` is counted: 7 top-level synthesizable RTL files, 9 testbenches, 1 optional twiddle hex loader, 1 separate ASIC memory model, and 1 generated Vivado global module. The artifact keeps the 17 project-authored RTL and testbench files relevant to FPGA/RBU simulation; it excludes the generated `glbl.v` and separate ASIC memory implementation.

