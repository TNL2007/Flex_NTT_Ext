# Anonymous release artifact inventory

This manifest lists the files in this package and summarizes the recursive source-tree audit. No original source files were modified.

## Included

| Path | Description | Dependencies / relevance |
|---|---|---|
| `rtl/controller/mlkem_ntt_fsm.v` | Top-level NTT/INTT scheduler and gated coefficient writes | Depends on RBU, arithmetic, and memory RTL |
| `rtl/rbu/mlkem_rbu.v` | RBU modes CT, GS, PWM, BASEMUL and its fault outputs | Depends on modular arithmetic units |
| `rtl/arithmetic/mlkem_modadd.v` | Modular addition, q=3329 | Used by RBU |
| `rtl/arithmetic/mlkem_modsub.v` | Modular subtraction, q=3329 | Used by RBU |
| `rtl/arithmetic/mlkem_modmult.v` | Pipelined Barrett multiplier and modulo-7 product check | Used by RBU |
| `rtl/memory/mlkem_coe_mem.v` | Coefficient memory | Used by FSM |
| `rtl/memory/mlkem_tf_mem.v` | Twiddle ROM | Used by FSM and memory bench |
| `rtl/memory/mlkem_tf_mem_hexload.v` | Optional test ROM loaded from hex vectors | Used by hex-load bench, not in top-level FPGA source list |
| `testbench/arithmetic/*.v` | Add/subtract/multiply benches | Multiplier bench in artifact copy was corrected for pipeline latency |
| `testbench/rbu/mlkem_rbu_tb.v` | Full RBU operational and protocol test | Includes PWM exhaustive sweep and BASEMUL schedule |
| `testbench/controller/mlkem_ntt_fsm_tb.v` | End-to-end NTT and INTT vector checks | Uses included input and expected vectors |
| `testbench/memory/*.v` | Coefficient and twiddle memory benches | Includes ZETA/GAMMA vectors |
| `testbench/security/tb_security_validation.v` | RTL-level product upset and invariant examples | Verification caveats documented |
| `simulation/scripts/golden_model.py` | Python golden reference | Python standard library |
| `simulation/inputs/*.hex` | NTT input and twiddle ROM vectors | Read by testbenches/model |
| `simulation/expected/*` | NTT/INTT outputs and generated golden model JSON | Expected values / run output |
| `simulation/scripts/run_all.ps1` | Icarus compile/run driver | PowerShell and Icarus Verilog |
| `fault_injection/source/host_security_validation.py` | Seeded Python fault-model campaign | Python standard library; software-only |
| `fault_injection/results/host_security_validation.log` | Captured software model output | Not physical evidence |
| `fpga/constraints/constraints.xdc` | Existing Artix-7 clock, I/O, package pin constraints | Board-specific pins must be checked |
| `fpga/vivado_scripts/reproduce_fpga.tcl` | Portable synthesis/place/route/report flow | Vivado and Artix-7 device support |
| `fpga/reports/vivado_output/*.rpt` | 11 existing Vivado report snapshots | Header host/path scrubbed; copyright retained |
| `fpga/reports/project_runs/{synth_1,impl_1}/*.rpt` | 12 saved Vivado project-run reports | Header host/path scrubbed; copyright retained |
| `results/resource_utilization.csv` | Parsed utilization at two report dates | Keeps report snapshots separate |
| `results/timing_summary.csv` | Parsed routed timing at two report dates | Includes the older failing report and newer passing report |
| `documentation/*.md`, `README.md` | Architecture, verification, reproduction, security scope, citations | Based on source inspection and test output |
| `LICENSE_PENDING.md` | Release status and license requirement | No license found in source workspace |

## Audited source-tree inventory

The recursive scan found 19 Verilog files: the 7 top-level RTL sources, 9 testbenches, the optional hex-loaded twiddle ROM, the separate ASIC coefficient-memory model, and Vivado-generated `glbl.v`. It also found 7 Python files, 12 Tcl files, 3 XDC files including generated constraints, 1 SDC, 23 report files, 5 authored Markdown/README files, 11 `.hex` files, 1 PDF, 2 PPTX files, 5 VCD waveforms, 7 compiled `.vvp` files, one bitstream, six DCP checkpoints, and numerous Vivado project/cache/log outputs.

