Import-IcingaLib icinga\enums;
Import-IcingaLib core\tools;

function New-IcingaCheckPackage()
{
    param(
        [string]$Name,
        [switch]$OperatorAnd,
        [switch]$OperatorOr,
        [switch]$OperatorNone,
        [int]$OperatorMin           = -1,
        [int]$OperatorMax           = -1,
        [array]$Checks              = @(),
        [int]$Verbose               = 0,
        [switch]$IgnoreEmptyPackage = $FALSE,
        [switch]$Hidden             = $FALSE
    );

    $Check = New-Object -TypeName PSObject;
    $Check | Add-Member -MemberType NoteProperty -Name 'name'               -Value $Name;
    $Check | Add-Member -MemberType NoteProperty -Name 'exitcode'           -Value -1;
    $Check | Add-Member -MemberType NoteProperty -Name 'verbose'            -Value $Verbose;
    $Check | Add-Member -MemberType NoteProperty -Name 'hidden'             -Value $Hidden;
    $Check | Add-Member -MemberType NoteProperty -Name 'ignoreemptypackage' -Value $IgnoreEmptyPackage;
    $Check | Add-Member -MemberType NoteProperty -Name 'checks'             -Value $Checks;
    $Check | Add-Member -MemberType NoteProperty -Name 'opand'              -Value $OperatorAnd;
    $Check | Add-Member -MemberType NoteProperty -Name 'opor'               -Value $OperatorOr;
    $Check | Add-Member -MemberType NoteProperty -Name 'opnone'             -Value $OperatorNone;
    $Check | Add-Member -MemberType NoteProperty -Name 'opmin'              -Value $OperatorMin;
    $Check | Add-Member -MemberType NoteProperty -Name 'opmax'              -Value $OperatorMax;
    $Check | Add-Member -MemberType NoteProperty -Name 'spacing'            -Value 0;
    $Check | Add-Member -MemberType NoteProperty -Name 'compiled'           -Value $FALSE;
    $Check | Add-Member -MemberType NoteProperty -Name 'perfdata'           -Value $FALSE;
    $Check | Add-Member -MemberType NoteProperty -Name 'checkcommand'       -Value '';
    $Check | Add-Member -MemberType NoteProperty -Name 'headermsg'          -Value '';
    $Check | Add-Member -MemberType NoteProperty -Name 'checkpackage'       -Value $TRUE;
    $Check | Add-Member -MemberType NoteProperty -Name 'warningchecks'      -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'criticalchecks'     -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'unknownchecks'      -Value @();

    $Check | Add-Member -MemberType ScriptMethod -Name 'HasChecks' -Value {
        if ($this.checks -ne 0) {
            return $TRUE
        }

        return $FALSE;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'Initialise' -Value {
        foreach ($check in $this.checks) {
            $this.InitCheck($check);
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'InitCheck' -Value {
        param($check);

        if ($null -eq $check) {
            return;
        }

        $check.verbose = $this.verbose;
        $check.AddSpacing();
        $check.SilentCompile();
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'AddSpacing' -Value {
        $this.spacing += 1;
        foreach ($check in $this.checks) {
            $check.spacing = $this.spacing;
            $check.AddSpacing();
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'AddCheck' -Value {
        param($check);

        if ($null -eq $check) {
            return;
        }

        $this.InitCheck($check);
        $this.checks += $check;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetWarnings' -Value {
        foreach ($check in $this.checks) {
            $this.warningchecks += $check.GetWarnings();
        }

        return $this.warningchecks;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetCriticals' -Value {
        foreach ($check in $this.checks) {
            $this.criticalchecks += $check.GetCriticals();
        }

        return $this.criticalchecks;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetUnknowns' -Value {
        foreach ($check in $this.checks) {
            $this.unknownchecks += $check.GetUnknowns();
        }

        return $this.unknownchecks;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'AssignCheckCommand' -Value {
        param($CheckCommand);

        $this.checkcommand = $CheckCommand;

        foreach ($check in $this.checks) {
            $check.AssignCheckCommand($CheckCommand);
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'Compile' -Value {
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
            } elseif ($this.opor) {
                if ($this.CheckOneOk() -eq $FALSE) {
                    $this.GetWorstExitCode();
                }
            } elseif ($this.opnone) {
                if ($this.CheckOneOk() -eq $TRUE) {
                    $this.GetWorstExitCode();
                    $this.exitcode = $IcingaEnums.IcingaExitCode.Critical;
                } else {
                    $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
                }
            } elseif ([int]$this.opmin -ne -1) {
                if ($this.CheckMinimumOk() -eq $FALSE) {
                    $this.GetWorstExitCode();
                } else {
                    $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
                }
            } elseif ([int]$this.opmax -ne -1) {
                if ($this.CheckMaximumOk() -eq $FALSE) {
                    $this.GetWorstExitCode();
                } else {
                    $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
                }
            }
        } else {
            if ($this.ignoreemptypackage) {
                $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
            } else {
                $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
            }
        }

        if ([int]$this.exitcode -eq -1) {
            $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
        }

        if ($Verbose -eq $TRUE) {
            $this.PrintOutputMessages();
        }

        return $this.exitcode;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'SilentCompile' -Value {
        $this.Compile($FALSE) | Out-Null;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetOkCount' -Value {
        [int]$okCount = 0;
        foreach ($check in $this.checks) {
            if ([int]$check.exitcode -eq [int]$IcingaEnums.IcingaExitCode.Ok) {
                $okCount += 1;
            }
        }

        return $okCount;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CheckMinimumOk' -Value {
        if ($this.opmin -gt $this.checks.Count) {
            Write-IcingaPluginOutput (
                [string]::Format(
                    'Unknown: The minimum argument ({0}) is exceeding the amount of assigned checks ({1}) to this package "{2}"',
                    $this.opmin, $this.checks.Count, $this.name
                )
            );
            $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
            return $FALSE;
        }

        [int]$okCount = $this.GetOkCount();

        if ($this.opmin -le $okCount) {
            return $TRUE;
        }

        return $FALSE;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CheckMaximumOk' -Value {
        if ($this.opmax -gt $this.checks.Count) {
            Write-IcingaPluginOutput (
                [string]::Format(
                    'Unknown: The maximum argument ({0}) is exceeding the amount of assigned checks ({1}) to this package "{2}"',
                    $this.opmax, $this.checks.Count, $this.name
                )
            );
            $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
            return $FALSE;
        }

        [int]$okCount = $this.GetOkCount();

        if ($this.opmax -ge $okCount) {
            return $TRUE;
        }

        return $FALSE;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CheckAllOk' -Value {
        foreach ($check in $this.checks) {
            if ([int]$check.exitcode -ne [int]$IcingaEnums.IcingaExitCode.Ok) {
                return $FALSE;
            }
        }

        return $TRUE;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CheckOneOk' -Value {
        foreach ($check in $this.checks) {
            if ([int]$check.exitcode -eq [int]$IcingaEnums.IcingaExitCode.Ok) {
                $this.exitcode = $check.exitcode;
                return $TRUE;
            }
        }

        return $FALSE;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetPackageConfigMessage' -Value {
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

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintOutputMessageSorted' -Value {
        param($skipHidden, $skipExitCode);

        if ($this.hidden -And $skipHidden) {
            return;
        }

        [hashtable]$MessageOrdering = @{};
        foreach ($check in $this.checks) {
            if ($this.verbose -eq 0) {
                if ([int]$check.exitcode -eq $skipExitCode) {
                    continue;
                }
            } elseif ($this.verbose -eq 1) {
                if ([int]$check.exitcode -eq $skipExitCode -And $check.checkpackage) {
                    continue;
                }
            }

            if ($MessageOrdering.ContainsKey($check.Name) -eq $FALSE) {
                $MessageOrdering.Add($check.name, $check);
            } else {
                [int]$DuplicateKeyIndex = 1;
                while ($TRUE) {
                    $newCheckName = [string]::Format('{0}[{1}]', $check.Name, $DuplicateKeyIndex);
                    if ($MessageOrdering.ContainsKey($newCheckName) -eq $FALSE) {
                        $MessageOrdering.Add($newCheckName, $check);
                        break;
                    }
                    $DuplicateKeyIndex += 1;
                }
            }
        }

        $SortedArray = $MessageOrdering.GetEnumerator() | Sort-Object name;

        foreach ($entry in $SortedArray) {
            $entry.Value.PrintAllMessages();
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WriteAllOutput' -Value {
        $this.PrintOutputMessageSorted($TRUE, $IcingaEnums.IcingaExitCode.Ok);
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintAllMessages' -Value {
        $this.WritePackageOutputStatus();
        $this.WriteAllOutput();
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WriteCheckErrors' -Value {
        $this.PrintOutputMessageSorted($FALSE, $IcingaEnums.IcingaExitCode.Ok);
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintNoChecksConfigured' -Value {
        if ($this.checks.Count -eq 0) {
            Write-IcingaPluginOutput (
                [string]::Format(
                    '{0}{1} No checks configured for package "{2}"',
                    (New-StringTree ($this.spacing + 1)),
                    $IcingaEnums.IcingaExitCodeText.($this.exitcode),
                    $this.name
                )
            )
            return;
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WritePackageOutputStatus' -Value {
        if ($this.hidden) {
            return;
        }

        [string]$outputMessage = '{0}{1} Check package "{2}"';
        if ($this.verbose -ne 0) {
            $outputMessage += ' ({3})';
        }

        if ($this.exitcode -ne 0 -And $this.spacing -eq 0) {
            $outputMessage += ' - {4}';
        }

        Write-IcingaPluginOutput (
            [string]::Format(
                $outputMessage,
                (New-StringTree $this.spacing),
                $IcingaEnums.IcingaExitCodeText.($this.exitcode),
                $this.name,
                $this.GetPackageConfigMessage(),
                $this.headermsg
            )
        );
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintOutputMessages' -Value {
        [bool]$printAll = $FALSE;

        switch ($this.verbose) {
            0 {
                # Default value. Only print a package but not the services include
                break;
            };
            1 {
                # Include the Operator into the check package result and OK checks of package
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
        } else {
            if ([int]$this.exitcode -ne $IcingaEnums.IcingaExitCode.Ok) {
                $this.WriteCheckErrors();
                $this.PrintNoChecksConfigured();
            }
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'AddUniqueSortedChecksToHeader' -Value {
        param($checkarray, $state);

        [hashtable]$CheckHash = @{};

        foreach ($entry in $checkarray) {
            if ($CheckHash.ContainsKey($entry) -eq $FALSE) {
                $CheckHash.Add($entry, $TRUE);
            }
        }

        [array]$SortedCheckArray = $CheckHash.GetEnumerator() | Sort-Object name;

        if ($SortedCheckArray.Count -ne 0) {
            $this.headermsg += [string]::Format(
                '{0} {1} ',
                $IcingaEnums.IcingaExitCodeText[$state],
                [string]::Join(', ', $SortedCheckArray.Key)
            );
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetWorstExitCode' -Value {
        if ([int]$this.exitcode -eq [int]$IcingaEnums.IcingaExitCode.Unknown) {
            return;
        }

        foreach ($check in $this.checks) {
            if ([int]$this.exitcode -lt $check.exitcode) {
                $this.exitcode = $check.exitcode;
            }

            $this.criticalchecks += $check.GetCriticals();
            $this.warningchecks  += $check.GetWarnings();
            $this.unknownchecks  += $check.GetUnknowns();
        }

        # Only apply this to our top package
        if ($this.spacing -ne 0) {
            return;
        }

        $this.AddUniqueSortedChecksToHeader(
            $this.criticalchecks, $IcingaEnums.IcingaExitCode.Critical
        );
        $this.AddUniqueSortedChecksToHeader(
            $this.warningchecks, $IcingaEnums.IcingaExitCode.Warning
        );
        $this.AddUniqueSortedChecksToHeader(
            $this.unknownchecks, $IcingaEnums.IcingaExitCode.Unknown
        );
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetPerfData' -Value {
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

            $CollectedPerfData.Add($data.label, $data);
        }

        # Now sort the label output by name
        $SortedArray = $CollectedPerfData.GetEnumerator() | Sort-Object name;

        # Buold the performance data output based on the sorted result
        foreach ($entry in $SortedArray) {
            $perfData += $entry.Value;
        }

        return @{
            'label'    = $this.name;
            'perfdata' = $CollectedPerfData;
            'package'  = $TRUE;
        }
    }

    $Check.Initialise();

    return $Check;
}
