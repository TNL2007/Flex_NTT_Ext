# Reproduction guide

## RTL

Requirements: Icarus Verilog with `iverilog` and `vvp`, plus PowerShell 5.1+ (Windows) or PowerShell 7+.

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\simulation\scripts\run_all.ps1
```

The script builds in `simulation/logs/build`, runs each image from `simulation/logs` so `$readmemh` and VCD paths are stable, records test logs, and writes `results/regression_summary.csv`. The RBU suite exhaustively checks all q-by-q PWM input pairs and also covers CT/GS/BASEMUL directed and randomized cases.

The NTT/INTT test reads `simulation/inputs/mlkem_ntt_input.hex`, checks against `simulation/expected/mlkem_ntt_expected.hex`, and then checks inverse output against `simulation/expected/mlkem_intt_expected.hex`. The twiddle memory tests use `simulation/inputs/mlkem_zetas.hex` and `mlkem_gammas.hex`.

## Python

```powershell
python .\simulation\scripts\golden_model.py
python .\fault_injection\source\host_security_validation.py
```

Both use only the Python standard library. The first command writes `simulation/expected/mlkem_golden_model_dump.json` beside the package. The second prints simulated detection counts; it does not produce hardware measurements.

## FPGA

The archived target is `xc7a35tcsg324-1`, with a 50 MHz clock and board-level I/O constraints from `fpga/constraints/constraints.xdc`. Verify that the package pin map matches the chosen board.

```powershell
vivado -mode batch -source .\fpga\vivado_scripts\reproduce_fpga.tcl
```

Fresh reports and a design checkpoint are written under `fpga/reports/run`. This flow was prepared but not executed in the current environment because Vivado was unavailable. The archived reports were made by Vivado 2026.1; using another version can change results.

