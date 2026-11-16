param([switch]$SkipLongRbu)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$build = Join-Path $root 'simulation\logs\build'
$logs = Join-Path $root 'simulation\logs'
New-Item -ItemType Directory -Force -Path $build,$logs | Out-Null
$rtl = Join-Path $root 'rtl'
$tb = Join-Path $root 'testbench'
$cases = @(
  @{Name='modadd'; Top='mlkem_modadd_tb'; Files=@("$rtl\arithmetic\mlkem_modadd.v","$tb\arithmetic\mlkem_modadd_tb.v")},
  @{Name='modsub'; Top='mlkem_modsub_tb'; Files=@("$rtl\arithmetic\mlkem_modsub.v","$tb\arithmetic\mlkem_modsub_tb.v")},
  @{Name='modmult'; Top='mlkem_modmult_tb'; Files=@("$rtl\arithmetic\mlkem_modmult.v","$tb\arithmetic\mlkem_modmult_tb.v")},
  @{Name='coe_memory'; Top='mlkem_coe_mem_tb'; Files=@("$rtl\memory\mlkem_coe_mem.v","$tb\memory\mlkem_coe_mem_tb.v")},
  @{Name='tf_memory'; Top='mlkem_tf_mem_tb'; Files=@("$rtl\memory\mlkem_tf_mem.v","$tb\memory\mlkem_tf_mem_tb.v")},
  @{Name='tf_memory_hexload'; Top='mlkem_tf_mem_hexload_tb'; Files=@("$rtl\memory\mlkem_tf_mem.v","$rtl\memory\mlkem_tf_mem_hexload.v","$tb\memory\mlkem_tf_mem_hexload_tb.v")},
  @{Name='security_validation'; Top='tb_security_validation'; Files=@("$rtl\arithmetic\mlkem_modadd.v","$rtl\arithmetic\mlkem_modsub.v","$rtl\arithmetic\mlkem_modmult.v","$rtl\rbu\mlkem_rbu.v","$tb\security\tb_security_validation.v")},
  @{Name='ntt_intt'; Top='mlkem_ntt_fsm_tb'; Files=@("$rtl\arithmetic\mlkem_modadd.v","$rtl\arithmetic\mlkem_modsub.v","$rtl\arithmetic\mlkem_modmult.v","$rtl\memory\mlkem_coe_mem.v","$rtl\memory\mlkem_tf_mem.v","$rtl\rbu\mlkem_rbu.v","$rtl\controller\mlkem_ntt_fsm.v","$tb\controller\mlkem_ntt_fsm_tb.v")}
)
if (-not $SkipLongRbu) { $cases += @{Name='rbu_modes_basemul'; Top='mlkem_rbu_tb'; Files=@("$rtl\arithmetic\mlkem_modadd.v","$rtl\arithmetic\mlkem_modsub.v","$rtl\arithmetic\mlkem_modmult.v","$rtl\rbu\mlkem_rbu.v","$tb\rbu\mlkem_rbu_tb.v")} }
$passPatterns = @{
  modadd='PASS all 11082241 cases correct'
  modsub='PASS all 11082241 cases correct'
  modmult='PASS modmult tests correct'
  coe_memory='FULL MEMORY SWEEP PASS.*ISOLATION PASS'
  tf_memory='FULL ROM SWEEP PASS all 256 entries correct'
  tf_memory_hexload='FULL ROM SWEEP PASS all 256 entries correct'
  security_validation='SECURITY VALIDATION SUITE: ALL AUDIT GATES .* PASS'
  ntt_intt='NTT PASS all 256 values match golden model.*INTT PASS all 256 values match golden model'
  rbu_modes_basemul='PASS\s+\d+ checks, 0 mismatches'
}
$rows = [System.Collections.Generic.List[object]]::new()
foreach ($case in $cases) {
  $exe = Join-Path $build ($case.Name + '.vvp')
  $log = Join-Path $logs ($case.Name + '.log')
  if (Test-Path -LiteralPath $exe) { Remove-Item -LiteralPath $exe }
  & iverilog -g2012 -s $case.Top -o $exe @($case.Files) 2>&1 | Out-File -LiteralPath (Join-Path $logs ($case.Name + '.compile.log')) -Encoding utf8
  $compileExit = $LASTEXITCODE
  if ($compileExit -ne 0 -and -not (Test-Path -LiteralPath $exe)) { $rows.Add([pscustomobject]@{Test=$case.Name;Compile='FAIL';Run='NOT RUN';Notes="Icarus exit $compileExit; no simulation image"}); continue }
  $compileStatus = if ($compileExit -eq 0) {'PASS'} else {"WARN: image written; Icarus exit $compileExit"}
  Push-Location $logs
  try { & vvp $exe *> $log; $runExit = $LASTEXITCODE } finally { Pop-Location }
  $body = Get-Content -LiteralPath $log -Raw
$body = $body.Replace($root, '[ARTIFACT_ROOT]')
Set-Content -LiteralPath $log -Value $body -Encoding utf8
  $bad = $body -match '(?im)\bFAIL\b|\bMISMATCH\b|WATCHDOG TIMEOUT|\bERROR\b'
  $good = $body -match ('(?s)' + $passPatterns[$case.Name])
  $runStatus = if ($runExit -eq 0 -and -not $bad -and $good) {'PASS'} else {'FAIL'}
  $notes = if ($runExit -ne 0) {"vvp exit $runExit"} elseif ($bad) {'failure marker found in simulator log'} elseif (-not $good) {'expected pass marker missing'} else {'see individual simulator log'}
  $rows.Add([pscustomobject]@{Test=$case.Name;Compile=$compileStatus;Run=$runStatus;Notes=$notes})
}
$rows | Export-Csv -NoTypeInformation -Encoding utf8 -LiteralPath (Join-Path $root 'results\regression_summary.csv')
$rows | Format-Table -AutoSize
if ($rows.Where({$_.Run -ne 'PASS'}).Count) { exit 1 }



