Import-IcingaLib icinga\enums;
Import-IcingaLib core\tools;

function New-IcingaCheck()
{
    param(
        [string]$Name       = '',
        $Value              = $null,
        $Unit               = $null,
        [string]$Minimum    = '',
        [string]$Maximum    = '',
        $ObjectExists       = -1,
        $Translation        = $null,
        [switch]$NoPerfData
    );

    $Check = New-Object -TypeName PSObject;
    $Check | Add-Member -membertype NoteProperty -name 'name'         -value $Name;
    $Check | Add-Member -membertype NoteProperty -name 'verbose'      -value 0;
    $Check | Add-Member -membertype NoteProperty -name 'messages'     -value @();
    $Check | Add-Member -membertype NoteProperty -name 'oks'          -value @();
    $Check | Add-Member -membertype NoteProperty -name 'warnings'     -value @();
    $Check | Add-Member -membertype NoteProperty -name 'criticals'    -value @();
    $Check | Add-Member -membertype NoteProperty -name 'unknowns'     -value @();
    $Check | Add-Member -membertype NoteProperty -name 'value'        -value $Value;
    $Check | Add-Member -membertype NoteProperty -name 'exitcode'     -value -1;
    $Check | Add-Member -membertype NoteProperty -name 'unit'         -value $Unit;
    $Check | Add-Member -membertype NoteProperty -name 'spacing'      -value 0;
    $Check | Add-Member -membertype NoteProperty -name 'compiled'     -value $FALSE;
    $Check | Add-Member -membertype NoteProperty -name 'perfdata'     -value (-Not $NoPerfData);
    $Check | Add-Member -membertype NoteProperty -name 'warning'      -value '';
    $Check | Add-Member -membertype NoteProperty -name 'critical'     -value '';
    $Check | Add-Member -membertype NoteProperty -name 'minimum'      -value $Minimum;
    $Check | Add-Member -membertype NoteProperty -name 'maximum'      -value $Maximum;
    $Check | Add-Member -membertype NoteProperty -name 'objectexists' -value $ObjectExists;
    $Check | Add-Member -membertype NoteProperty -name 'translation'  -value $Translation;
    $Check | Add-Member -membertype NoteProperty -name 'checks'       -value $null;
    $Check | Add-Member -membertype NoteProperty -name 'completed'    -value $FALSE;

    $Check | Add-Member -membertype ScriptMethod -name 'AddSpacing' -value {
        $this.spacing += 1;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnOutOfRange' -value {
        param($warning);

        if ([string]::IsNullOrEmpty($warning)) {
            return $this;
        }

        if ((Test-Numeric $warning)) {
            $this.WarnIfGreaterThan($warning).WarnIfLowerThan(0) | Out-Null;
        } else {
            [array]$thresholds = $warning.Split(':');
            [string]$rangeMin = $thresholds[0];
            [string]$rangeMax = $thresholds[1];
            $negate = $rangeMin.Contains('@');
            $rangeMin = $rangeMin.Replace('@', '');
            if (-Not $negate -And (Test-Numeric $rangeMin) -And (Test-Numeric $rangeMax)) {
                $this.WarnIfLowerThan($rangeMin).WarnIfGreaterThan($rangeMax) | Out-Null;
            } elseif ((Test-Numeric $rangeMin) -And [string]::IsNullOrEmpty($rangeMax) -eq $TRUE) {
                $this.WarnIfLowerThan($rangeMin) | Out-Null;
            } elseif ($rangeMin -eq '~' -And (Test-Numeric $rangeMax)) {
                $this.WarnIfGreaterThan($rangeMax) | Out-Null;
            } elseif ($negate -And (Test-Numeric $rangeMin) -And (Test-Numeric $rangeMax)) {
                $this.WarnIfBetweenAndEqual($rangeMin, $rangeMax) | Out-Null;
            } else {
                $this.AddMessage(
                    [string]::Format(
                        'Invalid range specified for Warning argument: "{0}" of check {1}',
                        $warning,
                        $this.name
                    ),
                    $IcingaEnums.IcingaExitCode.Unknown
                )
                $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
                return $this;
            }
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfLike' -value {
        param($warning);

        if ($this.value -Like $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'like'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfNotLike' -value {
        param($warning);

        if (-Not ($this.value -Like $warning)) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'not like'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfMatch' -value {
        param($warning);

        if ($this.value -eq $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'matching'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfNotMatch' -value {
        param($warning);

        if ($this.value -ne $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'not matching'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfBetweenAndEqual' -value {
        param($min, $max);

        if ($this.value -ge $min -And $this.value -le $max) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                [string]::Format('{0}:{1}', $min, $max),
                'between'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfBetween' -value {
        param($min, $max);

        if ($this.value -gt $min -And $this.value -lt $max) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                [string]::Format('{0}:{1}', $min, $max),
                'between'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfLowerThan' -value {
        param($warning);

        if ($this.value -lt $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'lower than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfLowerEqualThan' -value {
        param($warning);

        if ($this.value -le $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'lower or equal than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfGreaterThan' -value {
        param($warning);

        if ($this.value -gt $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'greater than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfGreaterEqualThan' -value {
        param($warning);

        if ($this.value -ge $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'greater or equal than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritOutOfRange' -value {
        param($critical);

        if ([string]::IsNullOrEmpty($critical)) {
            return $this;
        }

        if ((Test-Numeric $critical)) {
            $this.CritIfGreaterThan($critical).CritIfLowerThan(0) | Out-Null;
        } else {
            [array]$thresholds = $critical.Split(':');
            [string]$rangeMin = $thresholds[0];
            [string]$rangeMax = $thresholds[1];
            $negate = $rangeMin.Contains('@');
            $rangeMin = $rangeMin.Replace('@', '');
            if (-Not $negate -And (Test-Numeric $rangeMin) -And (Test-Numeric $rangeMax)) {
                $this.CritIfLowerThan($rangeMin).CritIfGreaterThan($rangeMax) | Out-Null;
            } elseif ((Test-Numeric $rangeMin) -And [string]::IsNullOrEmpty($rangeMax) -eq $TRUE) {
                $this.CritIfLowerThan($rangeMin) | Out-Null;
            } elseif ($rangeMin -eq '~' -And (Test-Numeric $rangeMax)) {
                $this.CritIfGreaterThan($rangeMax) | Out-Null;
            } elseif ($negate -And (Test-Numeric $rangeMin) -And (Test-Numeric $rangeMax)) {
                $this.CritIfBetweenAndEqual($rangeMin, $rangeMax) | Out-Null;
            } else {
                $this.AddMessage(
                    [string]::Format(
                        'Invalid range specified for Critical argument: "{0}" of check {1}',
                        $critical,
                        $this.name
                    ),
                    $IcingaEnums.IcingaExitCode.Unknown
                )
                $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
                return $this;
            }
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfLike' -value {
        param($critical);

        if ($this.value -Like $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'like'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfNotLike' -value {
        param($critical);

        if (-Not ($this.value -Like $critical)) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'not like'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfMatch' -value {
        param($critical);

        if ($this.value -eq $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'matching'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfNotMatch' -value {
        param($critical);

        if ($this.value -ne $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'not matching'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfBetweenAndEqual' -value {
        param($min, $max);

        if ($this.value -ge $min -And $this.value -le $max) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                [string]::Format('{0}:{1}', $min, $max),
                'between'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfBetween' -value {
        param($min, $max);

        if ($this.value -gt $min -And $this.value -lt $max) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                [string]::Format('{0}:{1}', $min, $max),
                'between'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfLowerThan' -value {
        param($critical);

        if ($this.value -lt $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'lower than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfLowerEqualThan' -value {
        param($critical);

        if ($this.value -le $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'lower or equal than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfGreaterThan' -value {
        param($critical);

        if ($this.value -gt $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'greater than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfGreaterEqualThan' -value {
        param($critical);

        if ($this.value -ge $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'greater or equal than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'TranslateValue' -value {
        param($value);

        if ($null -eq $this.translation -Or $null -eq $value) {
            return $value;
        }

        $checkValue = $value;

        if ((Test-Numeric $checkValue)) {
            $checkValue = [int]$checkValue;
        }

        if ($this.translation.ContainsKey($checkValue)) {
            return $this.translation[$checkValue];
        }

        return $value;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AddInternalCheckMessage' -value {
        param($state, $value, $type);

        if ($this.objectexists -ne -1 -And $null -eq $this.objectexists) {
            $this.SetExitCode($IcingaEnums.IcingaExitCode.Unknown);
            $this.AddMessage([string]::Format(
                '{0} does not exist', $this.name
            ), $IcingaEnums.IcingaExitCode.Unknown);
            return;
        }

        $this.SetExitCode($state);
        $this.AddMessage(
            [string]::Format(
                '{0} {1}{4} is {2} {3}{4}',
                $this.name,
                $this.TranslateValue($this.value),
                $type,
                $this.TranslateValue($value),
                $this.unit
            ),
            $state
        );

        switch ($state) {
            $IcingaEnums.IcingaExitCode.Warning {
                $this.warning = $value;
                break;
            };
            $IcingaEnums.IcingaExitCode.Critical {
                $this.critical = $value;
                break;
            };
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AddMessage' -value {
        param($message, [int]$exitcode);

        [string]$outputMessage = [string]::Format(
            '{0}: {1}',
            $IcingaEnums.IcingaExitCodeText[$exitcode],
            $message
        );
        $this.messages += $outputMessage;

        switch ([int]$exitcode) {
            $IcingaEnums.IcingaExitCode.Ok {
                $this.oks += $outputMessage;
                break;
            };
            $IcingaEnums.IcingaExitCode.Warning {
                $this.warnings += $outputMessage;
                break;
            };
            $IcingaEnums.IcingaExitCode.Critical {
                $this.criticals += $outputMessage;
                break;
            };
            $IcingaEnums.IcingaExitCode.Unknown {
                $this.unknowns += $outputMessage;
                break;
            };
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintOkMessages' -value {
        param([string]$spaces);
        $this.OutputMessageArray($this.oks, $spaces);
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintWarningMessages' -value {
        param([string]$spaces);
        $this.OutputMessageArray($this.warnings, $spaces);
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintCriticalMessages' -value {
        param([string]$spaces);
        $this.OutputMessageArray($this.criticals, $spaces);
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintUnknownMessages' -value {
        param([string]$spaces);
        $this.OutputMessageArray($this.unknowns, $spaces);
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintAllMessages' -value {
        [string]$spaces = New-StringTree $this.spacing;
        $this.OutputMessageArray($this.unknowns, $spaces);
        $this.OutputMessageArray($this.criticals, $spaces);
        $this.OutputMessageArray($this.warnings, $spaces);
        $this.OutputMessageArray($this.oks, $spaces);
    }

    $Check | Add-Member -membertype ScriptMethod -name 'OutputMessageArray' -value {
        param($msgArray, [string]$spaces);

        foreach ($msg in $msgArray) {
            Write-Host ([string]::Format('{0}{1}', $spaces, $msg));
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'PrintOutputMessages' -value {
        [string]$spaces = New-StringTree $this.spacing;
        if ($this.unknowns.Count -ne 0) {
            $this.PrintUnknownMessages($spaces);
        } elseif ($this.criticals.Count -ne 0) {
            $this.PrintCriticalMessages($spaces);
        } elseif ($this.warnings.Count -ne 0) {
            $this.PrintWarningMessages($spaces);
        } else {
            if ($this.oks.Count -ne 0) {
                $this.PrintOkMessages($spaces);
            }
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'SetExitCode' -value {
        param([int]$code);

        # Only overwrite the exit code in case our new value is greater then
        # the current one Ok > Warning > Critical
        if ([int]$this.exitcode -gt $code) {
            return $this;
        }

        switch ($code) {
            0 { break; };
            1 {
                $this.oks = @();
                break;
            };
            2 {
                $this.oks = @();
                $this.warnings = @();
                break;
            };
            3 {
                $this.oks = @();
                $this.warnings = @();
                $this.criticals = @();
                break;
            };
        }

        $this.exitcode = $code;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'ValidateUnit' -value {
        if ($null -ne $this.unit -And (-Not $IcingaEnums.IcingaMeasurementUnits.ContainsKey($this.unit))) {
            $this.AddMessage(
                    [string]::Format(
                        'Error on check "{0}": Usage of invalid plugin unit "{1}". Allowed units are: {2}',
                        $this.name,
                        $this.unit,
                        (($IcingaEnums.IcingaMeasurementUnits.Keys | Sort-Object name)  -Join ', ')
                    ),
                    $IcingaEnums.IcingaExitCode.Unknown
            )
            $this.unit = '';
            $this.exitcode = $IcingaEnums.IcingaExitCode.Unknown;
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AddOkOutput' -value {
        if ([int]$this.exitcode -eq -1) {
            $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
            $this.AddMessage(
                [string]::Format(
                    '{0} is {1}{2}',
                    $this.name,
                    $this.TranslateValue($this.value),
                    $this.unit
                ),
                $IcingaEnums.IcingaExitCode.Ok
            );
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'SilentCompile' -value {
        if ($this.compiled) {
            return;
        }

        $this.AddOkOutput();
        $this.compiled = $TRUE;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'Compile' -value {
        param([bool]$Verbose = $FALSE);

        if ($this.compiled) {
            return;
        }

        $this.AddOkOutput();
        $this.compiled = $TRUE;

        if ($Verbose) {
            $this.PrintOutputMessages();
        }

        return $this.exitcode;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'GetPerfData' -value {

        if ($this.completed -Or -Not $this.perfdata) {
            return '';
        }

        $this.AutodiscoverMinMax();

        if ([string]::IsNullOrEmpty($this.minimum) -eq $FALSE) {
            $this.minimum = [string]::Format(';{0}', $this.minimum);
        }
        if ([string]::IsNullOrEmpty($this.maximum) -eq $FALSE) {
            $this.maximum = [string]::Format(';{0}', $this.maximum);
        }

        $this.completed = $TRUE;

        return [string]::Format(
            "'{0}'={1}{2};{3};{4}{5}{6} ",
            $this.name,
            $this.value,
            $this.unit,
            $this.warning,
            $this.critical,
            $this.minimum,
            $this.maximum
        );
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AutodiscoverMinMax' -value {
        if ([string]::IsNullOrEmpty($this.minimum) -eq $FALSE -Or [string]::IsNullOrEmpty($this.maximum) -eq $FALSE) {
            return;
        }

        switch ($this.unit) {
            '%' {
                $this.minimum = '0';
                $this.maximum = '100';
                if ($this.value -gt $this.maximum) {
                    $this.maximum = $this.value
                }
                break;
            }
        }
    }

    $Check.ValidateUnit();

    return $Check;
}
