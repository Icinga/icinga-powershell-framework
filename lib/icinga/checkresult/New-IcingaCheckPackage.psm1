Import-IcingaLib icinga\enums;

function New-IcingaCheckPackage()
{
    param(
        [string]$Name,
        [switch]$OperatorAnd,
        [switch]$OperatorOr,
        [switch]$OperatorNone,
        [int]$OperatorMin = -1,
        [int]$OperatorMax = -1,
        [array]$Checks    = @()
    );

    $Check = New-Object -TypeName PSObject;
    $Check | Add-Member -membertype NoteProperty -name 'name'      -value $Name;
    $Check | Add-Member -membertype NoteProperty -name 'exitcode'  -value -1;
    $Check | Add-Member -membertype NoteProperty -name 'checks'    -value $Checks;
    $Check | Add-Member -membertype NoteProperty -name 'opand'     -value $OperatorAnd;
    $Check | Add-Member -membertype NoteProperty -name 'opor'      -value $OperatorOr;
    $Check | Add-Member -membertype NoteProperty -name 'opnone'    -value $OperatorNone;
    $Check | Add-Member -membertype NoteProperty -name 'opmin'     -value $OperatorMin;
    $Check | Add-Member -membertype NoteProperty -name 'opmax'     -value $OperatorMax;
    $Check | Add-Member -membertype NoteProperty -name 'hasoutput' -value $TRUE;

    $Check | Add-Member -membertype ScriptMethod -name 'Compile' -value {

        Write-Host ([string]::Format('Check result for package {0} ({1}):{2}', $this.name, $this.GetPackageConfigMessage(), "`r`n"));

        if ($this.opand) {
            if ($this.CheckAllOk() -eq $FALSE) {
                $this.GetWorstExitCode();
            }
        } elseif($this.opor) {
            if ($this.CheckOneOk() -eq $FALSE) {
                $this.GetWorstExitCode();
            }
        } elseif($this.opnone) {
            if ($this.CheckOneOk() -eq $TRUE) {
                $this.GetWorstExitCode();
                $this.exitcode = $IcingaEnums.IcingaExitCode.Critical;
            } else {
                $this.WriteAllOutput();
                $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
            }
        } elseif([int]$this.opmin -ne -1) {
            if ($this.CheckMinimumOk() -eq $FALSE) {
                $this.GetWorstExitCode();
            } else {
                $this.WriteAllOutput();
                $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
            }
        } elseif([int]$this.opmax -ne -1) {
            if ($this.CheckMaximumOk() -eq $FALSE) {
                $this.GetWorstExitCode();
            } else {
                $this.WriteAllOutput();
                $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
            }
        }

        if ($this.hasoutput -eq $FALSE) {
            Write-Host $IcingaEnums.IcingaExitCodeText.($this.exitcode);
        }

        return $this.exitcode;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'SilentCompile' -value {
        $this.Compile() | Out-Null;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'GetOkCount' -value {
        [int]$okCount = 0;
        foreach ($check in $this.checks) {
            if ([int]$check.exitcode -eq [int]$IcingaEnums.IcingaExitCode.Ok) {
                $okCount += 1;
            }
        }

        return $okCount;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CheckMinimumOk' -value {
        [int]$okCount = $this.GetOkCount();

        if ($this.opmin -le $okCount) {
            return $TRUE;
        }

        return $FALSE;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CheckMaximumOk' -value {
        [int]$okCount = $this.GetOkCount();

        if ($this.opmax -ge $okCount) {
            return $TRUE;
        }

        return $FALSE;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CheckAllOk' -value {
        foreach ($check in $this.checks) {
            if ([int]$check.exitcode -ne [int]$IcingaEnums.IcingaExitCode.Ok) {
                return $FALSE;
            }
        }

        return $TRUE;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CheckOneOk' -value {
        foreach ($check in $this.checks) {
            if ([int]$check.exitcode -eq [int]$IcingaEnums.IcingaExitCode.Ok) {
                if ($check.messages.Count -ne 0) {
                    Write-Host ($check.messages | Out-String);
                } else {
                    $this.hasoutput = $FALSE;
                }
                $this.exitcode = $check.exitcode;
                return $TRUE;
            }
        }

        return $FALSE;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'GetPackageConfigMessage' -value {
        if ($this.opand) {
            return 'Match All';
        } elseif ($this.opor) {
            return 'Match Any';
        } elseif ($this.opnone) {
            return 'Match None';
        } elseif ([int]$this.opmin -ne -1) {
            return [string]::Format('Minimum {0}', $this.opmin)
        } elseif ([int]$this.opmax -ne -1) {
            return [string]::Format('Maximum {0}', $this.opmax)
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WriteAllOutput' -value {
        $printedOutput = $FALSE;
        foreach ($check in $this.checks) {
            if ($check.messages.Count -ne 0) {
                Write-Host ($check.messages | Out-String);
                $printedOutput = $TRUE;
            }
        }
        if ($printedOutput -eq $FALSE) {
            $this.hasoutput = $FALSE;
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'GetWorstExitCode' -value {
        $worstCheck = $null;
        foreach ($check in $this.checks) {
            if ([int]$this.exitcode -lt $check.exitcode) {
                $this.exitcode = $check.exitcode;
                $worstCheck = $check;
            }
        }

        if ($null -ne $worstCheck) {
            if ($worstCheck.messages.Count -ne 0) {
                Write-Host ($worstCheck.messages | Out-String);
            } else {
                $this.hasoutput = $FALSE;
            }
        }
    }

    return $Check;
}
