# Artifact release report (pre-publication review)

**Status:** Local review package prepared. No repository was created or pushed; no files were sent to an external service. The anonymous URL is not generated.

## 1. Files selected for release

The package contains 17 authored Verilog files: 8 RTL files (controller, RBU, 3 arithmetic, 3 memory/ROM files) and 9 testbenches (arithmetic, memory, controller, security, and RBU/BASEMUL). It also contains five `.hex` vectors, the Python golden model and fault model, an executable Icarus runner, a cleaned Artix-7 XDC, a portable Vivado Tcl flow, 23 text Vivado reports, CSV summaries, verification logs, and documentation. The complete path-by-path list is in `ARTIFACT_MANIFEST.md`.

The multiplier testbench in the artifact snapshot is the only functionally modified testbench: its sample point now accounts for the registered two-stage multiplier latency. Design RTL is byte-identical to its source copy. Other testbench changes only update vector paths and configure the hex-loader testbench to use the packaged vectors.

## 2. Files excluded

- Vivado `.xpr`, `.runs`, `.sim`, `.cache`, `.hw`, `.ip_user_files`, `.Xil`, generated TCL, and local run scripts: contain machine-specific paths or user metadata; the package supplies a clean Tcl flow.
- Bitstream, DCP checkpoints, generated executables, VVP images, waveforms, and caches: generated binaries are unnecessary for reproducing source-level results and are not safe to anonymize by text redaction.
- ASIC scripts/reports and the ASIC coefficient-memory variant: the ASIC estimator uses assumed gate/node values rather than a demonstrated mapped flow; the ASIC README lists a memory file that is absent; no ASIC tool/library result was available to reproduce. These estimates are not presented as measurements.
- ASIC threat-analysis, mathematical derivation, comparison drafts, schematics, and related images/PDFs: they are outside the reproduced FPGA RTL flow and include claims/results not validated by the included implementation.
- `flex_ntt_k_extensions.pdf` and both presentation decks: not needed to reproduce the RTL; PPTX core metadata contains a `lastModifiedBy` field, and PDF metadata could not be inspected because `pdfinfo`/`pypdf` was unavailable. They remain excluded.
- Generated Vivado `glbl.v`: tool-provided simulation global, not project-authored source.
- Original Git history: the source folder had no `.git` directory; no Git history is present in this artifact.

The 23 included Vivado text reports retain AMD/Xilinx copyright headers. The reports' local hostname and absolute local directory strings were replaced; the copyright notices, dates, device, tool version, report state, and technical content were retained.

## 3. Tests executed and results

| Test | Result |
|---|---|
| Modular add | PASS — 11,082,241 cases |
| Modular subtract | PASS — 11,082,241 cases |
| Modular multiplier | PASS — 23,800 vector checks; artifact testbench waits for the two-stage pipeline |
| Coefficient memory | PASS — 256 locations and isolation checks |
| Twiddle ROM | PASS — 256 entries |
| Hex-loaded twiddle ROM | PASS — 256 entries |
| Security validation bench | PASS — all four bench audit gates; see caveats below |
| NTT and INTT controller | PASS — 256 forward and 256 inverse values matched expected vectors |
| RBU modes and BASEMUL | PASS — 13,440,425 checks, zero mismatches; includes exhaustive PWM pairs |
| Python golden model | PASS — NTT/INTT roundtrip, schoolbook polynomial product, and zeta assertions |
| Python fault model | EXECUTED — 10,000 software-model trials; 9,742 detections (97.42%); twiddle-fault category 87.10% |
| Vivado implementation | NOT RUN — Vivado was not installed in the available command environment |

Icarus Verilog reported version 12.0 development build `s20150603-1539-g2693dd32b`. For each bench it wrote a `.vvp` image and then returned Windows access-violation code `-1073741819`. Each generated image was run; `vvp` exited successfully and produced the pass marker shown in the regression CSV/logs. The runner records compiler warnings separately from run results. A stable Icarus build should be used to obtain clean compile exit statuses independently.

The Python fault script is a mathematical software model. It is not RTL fault injection or a physical experiment. It also prints fixed latency labels; these are not measured cycles. The security bench's 3B product-register flip is directly injected into RTL; 3C only flips a testbench-local value and evaluates a helper function; 3D is a nominal GS invariant check. The bench instantiates the RBU alone and does not test the controller's memory-write suppression. The controller gates each write after checking the RBU result, but the two writes are serialized, not an atomic two-word memory transaction. These results do not establish full DFA resistance, power/EM resistance, or physical fault coverage.