Authored Python files: `Golden_model.py`, `host_security_validation.py`, `asic/scripts/run_asic_estimation.py`, `asic/scripts/generate_schematics.py`, `make_presentation.py`, `make_master_presentation.py`, and `make_comprehensive_presentation.py`. Only the first two are included. The schematic and presentation generators are out of scope for reproducing the RTL/FPGA results; the ASIC estimator is an assumed-parameter model, not synthesis output.

Top-level Tcl files audited: `check_bitstream.tcl`, `check_synth_timing.tcl`, `run_full_impl.tcl`, `run_impl.tcl`, `run_vivado_flow.tcl`, and `synth_vivado.tcl`. Only a new portable, source-root-relative Vivado flow is included; original scripts contain absolute local paths. ASIC Tcl files are excluded because their file references do not resolve consistently from the documented invocation and the ASIC source set is incomplete.

## Additional discovered files excluded from this package

| Source-tree files | Purpose and audit finding |
|---|---|
| `run_vivado.bat`, `run_full_impl.tcl`, `run_impl.tcl`, `run_vivado_flow.tcl`, `synth_vivado.tcl` | Original FPGA launch/implementation wrappers; hard-code the local project path or assume the original working directory. Replaced by `fpga/vivado_scripts/reproduce_fpga.tcl`. |
| `check_bitstream.tcl`, `check_synth_timing.tcl` | Local-path checks for bitstream and timing outputs. The binary bitstream is excluded; timing data is retained in sanitized reports. |
| `run_asic.bat` | Runs the software ASIC estimator, a mixed ASIC simulation, and optional Yosys. Not a reproducible ASIC mapped-design result. |
| `clockInfo.txt` | Vivado-generated clock information with project context; not needed because clock period is present in constraints and reports. |
| `asic/README.md`, `asic/reports/asic_mathematical_derivation.md`, `asic/reports/asic_paper_comparison.md`, `asic_benchmark_summary.md` | ASIC methodology/metric documents; estimates are not supported by a reproducible mapped flow here. |
| `asic/reports/security_threat_analysis.md` | Draft threat analysis includes security claims beyond the included RTL evidence. |
| `asic/rtl/asic_coe_mem.v`, `asic/sdc/mlkem_ntt_fsm.sdc`, `asic/openlane/config.json` | Separate ASIC memory model, constraints, and OpenLane config; no full ASIC implementation flow is packaged. |
| `asic/scripts/run_asic_estimation.py`, `asic/scripts/synth_asic.tcl`, `asic/scripts/generate_asic_schematic.tcl`, `asic/scripts/generate_schematics.py`, `asic/scripts/test_schematic_help.tcl` | Assumed-value estimator and ASIC diagram/synthesis helpers; not used in the FPGA project. The estimator is not evidence of cell-mapped ASIC PPA. |
| `flex_ntt_k_extensions.pdf` | Project PDF; not included because its metadata/content could not be cleared for blind release. |
| `Flex_NTT_Master_Architecture_and_Security.pptx`, `Flex_NTT_Security_and_Attack_Analysis.pptx` | Presentation source material; excluded. Both have populated `lastModifiedBy` core metadata. |
| `make_presentation.py`, `make_master_presentation.py`, `make_comprehensive_presentation.py` | Scripts that generate the excluded decks; not required to reproduce the RTL or FPGA reports. |
| `asic/reports/flex_ntt_asic_top_schematic.{pdf,png,svg}`, `asic/reports/flex_ntt_rbu_datapath_schematic.{pdf,png,svg}` | Generated ASIC schematic diagrams; excluded with the unverified ASIC flow. |
| `Extended_Flex_NTT/Extended_Flex_NTT.xpr` and its `.runs`, `.sim`, `.cache`, `.hw`, `.ip_user_files` directories | Vivado-generated project, simulations, runs, caches, and hardware manager state; contain host/path metadata and generated products. |
| `Extended_Flex_NTT/Extended_Flex_NTT.runs/{synth_1,impl_1}/runme.{bat,sh}`, `ISEWrap.{sh,js}`, `mlkem_ntt_fsm.tcl`, plus `Extended_Flex_NTT.sim/.../compile.bat`, `elaborate.bat`, `simulate.bat` | Tool-generated launch scripts tied to local Vivado project/run paths. Report text from these runs is included separately after metadata scrubbing. |
| `Extended_Flex_NTT/Extended_Flex_NTT.sim/.../glbl.v`, `.wdb`, `.sdb`, `.exe`, `.vcd`, `.wdf`, `.pb`, `.dcp`, and `.bit` products | Vendor-generated simulation globals and binary/cache artifacts; not source needed for clean reproducibility. |
| Root `asic_sim.*`, `log_out.txt`, `ntf_fsm.*`, `rbu_tb.*`, simulator executables, `.vvp`, and `.vcd` products | Previous local simulation outputs; the fresh text logs/results in this artifact are used instead. The prior RBU result is preserved separately with provenance. |
## Excluded

