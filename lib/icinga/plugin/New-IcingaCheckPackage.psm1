function New-IcingaCheckPackage()
{
    param (
        [string]$Name               = '',
        [switch]$OperatorAnd        = $FALSE,
        [switch]$OperatorOr         = $FALSE,
        [switch]$OperatorNone       = $FALSE,
        [int]$OperatorMin           = -1,
        [int]$OperatorMax           = -1,
        [array]$Checks              = @(),
        [int]$Verbose               = 0,
        [switch]$IgnoreEmptyPackage = $FALSE,
        [switch]$Hidden             = $FALSE,
        [switch]$AddSummaryHeader   = $FALSE
    );

    $IcingaCheckPackage = New-IcingaCheckBaseObject;

    $IcingaCheckPackage.Name         = $Name;
    $IcingaCheckPackage.__ObjectType = 'IcingaCheckPackage';
    $IcingaCheckPackage.__SetHidden($Hidden);
    $IcingaCheckPackage.__SetVerbosity($Verbose);

    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorAnd'        -Value $OperatorAnd;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorOr'         -Value $OperatorOr;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorNone'       -Value $OperatorNone;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorMin'        -Value $OperatorMin;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorMax'        -Value $OperatorMax;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'IgnoreEmptyPackage' -Value $IgnoreEmptyPackage;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'AddSummaryHeader'   -Value $AddSummaryHeader;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__Checks'           -Value @();
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__OkChecks'         -Value @();
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__WarningChecks'    -Value @();
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__CriticalChecks'   -Value @();
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__UnknownChecks'    -Value @();

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Name 'ValidateOperators' -Value {
        if ($this.OperatorMin -ne -1) {
            return;
        }

        if ($this.OperatorMax -ne -1) {
            return;
        }

        if ($this.OperatorNone -ne $FALSE) {
            return;
        }

        if ($this.OperatorOr -ne $FALSE) {
            return;
        }

        # If no operator is set, use And as default
        $this.OperatorAnd = $TRUE;
    }

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Name 'AddCheck' -Value {
        param([array]$Checks);

        if ($null -eq $Checks -Or $Checks.Count -eq 0) {
            return;
        }

        foreach ($check in $Checks) {
            $check.__SetIndention($this.__NewIndention());
            $check.__SetCheckOutput();
            $check.__SetVerbosity($this.__GetVerbosity());
            $check.__SetParent($this);
            [array]$this.__Checks += $check;
        }
    }

    # Override shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__SetIndention' -Value {
        param ($Indention);

        $this.__Indention = $Indention;

        foreach ($check in $this.__Checks) {
            $check.__SetIndention($this.__NewIndention());
        }
    }

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Name '__SetCheckState' -Value {
        param ($State);

        if ($this.__GetCheckState() -lt $State) {
            $this.__CheckState = $State;
            $this.__SetCheckOutput();
        }
    }

    # Override shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__SetCheckOutput' -Value {
        param ($PluginOutput);

        $UnknownChecks    = '';
        $CriticalChecks   = '';
        $WarningChecks    = '';
        $CheckSummary     = New-Object -TypeName 'System.Text.StringBuilder';
        [bool]$HasContent = $FALSE;

        # Always apply this to the first package or if we specify AddSummaryHeader
        if ($this.__GetIndention() -eq 0 -Or $this.AddSummaryHeader) {
            if ($this.__UnknownChecks.Count -ne 0) {
                $UnknownChecks = [string]::Format(' [UNKNOWN] {0}', ([string]::Join(', ', $this.__UnknownChecks)));
                $CheckSummary.Append(
                    [string]::Format(' {0} Unknown', $this.__UnknownChecks.Count)
                ) | Out-Null;
            }
            if ($this.__CriticalChecks.Count -ne 0) {
                $CriticalChecks = [string]::Format(' [CRITICAL] {0}', ([string]::Join(', ', $this.__CriticalChecks)));
                $CheckSummary.Append(
                    [string]::Format(' {0} Critical', $this.__CriticalChecks.Count)
                ) | Out-Null;
            }
            if ($this.__WarningChecks.Count -ne 0) {
                $WarningChecks = [string]::Format(' [WARNING] {0}', ([string]::Join(', ', $this.__WarningChecks)));
                $CheckSummary.Append(
                    [string]::Format(' {0} Warning', $this.__WarningChecks.Count)
                ) | Out-Null;
            }
        }

        if ($this.__OkChecks.Count -ne 0) {
            $CheckSummary.Append(
                [string]::Format(' {0} Ok', $this.__OkChecks.Count)
            ) | Out-Null;
        }

        if ($this.AddSummaryHeader -eq $FALSE) {
            $CheckSummary.Clear() | Out-Null;
            $CheckSummary.Append('') | Out-Null;
        } elseif ($CheckSummary.Length -ne 0) {
            $HasContent = $TRUE;
        }

        if ([string]::IsNullOrEmpty($this.__ErrorMessage) -eq $FALSE) {
            $HasContent = $TRUE;
        }

        $this.__CheckOutput = [string]::Format(
            '{0} {1}{2}{3}{4}{5}{6}{7}{8}',
            $IcingaEnums.IcingaExitCodeText[$this.__GetCheckState()],
            $this.Name,
            (&{ if ($HasContent) { return ':'; } else { return ''; } }),
            $CheckSummary.ToString(),
            ([string]::Format('{0}{1}', (&{ if ($this.__ErrorMessage.Length -gt 1) { return ' '; } else { return ''; } }), $this.__ErrorMessage)),
            $UnknownChecks,
            $CriticalChecks,
            $WarningChecks,
            $this.__ShowPackageConfig()
        );
    }

    $IcingaCheckPackage | Add-Member -Force -MemberType ScriptMethod -Name 'Compile' -Value {
        $this.__OkChecks.Clear();
        $this.__WarningChecks.Clear();
        $this.__CriticalChecks.Clear();
        $this.__UnknownChecks.Clear();

        $WorstState  = $IcingaEnums.IcingaExitCode.Ok;
        $BestState   = $IcingaEnums.IcingaExitCode.Ok;
        $NotOkChecks = 0;
        $OkChecks    = 0;

        if ($this.__Checks.Count -eq 0 -And $this.IgnoreEmptyPackage -eq $FALSE) {
            $this.__ErrorMessage = 'No checks added to this package';
            $this.__SetCheckState($IcingaEnums.IcingaExitCode.Unknown);
            $this.__SetCheckOutput();
            return;
        }

        [array]$this.__Checks = ($this.__Checks | Sort-Object -Property Name);

        # Loop all checks to understand the content of result
        foreach ($check in $this.__Checks) {

            $check.Compile();

            if ($check.__IsHidden() -Or $check.__NoHeaderReport()) {
                continue;
            }

            if ($WorstState -lt $check.__GetCheckState()) {
                $WorstState = $check.__GetCheckState();
            }

            if ($BestState -gt $check.__GetCheckState()) {
                $BestState = $check.__GetCheckState();
            }

            [string]$CheckStateOutput = [string]::Format(
                '{0}{1}',
                $check.__GetName(),
                $check.__GetHeaderOutputValue()
            );

            switch ($check.__GetCheckState()) {
                $IcingaEnums.IcingaExitCode.Ok {
                    $this.__OkChecks += $CheckStateOutput;
                    $OkChecks += 1;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Warning {
                    $this.__WarningChecks += $CheckStateOutput;
                    $NotOkChecks += 1;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Critical {
                    $this.__CriticalChecks += $CheckStateOutput;
                    $NotOkChecks += 1;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Unknown {
                    $this.__UnknownChecks += $CheckStateOutput;
                    $NotOkChecks += 1;
                    break;
                };
            }
        }

        if ($this.OperatorAnd -And $NotOkChecks -ne 0) {
            $this.__SetCheckState($WorstState);
        } elseif ($this.OperatorOr -And $OkChecks -eq 0 ) {
            $this.__SetCheckState($WorstState);
        } elseif ($this.OperatorNone -And $OkChecks -ne 0 ) {
            $this.__SetCheckState($WorstState);
        } elseif ($this.OperatorMin -ne -1) {
            if (-Not ($this.__Checks.Count -eq 0 -And $this.IgnoreEmptyPackage -eq $TRUE)) {
                if ($this.OperatorMin -gt $this.__Checks.Count) {
                    $this.__SetCheckState($IcingaEnums.IcingaExitCode.Unknown);
                    $this.__ErrorMessage = [string]::Format('Minium check count ({0}) is larger than number of assigned checks ({1})', $this.OperatorMin, $this.__Checks.Count);
                } elseif ($OkChecks -lt $this.OperatorMin) {
                    $this.__SetCheckState($WorstState);
                    $this.__ErrorMessage = '';
                }
            }
        } elseif ($this.OperatorMax -ne -1) {
            if (-Not ($this.__Checks.Count -eq 0 -And $this.IgnoreEmptyPackage -eq $TRUE)) {
                if ($this.OperatorMax -gt $this.__Checks.Count) {
                    $this.__SetCheckState($IcingaEnums.IcingaExitCode.Unknown);
                    $this.__ErrorMessage = [string]::Format('Maximum check count ({0}) is larger than number of assigned checks ({1})', $this.OperatorMax, $this.__Checks.Count);
                } elseif ($OkChecks -gt $this.OperatorMax) {
                    $this.__SetCheckState($WorstState);
                    $this.__ErrorMessage = '';
                }
            }
        }

        $this.__SetCheckOutput();
    }

    # Override default behaviour from shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__SetVerbosity' -Value {
        param ($Verbosity);
        # Do nothing for check packages
    }

    # Override default behaviour from shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__GetCheckOutput' -Value {

        if ($this.__IsHidden()) {
            return ''
        };

        if ($this._CanOutput() -eq $FALSE) {
            return '';
        }

        $CheckOutput = [string]::Format(
            '{0}{1}',
            (New-StringTree -Spacing $this.__GetIndention()),
            $this.__CheckOutput
        );

        foreach ($check in $this.__Checks) {
            if ($check.__IsHidden()) {
                continue;
            };

            if ($check._CanOutput() -eq $FALSE) {
                continue;
            }

            $CheckOutput = [string]::Format(
                '{0}{1}{2}',
                $CheckOutput,
                "`n",
                $check.__GetCheckOutput()
            );
        }

        return $CheckOutput;
    }

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__HasNotOkChecks' -Value {

        if ($this.__WarningChecks.Count -ne 0) {
            return $TRUE;
        }

        if ($this.__CriticalChecks.Count -ne 0) {
            return $TRUE;
        }

        if ($this.__UnknownChecks.Count -ne 0) {
            return $TRUE;
        }

        return $FALSE;
    }

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__ShowPackageConfig' -Value {
        if ($this.__GetVerbosity() -lt 3) {
            return '';
        }

        if ($this.OperatorAnd) {
            return ' (All must be [OK])';
        }
        if ($this.OperatorOr) {
            return ' (Atleast one must be [OK])';
        }
        if ($this.OperatorMin -ne -1) {
            return ([string]::Format(' (Atleast {0} must be [OK])', $this.OperatorMin));
        }
        if ($this.OperatorMax -ne -1) {
            return ([string]::Format(' (Not more than {0} must be [OK])', $this.OperatorMax));
        }

        return '';
    }

    # __GetTimeSpanThreshold(0, 'Core_30_20', 'Core_30')
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__GetTimeSpanThreshold' -Value {
        param ($TimeSpanLabel, $Label, $MultiOutput);

        foreach ($check in $this.__Checks) {
            $Result = $check.__GetTimeSpanThreshold($TimeSpanLabel, $Label, $MultiOutput);

            if ([string]::IsNullOrEmpty($Result.Interval) -eq $FALSE) {
                return $Result;
            }
        }

        return @{
            'Warning'  = '';
            'Critical' = '';
            'Interval' = '';
        };
    }

    # Override shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name 'HasChecks' -Value {
        if ($this.__Checks.Count -eq 0) {
            return $FALSE;
        }

        return $TRUE;
    }

    $IcingaCheckPackage.ValidateOperators();
    $IcingaCheckPackage.AddCheck($Checks);

    return $IcingaCheckPackage;
}