Saved FPGA evidence is mixed across dates. October 2 reports WNS `-2.801 ns`, TNS `-31.215 ns`, 12 failing endpoints. October 23 reports routed WNS `1.629 ns`, TNS `0 ns`, and zero failing endpoints at 50 MHz. October 23 routed utilization is 644 LUTs, 281 registers, 0.5 BRAM tile, and 2 DSPs. The separate report-date rows are retained in `results/*.csv`.

## 4. Missing dependencies and release concerns

- No license was found in the project source. `LICENSE_PENDING.md` intentionally contains no guessed license. Public redistribution needs a chosen license and confirmation from the authors/institution.
- No evidence of third-party RTL IP was found in the selected source set. AMD/Xilinx report copyright notices are retained; the original binary reports/project data are not included.
- Vivado is required for a fresh FPGA implementation and is not installed in this environment. The archived Vivado reports are not a fresh run.
- The XDC contains fixed package-pin assignments and timing assumptions. Verify these against the actual board before relying on the flow.
- The source tree has no standalone BASEMUL test file; BASEMUL is covered by the RBU testbench.
- No LaTeX paper source was found in the supplied project directory, so no manuscript or abstract was modified.

## 5. Anonymity audit

- The included RTL, testbench, Tcl, XDC, Python, Markdown, and report text was checked for the known user name, institutional terms, email-like strings, host name, and local absolute paths. No such matches remain in the curated source/docs/report text.
- Four named Vivado waiver records were removed from the copied XDC. The original XDC remains untouched.
- Generated project metadata and original Vivado/ASIC logs were excluded; only sanitized Vivado report snapshots and fresh RTL test logs are included. Test logs produced by the runner are rewritten to replace the local artifact-root path.
- The source directory had no Git history. No GitHub username, original repository URL, credential file, PDF, presentation, or binary bitstream is included.
- PPTX documents were excluded; inspection found a populated `lastModifiedBy` core property. PDF metadata could not be inspected locally, so the PDF was excluded.

This is a best-effort text/source audit, not proof that an anonymous reviewer cannot infer the work from the research topic, cited technical content, filenames, or external search.

## 6. Proposed anonymous repository workflow

Official Anonymous GitHub pages were checked on 2026-11-16. The service describes a read-only mirror created after GitHub sign-in and access to selected repositories. Its FAQ describes text/path/owner redaction, anonymized ZIP downloads, and binary files being served unchanged. It also states that the mirror cannot fetch updates if its source repo is made private or deleted. The FAQ does not explicitly settle whether the source repo must be public or whether commit metadata/history is exposed.

After explicit approval and license/release clearance:

1. Create a separate GitHub repository containing only this cleaned snapshot. Do not use the original development repository or its history.
2. Confirm the source-repository visibility required by Anonymous GitHub before authorizing it. If a public intermediate repo is required, it would itself be visible at a GitHub URL; do not proceed unless that visibility is approved for double-blind review.
3. Authorize read-only access to only the new artifact repository, configure author/institution/email redaction terms, and generate the mirror.
4. Review the mirror and downloaded anonymized ZIP in a signed-out/incognito browser. Check all RTL, scripts, source/report metadata, and file links. Choose removal at expiry rather than redirecting reviewers to an identifiable source repo.
5. Only after verification, insert the real anonymous URL into the citation and manuscript. Do not change the abstract.

Official references: [Anonymous GitHub](https://anonymous.4open.science/) and [its FAQ](https://anonymous.4open.science/faq).

## 7. Repository URL

**Not generated.** No external repository was created and no source was uploaded.

## 8. Exact paper text prepared

Introduction ending:

```latex
The RTL implementation, verification testbenches, and
evaluation scripts are made available through an
anonymized repository to facilitate independent
assessment and reproducibility~\cite{flexntt_artifact}.
```

Conclusion ending:

```latex
The accompanying artifact repository provides the
design and verification materials for independent
evaluation and further research on Flex-NTT-Ext~\cite{flexntt_artifact}.
```

BibTeX (URL remains a placeholder until the mirror exists):

```bibtex
@misc{flexntt_artifact,
  title        = {{Flex-NTT-Ext: Design and Verification Artifacts}},
  howpublished = {Anonymous online repository},
  url          = {ANONYMOUS_REPOSITORY_URL},
  note         = {Accessed: November 2026}
}
```

## Approval gate

The release package is ready for review, not for upload. Public release requires your explicit approval after reviewing this report and manifest, plus author/institution release clearance and a license choice. No public-release action has been taken.


