# Verification audit

## RTL simulation

The nine benches were compiled and executed with the runner in `simulation/scripts/run_all.ps1`. Every `vvp` run exited successfully and produced its expected pass marker. The regression table is in `results/regression_summary.csv`; individual logs are in `simulation/logs`.

The available Icarus is version 12.0 development build `s20150603-1539-g2693dd32b`. On this Windows environment, `iverilog` produced a valid `.vvp` image and then exited with access-violation code `-1073741819`. This occurred for all nine compile commands. The generated images ran to completion. The runner labels those compiler results `WARN` and separates them from simulation results. A stable Icarus build should be used for a clean compile status in an independent environment.

The original multiplier bench sampled the output at the first rising edge after changing operands, even though `mlkem_modmult` has a registered product stage followed by a registered reduction/result stage. The original bench therefore observed stale results. In the artifact copy only, the test now holds each vector through two active edges before comparing. The RTL and sweep range are unchanged; the corrected test passed 23,800 vector checks.

The RBU bench completed 13,440,425 checks: corners, exhaustive two-dimensional slices, all 11,082,241 PWM pairs, randomized operations in all modes, ML-KEM zeta cases, and protocol checks. It reported zero mismatches. The exhaustive run took about 20 minutes locally.

The security testbench directly flips `dut.u_mul.prod_reg` for its product-upset case. Its 3C check applies a bit flip to a local copy of `r1` and calls a testbench function; it does not inject the corruption into the RTL adder/subtractor result path. Its GS test checks nominal output consistency and is not a GS fault-injection test. The bench's “fully immune” display message is not adopted as a research conclusion.

## Software models

`simulation/scripts/golden_model.py` ran successfully with Python 3. It reports the NTT/INTT roundtrip and schoolbook polynomial multiplication checks passed. Its generated JSON is included at `simulation/expected/mlkem_golden_model_dump.json`.

`fault_injection/source/host_security_validation.py` ran and processed 10,000 seeded software-model trials. It reported 9,742 detections (97.42% overall); the five category rates were 100%, 100%, 100%, 100%, and 87.10%. This model implements Python equations and mutations; it does not inject faults into RTL or hardware. Its fixed `latency_cycles` values are assumptions, not measurements. See `fault_injection/results/host_security_validation.log`.

## FPGA evidence

The workspace contains 23 text reports across the Vivado output folder and saved Vivado project runs. The report headers show Vivado 2026.1 and Artix-7 XC7A35T. Existing snapshots are not a fresh run during this artifact build. The October 2 routed timing report failed timing (WNS -2.801 ns; TNS -31.215 ns; 12 failing endpoints). The October 23 routed timing report met timing at 50 MHz (WNS 1.629 ns; TNS 0 ns; no failing endpoints). Resource counts are reported separately by snapshot because they differ. The XDC has fixed package pins and needs board-specific confirmation.

Vivado was not available in the command environment; fresh synthesis and routing were not run.

The available controller testbench checks NTT/INTT data correctness. The security bench instantiates the RBU alone, so it does not test top-level coefficient-memory write suppression or prove the controller's check-before-write behavior under injected faults. The FSM source implements per-write fault gating, but the artifact does not claim a two-word atomic commit.
