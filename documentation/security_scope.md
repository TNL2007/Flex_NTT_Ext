# Security and release notes

The RTL includes a modulo-7 product residue check and CT/GS arithmetic invariants. The controller checks the RBU fault output before writing the result pair. The supplied testbench demonstrates one injected product-register upset in RTL simulation. It does not physically inject faults or measure silicon/FPGA behavior.

The Python host campaign is a software-level model with a fixed seed. Its result must be reported as a result of that model only. It is not evidence for complete detection coverage of the RTL or physical device. The code contains hard-coded latency labels and a constant-time profile helper; neither is a measured latency study.

No physical fault injection, power/EM side-channel measurement, or ASIC implementation flow is included in this artifact. ASIC estimates and security threat-analysis drafts found in the source tree are excluded because the ASIC dependency set is incomplete and the analysis makes claims that are not established by the provided RTL/simulation evidence.