| Excluded files / groups | Reason |
|---|---|
| `Extended_Flex_NTT/Extended_Flex_NTT.xpr`, `.runs`, `.sim`, `.cache`, `.hw`, `.ip_user_files`, and root `.Xil` | Generated Vivado project/cache data contains machine paths/user metadata; a clean portable flow is supplied instead |
| `vivado_output/*.bit`, DCP checkpoints, and non-text generated artifacts | Not needed to inspect/reproduce source; binary anonymity cannot be assured; no bitstream redistribution review |
| Root `.vvp`, simulator executables, `.out`, `.log`, `.vcd`, `.jou`, `.str` outputs | Generated local run products, not source; fresh result logs are generated by the script |
| `asic/rtl/asic_coe_mem.v` and ASIC scripts/reports/README | ASIC flow missing files listed by its README, including `asic_tf_mem.v`; synthesis Tcl paths are inconsistent; benchmark is based on assumed values rather than executed mapped synthesis |
| `asic/reports/security_threat_analysis.md` and related ASIC mathematical/benchmark analyses | Contains unsupported security/ASIC claims not substantiated by the included implementation/evidence |
| `flex_ntt_k_extensions.pdf`, `Flex_NTT_*Presentation*.pptx`, and presentation builder scripts | Not required for RTL reproduction; not included because full content and identifying metadata have not been cleared for double-blind release |
| Generated Vivado `glbl.v` | Tool-generated simulation global, supplied by Vivado when needed; not project-authored source |
| Original repository history (no `.git` copied) | Avoids author and machine identity leakage; no commit history is part of this source snapshot |

## Anonymous GitHub workflow findings

Official Anonymous GitHub pages were checked on 2026-11-16:

- The service creates a read-only anonymous mirror from a selected GitHub repository, pull request, or gist; GitHub sign-in is required and the GitHub App is described as read-only for selected repositories.
- Its FAQ says the service anonymizes owner/organization/repository names, paths, and textual file contents; custom redaction terms can be supplied. It provides a ZIP download of the anonymized repository.
- It does not anonymize binary files. Images and PDFs are served unchanged; files over 8 MB are unsupported. Text replacement can change code behavior.
- The FAQ does not explicitly say whether Git commit history is exposed or whether the source repository must be public. Therefore this package has no Git history and should be tested through the service before a reviewer link is used. The FAQ warns a mirror cannot fetch updates if its source repository becomes private or is deleted.
- Use a new, separate source repository containing only this reviewed snapshot. Do not connect the service to the original development repository. The anonymized mirror itself is intended for anonymous read-only reviewer access; the source repository remains subject to the service’s GitHub access and update requirements.

No source repository or mirror was created. This report stops before any external upload, as requested.

## Exact release-archive file list

