# Provenance for the prior RBU regression log

`prior_rbu_regression.log` is an existing output from the original source workspace, timestamped 2026-10-23 11:45 local time. It records 13,440,425 RBU checks and zero mismatches, including all 11,082,241 PWM pairs and the RBU protocol checks. SHA-256 comparisons show that the RBU RTL, add/subtract/multiplier dependencies, and `mlkem_rbu_tb.v` in this artifact snapshot are byte-identical to the source files in the original workspace.

A fresh exhaustive run was also completed while preparing this artifact. The current run appears in `simulation/logs/rbu_modes_basemul.log`; the pre-existing run is retained separately for provenance. The fresh run used the same unchanged RBU sources and bench.
