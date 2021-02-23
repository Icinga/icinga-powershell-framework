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
        [string]$LabelName  = $null,
        [switch]$NoPerfData
    );

    $Check = New-Object -TypeName PSObject;
    $Check | Add-Member -MemberType NoteProperty -Name 'name'           -Value $Name;
    $Check | Add-Member -MemberType NoteProperty -Name 'verbose'        -Value 0;
    $Check | Add-Member -MemberType NoteProperty -Name 'messages'       -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'oks'            -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'warnings'       -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'criticals'      -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'unknowns'       -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'okchecks'       -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'warningchecks'  -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'criticalchecks' -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'unknownchecks'  -Value @();
    $Check | Add-Member -MemberType NoteProperty -Name 'value'          -Value $Value;
    $Check | Add-Member -MemberType NoteProperty -Name 'exitcode'       -Value -1;
    $Check | Add-Member -MemberType NoteProperty -Name 'unit'           -Value $Unit;
    $Check | Add-Member -MemberType NoteProperty -Name 'spacing'        -Value 0;
    $Check | Add-Member -MemberType NoteProperty -Name 'compiled'       -Value $FALSE;
    $Check | Add-Member -MemberType NoteProperty -Name 'perfdata'       -Value (-Not $NoPerfData);
    $Check | Add-Member -MemberType NoteProperty -Name 'warning'        -Value '';
    $Check | Add-Member -MemberType NoteProperty -Name 'critical'       -Value '';
    $Check | Add-Member -MemberType NoteProperty -Name 'minimum'        -Value $Minimum;
    $Check | Add-Member -MemberType NoteProperty -Name 'maximum'        -Value $Maximum;
    $Check | Add-Member -MemberType NoteProperty -Name 'objectexists'   -Value $ObjectExists;
    $Check | Add-Member -MemberType NoteProperty -Name 'translation'    -Value $Translation;
    $Check | Add-Member -MemberType NoteProperty -Name 'labelname'      -Value $LabelName;
    $Check | Add-Member -MemberType NoteProperty -Name 'checks'         -Value $null;
    $Check | Add-Member -MemberType NoteProperty -Name 'completed'      -Value $FALSE;
    $Check | Add-Member -MemberType NoteProperty -Name 'checkcommand'   -Value '';
    $Check | Add-Member -MemberType NoteProperty -Name 'checkpackage'   -Value $FALSE;

    $Check | Add-Member -MemberType ScriptMethod -Name 'HandleDaemon' -Value {
        # Only apply this once the checkcommand is set
        if ([string]::IsNullOrEmpty($this.checkcommand) -Or $global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
            return;
        }

        if ($null -eq $global:Icinga -Or $global:Icinga.ContainsKey('CheckData') -eq $FALSE) {
            return;
        }

        if ($global:Icinga.CheckData.ContainsKey($this.checkcommand)) {
            if ($global:Icinga.CheckData[$this.checkcommand]['results'].ContainsKey($this.name) -eq $FALSE) {
                $global:Icinga.CheckData[$this.checkcommand]['results'].Add(
                    $this.name,
                    @{ }
                );
            }

            $global:Icinga.CheckData[$this.checkcommand]['results'][$this.name].Add(
                (Get-IcingaUnixTime),
                $this.value
            );
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'AddSpacing' -Value {
        $this.spacing += 1;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'AssignCheckCommand' -Value {
        param($CheckCommand);

        $this.checkcommand = $CheckCommand;
        $this.HandleDaemon();
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetWarnings' -Value {
        return $this.warningchecks;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetCriticals' -Value {
        return $this.criticalchecks;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetUnknowns' -Value {
        return $this.unknownchecks;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'SetUnknown' -Value {
        $this.AddInternalCheckMessage(
            $IcingaEnums.IcingaExitCode.Unknown,
            $null,
            $null
        );

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'SetWarning' -Value {
        $this.AddInternalCheckMessage(
            $IcingaEnums.IcingaExitCode.Warning,
            $null,
            $null
        );

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnOutOfRange' -Value {
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

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfLike' -Value {
        param($warning);

        if ($this.value -Like $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'like'
            );
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfNotLike' -Value {
        param($warning);

        if (-Not ($this.value -Like $warning)) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'not like'
            );
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfMatch' -Value {
        param($warning);

        if ($this.value -eq $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'matching'
            );
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfNotMatch' -Value {
        param($warning);

        if ($this.value -ne $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'not matching'
            );
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfBetweenAndEqual' -Value {
        param($min, $max);

        if ($this.value -ge $min -And $this.value -le $max) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                [string]::Format('{0}:{1}', $min, $max),
                'between'
            );
        }

        $this.warning = [string]::Format('{0}:{1}', $min, $max);

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfBetween' -Value {
        param($min, $max);

        if ($this.value -gt $min -And $this.value -lt $max) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                [string]::Format('{0}:{1}', $min, $max),
                'between'
            );
        }

        $this.warning = [string]::Format('{0}:{1}', $min, $max);

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfLowerThan' -Value {
        param($warning);

        if ($this.value -lt $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'lower than'
            );
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfLowerEqualThan' -Value {
        param($warning);

        if ($this.value -le $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'lower or equal than'
            );
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfGreaterThan' -Value {
        param($warning);

        if ($this.value -gt $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'greater than'
            );
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'WarnIfGreaterEqualThan' -Value {
        param($warning);

        if ($this.value -ge $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'greater or equal than'
            );
        }

        $this.warning = $warning;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'SetCritical' -Value {
        $this.AddInternalCheckMessage(
            $IcingaEnums.IcingaExitCode.Critical,
            $null,
            $null
        );

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritOutOfRange' -Value {
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

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfLike' -Value {
        param($critical);

        if ($this.value -Like $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'like'
            );
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfNotLike' -Value {
        param($critical);

        if (-Not ($this.value -Like $critical)) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'not like'
            );
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfMatch' -Value {
        param($critical);

        if ($this.value -eq $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'matching'
            );
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfNotMatch' -Value {
        param($critical);

        if ($this.value -ne $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'not matching'
            );
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfBetweenAndEqual' -Value {
        param($min, $max);

        if ($this.value -ge $min -And $this.value -le $max) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                [string]::Format('{0}:{1}', $min, $max),
                'between'
            );
        }

        $this.critical = [string]::Format('{0}:{1}', $min, $max);

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfBetween' -Value {
        param($min, $max);

        if ($this.value -gt $min -And $this.value -lt $max) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                [string]::Format('{0}:{1}', $min, $max),
                'between'
            );
        }

        $this.critical = [string]::Format('{0}:{1}', $min, $max);

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfLowerThan' -Value {
        param($critical);

        if ($this.value -lt $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'lower than'
            );
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfLowerEqualThan' -Value {
        param($critical);

        if ($this.value -le $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'lower or equal than'
            );
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfGreaterThan' -Value {
        param($critical);

        if ($this.value -gt $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'greater than'
            );
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'CritIfGreaterEqualThan' -Value {
        param($critical);

        if ($this.value -ge $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'greater or equal than'
            );
        }

        $this.critical = $critical;

        return $this;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'TranslateValue' -Value {
        param($value);

        $value = Format-IcingaPerfDataValue $value;

        if ($null -eq $this.translation -Or $null -eq $value) {
            return $value;
        }

        $checkValue = $value;

        if ((Test-Numeric $checkValue)) {
            $checkValue = [int]$checkValue;
        } else {
            $checkValue = [string]$checkValue;
        }

        if ($this.translation.ContainsKey($checkValue)) {
            return $this.translation[$checkValue];
        }

        return $value;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'AddInternalCheckMessage' -Value {
        param($state, $value, $type);

        if ($this.objectexists -ne -1 -And $null -eq $this.objectexists) {
            $this.SetExitCode($IcingaEnums.IcingaExitCode.Unknown);
            $this.AddMessage(
                [string]::Format(
                    '{0} does not exist', $this.name
                ),
                $IcingaEnums.IcingaExitCode.Unknown
            );
            return;
        }

        $this.SetExitCode($state);

        if ($null -eq $value -And $null -eq $type) {
            $this.AddMessage(
                $this.name,
                $state
            );
        } else {
            $this.AddMessage(
                [string]::Format(
                    '{0}: Value "{1}{4}" is {2} threshold "{3}{4}"',
                    $this.name,
                    $this.TranslateValue($this.value),
                    $type,
                    $this.TranslateValue($value),
                    $this.unit
                ),
                $state
            );
        }

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

    $Check | Add-Member -MemberType ScriptMethod -Name 'AddMessage' -Value {
        param($message, [int]$exitcode);

        [string]$outputMessage = [string]::Format(
            '{0} {1}',
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

    $Check | Add-Member -MemberType ScriptMethod -Name 'AddCheckStateArrays' -Value {
        switch ([int]$this.exitcode) {
            $IcingaEnums.IcingaExitCode.Ok {
                $this.okchecks += $this.name;
                break;
            };
            $IcingaEnums.IcingaExitCode.Warning {
                $this.warningchecks += $this.name;
                break;
            };
            $IcingaEnums.IcingaExitCode.Critical {
                $this.criticalchecks += $this.name;
                break;
            };
            $IcingaEnums.IcingaExitCode.Unknown {
                $this.unknownchecks += $this.name;
                break;
            };
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintOkMessages' -Value {
        param([string]$spaces);
        $this.OutputMessageArray($this.oks, $spaces);
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintWarningMessages' -Value {
        param([string]$spaces);
        $this.OutputMessageArray($this.warnings, $spaces);
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintCriticalMessages' -Value {
        param([string]$spaces);
        $this.OutputMessageArray($this.criticals, $spaces);
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintUnknownMessages' -Value {
        param([string]$spaces);
        $this.OutputMessageArray($this.unknowns, $spaces);
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintAllMessages' -Value {
        [string]$spaces = New-StringTree $this.spacing;
        $this.OutputMessageArray($this.unknowns, $spaces);
        $this.OutputMessageArray($this.criticals, $spaces);
        $this.OutputMessageArray($this.warnings, $spaces);
        $this.OutputMessageArray($this.oks, $spaces);
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'OutputMessageArray' -Value {
        param($msgArray, [string]$spaces);

        foreach ($msg in $msgArray) {
            Write-IcingaPluginOutput ([string]::Format('{0}{1}', $spaces, $msg));
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'PrintOutputMessages' -Value {
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

    $Check | Add-Member -MemberType ScriptMethod -Name 'SetExitCode' -Value {
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

    $Check | Add-Member -MemberType ScriptMethod -Name 'ValidateUnit' -Value {
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

    $Check | Add-Member -MemberType ScriptMethod -Name 'AddOkOutput' -Value {
        if ([int]$this.exitcode -eq -1) {
            $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
            $this.AddMessage(
                [string]::Format(
                    '{0}: {1}{2}',
                    $this.name,
                    $this.TranslateValue($this.value),
                    $this.unit
                ),
                $IcingaEnums.IcingaExitCode.Ok
            );
        }
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'SilentCompile' -Value {
        if ($this.compiled) {
            return;
        }

        $this.AddOkOutput();
        $this.compiled = $TRUE;
        $this.AddCheckStateArrays();
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'Compile' -Value {
        param([bool]$Verbose = $FALSE);

        if ($this.compiled) {
            return;
        }

        $this.AddOkOutput();
        $this.compiled = $TRUE;

        if ($Verbose) {
            $this.PrintOutputMessages();
        }

        $this.AddCheckStateArrays();

        return $this.exitcode;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'GetPerfData' -Value {

        if ($this.completed -Or -Not $this.perfdata) {
            return $null;
        }

        $this.AutodiscoverMinMax();

        $this.completed    = $TRUE;
        [string]$LabelName = (Format-IcingaPerfDataLabel $this.name);
        $value             = ConvertTo-Integer -Value $this.value -NullAsEmpty;
        $warning           = ConvertTo-Integer -Value $this.warning -NullAsEmpty;
        $critical          = ConvertTo-Integer -Value $this.critical -NullAsEmpty;

        if ([string]::IsNullOrEmpty($this.labelname) -eq $FALSE) {
            $LabelName = $this.labelname;
        }

        $perfdata = @{
            'label'    = $LabelName;
            'perfdata' = '';
            'unit'     = $this.unit;
            'value'    = (Format-IcingaPerfDataValue $value);
            'warning'  = (Format-IcingaPerfDataValue $warning);
            'critical' = (Format-IcingaPerfDataValue $critical);
            'minimum'  = (Format-IcingaPerfDataValue $this.minimum);
            'maximum'  = (Format-IcingaPerfDataValue $this.maximum);
            'package'  = $FALSE;
        };

        return $perfdata;
    }

    $Check | Add-Member -MemberType ScriptMethod -Name 'AutodiscoverMinMax' -Value {
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
    $Check.HandleDaemon();

    return $Check;
}