The archive omits locally generated .vvp, .vcd, and compiler-log artifacts; those were created only while running tests and are not part of the release package.
- `.gitignore`
- `ARTIFACT_MANIFEST.md`
- `ARTIFACT_RELEASE_REPORT.md`
- `documentation/architecture.md`
- `documentation/paper-citation.md`
- `documentation/reproduction_guide.md`
- `documentation/security_scope.md`
- `documentation/verification.md`
- `fault_injection/source/host_security_validation.py`
- `fpga/constraints/constraints.xdc`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_bus_skew_routed.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_clock_utilization_routed.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_control_sets_placed.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_drc_opted.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_drc_routed.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_io_placed.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_methodology_drc_routed.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_power_routed.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_route_status.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_timing_summary_routed.rpt`
- `fpga/reports/project_runs/impl_1/mlkem_ntt_fsm_utilization_placed.rpt`
- `fpga/reports/project_runs/synth_1/mlkem_ntt_fsm_utilization_synth.rpt`
- `fpga/reports/vivado_output/drc.rpt`
- `fpga/reports/vivado_output/methodology.rpt`
- `fpga/reports/vivado_output/routed_drc.rpt`
- `fpga/reports/vivado_output/routed_methodology.rpt`
- `fpga/reports/vivado_output/routed_timing_summary.rpt`
- `fpga/reports/vivado_output/routed_utilization.rpt`
- `fpga/reports/vivado_output/synth_drc.rpt`
- `fpga/reports/vivado_output/synth_methodology.rpt`
- `fpga/reports/vivado_output/synth_timing_summary.rpt`
- `fpga/reports/vivado_output/timing_summary.rpt`
- `fpga/reports/vivado_output/utilization.rpt`
- `fpga/vivado_scripts/reproduce_fpga.tcl`
- `LICENSE_PENDING.md`
- `README.md`
- `results/host_security_validation.log`
- `results/prior_rbu_provenance.md`
- `results/prior_rbu_regression.log`
- `results/regression_summary.csv`
- `results/regression_summary.md`
- `results/resource_utilization.csv`
- `results/timing_summary.csv`
- `rtl/arithmetic/mlkem_modadd.v`
- `rtl/arithmetic/mlkem_modmult.v`
- `rtl/arithmetic/mlkem_modsub.v`
- `rtl/controller/mlkem_ntt_fsm.v`
- `rtl/memory/mlkem_coe_mem.v`
- `rtl/memory/mlkem_tf_mem_hexload.v`
- `rtl/memory/mlkem_tf_mem.v`
- `rtl/rbu/mlkem_rbu.v`
- `simulation/expected/mlkem_golden_model_dump.json`
- `simulation/expected/mlkem_intt_expected.hex`
- `simulation/expected/mlkem_ntt_expected.hex`
- `simulation/inputs/mlkem_gammas.hex`
- `simulation/inputs/mlkem_ntt_input.hex`
- `simulation/inputs/mlkem_zetas.hex`
- `simulation/logs/coe_memory.log`
- `simulation/logs/modadd.log`
- `simulation/logs/modmult.log`
- `simulation/logs/modsub.log`
- `simulation/logs/ntt_intt.log`
- `simulation/logs/rbu_modes_basemul.log`
- `simulation/logs/security_validation.log`
- `simulation/logs/tf_memory_hexload.log`
- `simulation/logs/tf_memory.log`
- `simulation/scripts/golden_model.py`
- `simulation/scripts/run_all.ps1`
- `testbench/arithmetic/mlkem_modadd_tb.v`
- `testbench/arithmetic/mlkem_modmult_tb.v`
- `testbench/arithmetic/mlkem_modsub_tb.v`
- `testbench/controller/mlkem_ntt_fsm_tb.v`
- `testbench/memory/mlkem_coe_mem_tb.v`
- `testbench/memory/mlkem_tf_mem_hexload_tb.v`
- `testbench/memory/mlkem_tf_mem_tb.v`
- `testbench/rbu/mlkem_rbu_tb.v`
- `testbench/security/tb_security_validation.v`


