# Synthesis plus place and route for the checked-in Artix-7 target. Run from
# Vivado batch mode with this script path; output reports go to fpga/reports/run.
set here [file normalize [file dirname [info script]]]
set root [file normalize [file join $here .. ..]]
set out [file join $root fpga reports run]
file mkdir $out
set part xc7a35tcsg324-1
read_verilog [list \
  [file join $root rtl arithmetic mlkem_modadd.v] \
  [file join $root rtl arithmetic mlkem_modsub.v] \
  [file join $root rtl arithmetic mlkem_modmult.v] \
  [file join $root rtl memory mlkem_coe_mem.v] \
  [file join $root rtl memory mlkem_tf_mem.v] \
  [file join $root rtl rbu mlkem_rbu.v] \
  [file join $root rtl controller mlkem_ntt_fsm.v]]
read_xdc [file join $root fpga constraints constraints.xdc]
synth_design -top mlkem_ntt_fsm -part $part -flatten_hierarchy rebuilt
report_utilization -file [file join $out synth_utilization.rpt]
report_timing_summary -file [file join $out synth_timing_summary.rpt]
opt_design
place_design
phys_opt_design
route_design
report_utilization -file [file join $out routed_utilization.rpt]
report_timing_summary -file [file join $out routed_timing_summary.rpt] -max_paths 20 -report_unconstrained -warn_on_violation
report_drc -file [file join $out routed_drc.rpt]
report_methodology -file [file join $out routed_methodology.rpt]
write_checkpoint -force [file join $out post_route.dcp]
close_design
exit
