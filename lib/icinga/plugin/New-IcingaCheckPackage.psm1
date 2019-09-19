Import-IcingaLib icinga\enums;
Import-IcingaLib core\tools;

function New-IcingaCheckPackage()
{
    param(
        [string]$Name,
        [switch]$OperatorAnd,
        [switch]$OperatorOr,
        [switch]$OperatorNone,
        [int]$OperatorMin      = -1,
        [int]$OperatorMax      = -1,
        [array]$Checks         = @(),
        [int]$Verbose          = 0,
        [switch]$Hidden        = $FALSE
    );

    $Check = New-Object -TypeName PSObject;
    $Check | Add-Member -membertype NoteProperty -name 'name'      -value $Name;
    $Check | Add-Member -membertype NoteProperty -name 'exitcode'  -value -1;
    $Check | Add-Member -membertype NoteProperty -name 'verbose'   -value $Verbose;
    $Check | Add-Member -membertype NoteProperty -name 'hidden'    -value $Hidden;
    $Check | Add-Member -membertype NoteProperty -name 'checks'    -value $Checks;
    $Check | Add-Member -membertype NoteProperty -name 'opand'     -value $OperatorAnd;
    $Check | Add-Member -membertype NoteProperty -name 'opor'      -value $OperatorOr;
    $Check | Add-Member -membertype NoteProperty -name 'opnone'    -value $OperatorNone;
    $Check | Add-Member -membertype NoteProperty -name 'opmin'     -value $OperatorMin;
    $Check | Add-Member -membertype NoteProperty -name 'opmax'     -value $OperatorMax;
    $Check | Add-Member -membertype NoteProperty -name 'spacing'   -value 0;
    $Check | Add-Member -membertype NoteProperty -name 'compiled'  -value $FALSE;
    $Check | Add-Member -membertype NoteProperty -name 'perfdata'  -value $FALSE;

    $Check | Add-Member -membertype ScriptMethod -name 'Initialise' -value {
        foreach ($check in $this.checks) {
            $this.InitCheck($check);
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'InitCheck' -value {
        param($check);

        if ($null -eq $check) {
            return;
        }

        $check.verbose = $this.verbose;
        $check.AddSpacing();
        $check.SilentCompile();
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AddSpacing' -value {
        $this.spacing += 1;
        foreach ($check in $this.checks) {
            $check.spacing = $this.spacing;
            $check.AddSpacing();
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AddCheck' -value {
        param($check);

        if ($null -eq $check) {
            return;
        }

        $this.InitCheck($check);
        $this.checks += $check;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'Compile' -value {
        param([bool]$Verbose);

        if ($this.compiled) {
            return;
        }

        $this.compiled = $TRUE;

        if ($this.checks.Count -ne 0) {
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
                    $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
                }
            } elseif([int]$this.opmin -ne -1) {
                if ($this.CheckMinimumOk() -eq $FALSE) {
                    $this.GetWorstExitCode();
                } else {
                    $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
                }
            } elseif([int]$this.opmax -ne -1) {
                if ($this.CheckMaximumOk() -eq $FALSE) {
                    $this.GetWorstExitCode();
                } else {
                    $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
                }
            }
        } else {
            $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
        }

        if ([int]$this.exitcode -eq -1) {
            $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
        }

        if ($Verbose -eq $TRUE) {
            $this.PrintOutputMessages();
        }

        return $this.exitcode;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'SilentCompile' -value {
        $this.Compile($FALSE) | Out-Null;
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
        if ($this.opmin -gt $this.checks.Count) {
            Write-Host ([string]::Format(
                'Unknown: The minimum argument ({0}) is exceeding the amount of assigned checks ({1}) to this package "{2}"',
                $this.opmin, $this.checks.Count, $this.name
            ));
            $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
            return $FALSE;
        }

        [int]$okCount = $this.GetOkCount();

        if ($this.opmin -le $okCount) {
            return $TRUE;
        }

        return $FALSE;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CheckMaximumOk' -value {
        if ($this.opmax -gt $this.checks.Count) {
            Write-Host ([string]::Format(
                'Unknown: The maximum argument ({0}) is exceeding the amount of assigned checks ({1}) to this package "{2}"',
                $this.opmax, $this.checks.Count, $this.name
            ));
            $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
            return $FALSE;
        }

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
        if ($this.hidden) {
            return;
        }

        [hashtable]$MessageOrdering = @{};
        foreach ($check in $this.checks) {
            $MessageOrdering.Add($check.name, $check);
        }

        $SortedArray = $MessageOrdering.GetEnumerator() | Sort-Object name;

        foreach ($entry in $SortedArray) {
            $entry.Value.PrintAllMessages();
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintAllMessages' -value {
        $this.WritePackageOutputStatus();
        $this.WriteAllOutput();
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WriteCheckErrors' -value {
        [hashtable]$MessageOrdering = @{};
        foreach ($check in $this.checks) {
            if ([int]$check.exitcode -ne $IcingaEnums.IcingaExitCode.Ok) {
                $MessageOrdering.Add($check.name, $check);
            }
        }

        $SortedArray = $MessageOrdering.GetEnumerator() | Sort-Object name;

        foreach ($entry in $SortedArray) {
            $entry.Value.PrintAllMessages();
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintNoChecksConfigured' -value {
        if ($this.checks.Count -eq 0) {
            Write-Host (
                [string]::Format(
                    '{0}{1}: No checks configured for package "{2}"',
                    (New-StringTree ($this.spacing + 1)),
                    $IcingaEnums.IcingaExitCodeText.($this.exitcode),
                    $this.name
                )
            )
            return;
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WritePackageOutputStatus' -value {
        if ($this.hidden) {
            return;
        }

        [string]$outputMessage = '{0}{1}: Check package "{2}" is {1}';
        if ($this.verbose -ne 0) {
            $outputMessage += ' ({3})';
        }

        Write-Host (
            [string]::Format(
                $outputMessage,
                (New-StringTree $this.spacing),
                $IcingaEnums.IcingaExitCodeText.($this.exitcode),
                $this.name,
                $this.GetPackageConfigMessage()
            )
        );
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintOutputMessages' -value {
        [bool]$printDetails = $FALSE;
        [bool]$printAll = $FALSE;

        switch ($this.verbose) {
            0 { break; };
            1 { break; };
            2 {
                $printDetails = $TRUE;
                break;
            };
            Default {
                $printAll = $TRUE;
                break;
            }
        }

        $this.WritePackageOutputStatus();

        if ($printAll) {
            $this.WriteAllOutput();
            $this.PrintNoChecksConfigured();
        } elseif ($printDetails) {
            # Now print Non-Ok Check outputs in case our package is not Ok
            if ([int]$this.exitcode -ne $IcingaEnums.IcingaExitCode.Ok) {
                $this.WriteCheckErrors();
                $this.PrintNoChecksConfigured();
            }
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'GetWorstExitCode' -value {
        if ([int]$this.exitcode -eq [int]$IcingaEnums.IcingaExitCode.Unknown) {
            return;
        }
        foreach ($check in $this.checks) {
            if ([int]$this.exitcode -lt $check.exitcode) {
                $this.exitcode = $check.exitcode;
            }
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'GetPerfData' -value {
        [string]$perfData             = '';
        [hashtable]$CollectedPerfData = @{};

        # At first lets collect all perf data, but ensure we only add possible label duplication only once
        foreach ($check in $this.checks) {
            $data = $check.GetPerfData();

            if ($null -eq $data -Or $null -eq $data.label) {
                continue;
            }

            if ($CollectedPerfData.ContainsKey($data.label)) {
                continue;
            }

            $CollectedPerfData.Add($data.label, $data.perfdata);
        }

        # Now sort the label output by name
        $SortedArray = $CollectedPerfData.GetEnumerator() | Sort-Object name;

        # Buold the performance data output based on the sorted result
        foreach ($entry in $SortedArray) {
            $perfData += $entry.Value;
        }

        return @{
            'label'    = $this.name;
            'perfdata' = $perfData;
        }
    }

    $Check.Initialise();

    return $Check;
}
