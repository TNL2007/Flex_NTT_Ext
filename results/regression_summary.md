# Regression summary

Fresh RTL simulation was run using Icarus Verilog 12.0 (development build `s20150603-1539-g2693dd32b`). All nine benches returned zero from `vvp` and emitted their expected pass markers. The Icarus compiler wrote each simulation image but then exited with Windows access-violation code `-1073741819`; the script records this as a compile warning, not a clean compiler pass. The images were run successfully.

- Modular add: 11,082,241 cases passed.
- Modular subtract: 11,082,241 cases passed.
- Modular multiplier: 23,800 vector checks passed after the artifact copy of the testbench was aligned to the two-stage pipeline latency.
- Coefficient memory: all 256 locations and the address isolation checks passed.
- Twiddle ROM: all 256 entries passed.
- Hex-loaded twiddle ROM: all 256 entries passed.
- Security-validation bench: its four internal audit gates passed; see the scope qualification in `documentation/verification.md`.
- NTT/INTT: all 256 forward outputs and all 256 inverse outputs matched the expected vectors.
- RBU modes and BASEMUL: 13,440,425 checks passed with zero mismatches. This exhaustive run took about 20 minutes in the local Icarus environment.

Python reference model passed its assertions. The seeded host-side software model completed 10,000 simulated mutations and reported 97.42% detection; this is software-only model output, not hardware measurement.

Vivado was unavailable, so FPGA synthesis/routing was not rerun. Archived reports are included and distinguished by report date; the 2026-10-02 timing snapshot failed timing, while the 2026-10-23 routed report met the 50 MHz constraints.
