function New-IcingaCheck()
{
    param(
        [string]$Name           = '',
        $Value                  = $null,
        $BaseValue              = $null,
        $Unit                   = '',
        $MetricIndex            = 'default',
        $MetricName             = '',
        $MetricTemplate         = '',
        [string]$Minimum        = '',
        [string]$Maximum        = '',
        $ObjectExists           = -1,
        $Translation            = $null,
        [string]$LabelName      = $null,
        [switch]$NoPerfData     = $FALSE,
        [switch]$NoHeaderReport = $FALSE
    );

    $IcingaCheck = New-IcingaCheckBaseObject;

    $IcingaCheck.Name         = $Name;
    $IcingaCheck.__ObjectType = 'IcingaCheck';

    # Ensure we always set our current value to 0 in case it is null and we set a unit, to prevent conversion exceptions
    if ([string]::IsNullOrEmpty($Unit) -eq $FALSE -And $null -eq $Value) {
        $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Value' -Value 0;
    } else {
        $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Value' -Value $Value;
    }

    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'BaseValue'         -Value $BaseValue;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Unit'              -Value $Unit;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'MetricIndex'       -Value $MetricIndex;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'MetricName'        -Value $MetricName;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'MetricTemplate'    -Value $MetricTemplate;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Minimum'           -Value $Minimum;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Maximum'           -Value $Maximum;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'ObjectExists'      -Value $ObjectExists;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Translation'       -Value $Translation;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'LabelName'         -Value $LabelName;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'NoPerfData'        -Value $NoPerfData;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__WarningValue'    -Value $null;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__CriticalValue'   -Value $null;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__LockedState'     -Value $FALSE;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__ThresholdObject' -Value $null;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__TimeInterval'    -Value $null;

    $IcingaCheck.__SetNoHeaderReport($NoHeaderReport);

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name 'Compile' -Value {
        $this.__ValidateThresholdInput();
        if ($null -eq $this.__ThresholdObject) {
            $this.__CreateDefaultThresholdObject();
        }
        $this.__SetCheckOutput();
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__SetInternalTimeInterval' -Value {
        $CallStack           = Get-PSCallStack;
        [bool]$FoundInterval = $FALSE;

        foreach ($entry in $CallStack) {
            if ($FoundInterval) {
                break;
            }
            [string]$CheckCommand = $entry.Command;
            if ($CheckCommand -eq $this.__CheckCommand) {
                [string]$CheckArguments = $entry.Arguments.Replace('{', '').Replace('}', '');
                [array]$SplitArgs       = $CheckArguments.Split(',');

                foreach ($SetArg in $SplitArgs) {
                    $SetArg = $SetArg.Replace(' ', '');
                    if ($FoundInterval) {
                        $this.__TimeInterval = $SetArg;
                        break;
                    }
                    if ($SetArg -eq '-ThresholdInterval' -Or $SetArg -eq '-ThresholdInterval:') {
                        $FoundInterval = $TRUE;
                        continue;
                    }
                }
                break;
            }
        }
    }

    # Override shared function
    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__GetHeaderOutputValue' -Value {
        if ($null -eq $this.__ThresholdObject) {
            return ''
        }

        if ([string]::IsNullOrEmpty($this.__ThresholdObject.HeaderValue)) {
            return '';
        }

        return (
            [string]::Format(
                ' ({0})',
                $this.__ThresholdObject.HeaderValue
            )
        )
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__CreateDefaultThresholdObject' -Value {
        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $this.__ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;
        $this.__SetCheckState($this.__ThresholdObject, $IcingaEnums.IcingaExitCode.Ok);
    }

    # Override shared function
    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__SetCheckOutput' -Value {
        param ($PluginOutput);

        if ($this.__InLockState()) {
            return;
        }

        $PluginThresholds = '';
        $TimeSpan         = '';
        $PluginThresholds = $this.__ThresholdObject.Message;

        if ([string]::IsNullOrEmpty($PluginOutput) -eq $FALSE) {
            $PluginThresholds = $PluginOutput;
        }

        <#if ($null -ne $this.__ThresholdObject -And [string]::IsNullOrEmpty($this.__ThresholdObject.TimeSpan) -eq $FALSE) {
            $TimeSpan = [string]::Format(
                '{0}({1}m avg.)',
                (&{ if ([string]::IsNullOrEmpty($PluginThresholds)) { return ''; } else { return ' ' } }),
                $this.__ThresholdObject.TimeSpanOutput
            );
        }#>

        [bool]$AddColon = $TRUE;

        if ([string]::IsNullOrEmpty($this.Name) -eq $FALSE -And $this.Name[$this.Name.Length - 1] -eq ':') {
            $AddColon = $FALSE;
        }

        $this.__CheckOutput = [string]::Format(
            '{0} {1}{2} {3}{4}',
            $IcingaEnums.IcingaExitCodeText[$this.__CheckState],
            $this.Name,
            (&{ if ($AddColon) { return ':'; } else { return ''; } }),
            $PluginThresholds,
            $TimeSpan
        );

        $this.__SetPerformanceData();
    }

    # __GetTimeSpanThreshold(0, 'Core_30_20', 'Core_30')
    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__GetTimeSpanThreshold' -Value {
        param ($TimeSpanLabel, $Label, $MultiOutput);

        [hashtable]$TimeSpans = @{
            'Warning'  = '';
            'Critical' = '';
            'Interval' = '';
        }

        [string]$LabelName = (Format-IcingaPerfDataLabel -PerfData $this.Name -MultiOutput:$MultiOutput);
        if ([string]::IsNullOrEmpty($this.LabelName) -eq $FALSE) {
            $LabelName = $this.LabelName;
        }

        if ($Label -ne $LabelName) {
            return $TimeSpans;
        }

        $TimeSpan = $TimeSpanLabel.Replace($Label, '').Replace('_', '').Replace('::Interval', '').Replace('::', '');

        if ($null -ne $this.__WarningValue -And [string]::IsNullOrEmpty($this.__WarningValue.TimeSpan) -eq $FALSE -And $this.__WarningValue.TimeSpan -eq $TimeSpan) {
            $TimeSpans.Warning = $this.__WarningValue.Threshold.Threshold;
        }
        if ($null -ne $this.__CriticalValue -And [string]::IsNullOrEmpty($this.__CriticalValue.TimeSpan) -eq $FALSE -And $this.__CriticalValue.TimeSpan -eq $TimeSpan) {
            $TimeSpans.Critical = $this.__CriticalValue.Threshold.Threshold;
        }
        $TimeSpans.Interval = $TimeSpan;

        return $TimeSpans;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__GetWarningThresholdObject' -Value {
        return $this.__WarningValue;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__GetCriticalThresholdObject' -Value {
        return $this.__CriticalValue;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__SetPerformanceData' -Value {
        if ($null -eq $this.__ThresholdObject -Or $this.NoPerfData) {
            return;
        }

        [string]$LabelName      = (Format-IcingaPerfDataLabel -PerfData $this.Name);
        [string]$MultiLabelName = (Format-IcingaPerfDataLabel -PerfData $this.Name -MultiOutput);
        $value                  = ConvertTo-Integer -Value $this.__ThresholdObject.Value -NullAsEmpty;
        $warning                = '';
        $critical               = '';

        # Set our threshold to nothing if we use time spans, as it would cause performance metrics to
        # contain warning/critical values for everything, which is not correct
        if ([string]::IsNullOrEmpty($this.__WarningValue.TimeSpan)) {
            $warning = ConvertTo-Integer -Value $this.__WarningValue.Threshold.Threshold -NullAsEmpty;
        }
        if ([string]::IsNullOrEmpty($this.__CriticalValue.TimeSpan)) {
            $critical = ConvertTo-Integer -Value $this.__CriticalValue.Threshold.Threshold -NullAsEmpty;
        }

        if ([string]::IsNullOrEmpty($this.LabelName) -eq $FALSE) {
            $LabelName      = $this.LabelName;
            $MultiLabelName = $this.LabelName;
        }

        if ([string]::IsNullOrEmpty($this.Minimum) -And [string]::IsNullOrEmpty($this.Maximum)) {
            if ($this.Unit -eq '%') {
                $this.Minimum = '0';
                $this.Maximum = '100';
            } elseif ($null -ne $this.BaseValue) {
                $this.Minimum = '0';
                $this.Maximum = $this.__ThresholdObject.BaseValue;
            }

            if ([string]::IsNullOrEmpty($this.Maximum) -eq $FALSE -And (Test-Numeric $this.Maximum) -And (Test-Numeric $this.Value) -And $this.Value -gt $this.Maximum) {
                $this.Maximum = $this.__ThresholdObject.Value;
            }
        }

        $PerfDataTemplate = ($this.__CheckCommand.Replace('Invoke-IcingaCheck', ''));

        if ([string]::IsNullOrEmpty($this.MetricTemplate) -eq $FALSE) {
            $PerfDataTemplate = $this.MetricTemplate;
        }

        [string]$PerfDataName = [string]::Format(
            '{0}::ifw_{1}::{2}',
            $this.MetricIndex,
            $PerfDataTemplate.ToLower(),
            $this.MetricName
        );

        # Ensure we only add a label with identical name once
        if ($Global:Icinga.Private.Scheduler.PerfDataWriter.Cache.ContainsKey($PerfDataName) -eq $FALSE) {
            $Global:Icinga.Private.Scheduler.PerfDataWriter.Cache.Add($PerfDataName, $TRUE);
        } else {
            return;
        }

        [string]$PerfDataLabel = [string]::Format(
            '{0}={1}{2};{3};{4};{5};{6}',
            $PerfDataName,
            (Format-IcingaPerfDataValue $value),
            $this.__ThresholdObject.PerfUnit,
            (Format-IcingaPerfDataValue $warning),
            (Format-IcingaPerfDataValue $critical),
            (Format-IcingaPerfDataValue $this.Minimum),
            (Format-IcingaPerfDataValue $this.Maximum)
        );

        # Add a space before adding another metric
        if ($Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Length -ne 0) {
            $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Append(' ') | Out-Null;
        }

        $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Append($PerfDataLabel.ToLower()) | Out-Null;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__ValidateObject' -Value {
        if ($null -eq $this.ObjectExists) {
            $this.SetUnknown() | Out-Null;
            $this.__SetCheckOutput('The object does not exist');
            $this.__LockState();
        }
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__LockState' -Value {
        $this.__LockedState = $TRUE;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__InLockState' -Value {
        return $this.__LockedState;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__ValidateUnit' -Value {
        if ([string]::IsNullOrEmpty($this.Unit) -eq $FALSE -And (-Not $IcingaEnums.IcingaMeasurementUnits.ContainsKey($this.Unit))) {
            $this.SetUnknown();
            $this.__SetCheckOutput(
                [string]::Format(
                    'Usage of invalid plugin unit "{0}". Allowed units are: {1}',
                    $this.Unit,
                    (($IcingaEnums.IcingaMeasurementUnits.Keys | Sort-Object name)  -Join ', ')
                )
            );

            $this.__LockState();
            $this.unit = $null;
        }
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__ValidateMetricsName' -Value {
        if ([string]::IsNullOrEmpty($this.MetricIndex)) {
            Write-IcingaConsoleError -Message 'The metric index has no default value for the check object "{0}"' -Objects $this.Name;
        } else {
            $this.MetricIndex = Format-IcingaPerfDataLabel -PerfData $this.MetricIndex -MultiOutput;
        }

        if ([string]::IsNullOrEmpty($this.MetricName)) {
            $this.MetricName = Format-IcingaPerfDataLabel -PerfData $this.Name -MultiOutput;
        } else {
            $this.MetricName = Format-IcingaPerfDataLabel -PerfData $this.MetricName -MultiOutput;
        }
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__ConvertMinMax' -Value {
        if ([string]::IsNullOrEmpty($this.Unit) -eq $FALSE) {
            if ([string]::IsNullOrEmpty($this.Minimum) -eq $FALSE) {
                $this.Minimum = (Convert-IcingaPluginThresholds -Threshold ([string]::Format('{0}{1}', $this.Minimum, $this.Unit))).Value;
            }
            if ([string]::IsNullOrEmpty($this.Maximum) -eq $FALSE) {
                $this.Maximum = (Convert-IcingaPluginThresholds -Threshold ([string]::Format('{0}{1}', $this.Maximum, $this.Unit))).Value;
            }
        }
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__SetCurrentExecutionTime' -Value {
        if ($null -eq $global:Icinga) {
            $global:Icinga = @{ };
        }

        if ($global:Icinga.ContainsKey('CurrentDate') -eq $FALSE) {
            $global:Icinga.Add('CurrentDate', (Get-Date));
            return;
        }

        if ($null -ne $global:Icinga.CurrentDate) {
            return;
        }

        $global:Icinga.CurrentDate = (Get-Date).ToUniversalTime();
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__AddCheckDataToCache' -Value {

        # We only require this in case we are running as daemon
        if ([string]::IsNullOrEmpty($this.__CheckCommand) -Or $Global:Icinga.Protected.RunAsDaemon -eq $FALSE) {
            return;
        }

        if ($global:Icinga.Private.Scheduler.CheckData.ContainsKey($this.__CheckCommand) -eq $FALSE) {
            return;
        }

        # Fix possible error for identical time stamps due to internal exceptions
        # and check execution within the same time slot because of this
        [string]$TimeIndex = Get-IcingaUnixTime;
        [string]$LabelName = $this.Name;

        if ([string]::IsNullOrEmpty($this.LabelName) -eq $FALSE) {
            $LabelName = $this.LabelName;
        }

        Add-IcingaHashtableItem -Hashtable $global:Icinga.Private.Scheduler.CheckData[$this.__CheckCommand]['results'] -Key $LabelName -Value @{ } | Out-Null;
        Add-IcingaHashtableItem -Hashtable $global:Icinga.Private.Scheduler.CheckData[$this.__CheckCommand]['results'][$LabelName] -Key $TimeIndex -Value $this.Value -Override | Out-Null;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'SetOk' -Value {
        param ([string]$Message, [bool]$Lock);

        if ($this.__InLockState() -eq $FALSE) {
            $this.__CheckState = $IcingaEnums.IcingaExitCode.Ok;
            $this.__SetCheckOutput($Message);
        }

        if ($Lock) {
            $this.__LockState();
        }

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'SetWarning' -Value {
        param ([string]$Message, [bool]$Lock);

        if ($this.__InLockState() -eq $FALSE) {
            $this.__CheckState = $IcingaEnums.IcingaExitCode.Warning;
            $this.__SetCheckOutput($Message);
        }

        if ($Lock) {
            $this.__LockState();
        }

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'SetCritical' -Value {
        param ([string]$Message, [bool]$Lock);

        if ($this.__InLockState() -eq $FALSE) {
            $this.__CheckState = $IcingaEnums.IcingaExitCode.Critical;
            $this.__SetCheckOutput($Message);
        }

        if ($Lock) {
            $this.__LockState();
        }

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'SetUnknown' -Value {
        param ([string]$Message, [bool]$Lock);

        if ($this.__InLockState() -eq $FALSE) {
            $this.__CheckState = $IcingaEnums.IcingaExitCode.Unknown;
            $this.__SetCheckOutput($Message);
        }

        if ($Lock) {
            $this.__LockState();
        }

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__SetCheckState' -Value {
        param ($ThresholdObject, $State);

        if ($ThresholdObject.HasError) {
            $this.SetUnknown() | Out-Null;
            $this.__ThresholdObject = $ThresholdObject;
            $this.__SetCheckOutput($this.__ThresholdObject.Message);
            $this.__LockState();
            return;
        }

        if ($this.__InLockState()) {
            return;
        }

        # In case no thresholds are set, always set the first value
        if ($null -eq $this.__ThresholdObject) {
            $this.__ThresholdObject = $ThresholdObject;
        }

        if ($ThresholdObject.IsOk -eq $FALSE) {
            if ($this.__CheckState -lt $State) {
                $this.__CheckState      = $State;
                $this.__ThresholdObject = $ThresholdObject;
            }
        }

        $this.__SetCheckOutput();
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__GetBaseThresholdArguments' -Value {
        return @{
            '-InputValue'     = $this.Value;
            '-BaseValue'      = $this.BaseValue;
            '-Unit'           = $this.Unit;
            '-CheckName'      = $this.__GetName();
            '-PerfDataLabel'  = $this.LabelName;
            '-ThresholdCache' = (Get-IcingaThresholdCache -CheckCommand $this.__CheckCommand);
            '-Translation'    = $this.Translation;
            '-TimeInterval'   = $this.__TimeInterval;
        };
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnOutOfRange' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnOutOfRange($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnDateTime' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnDateTime($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-DateTime', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfLike' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnIfLike($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-Matches', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfNotLike' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnIfNotLike($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-NotMatches', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfMatch' -Value {
        param ($Threshold);

        return $this.WarnIfLike($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfNotMatch' -Value {
        param ($Threshold);

        return $this.WarnIfNotLike($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritOutOfRange' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritOutOfRange($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritDateTime' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritDateTime($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-DateTime', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfLike' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritIfLike($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-Matches', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfNotLike' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritIfNotLike($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-NotMatches', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfMatch' -Value {
        param ($Threshold);

        return $this.CritIfLike($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfNotMatch' -Value {
        param ($Threshold);

        return $this.CritIfNotLike($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfBetweenAndEqual' -Value {
        param ($Min, $Max);

        [string]$Threshold = [string]::Format('@{0}:{1}', $Min, $Max);

        return $this.WarnOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfBetweenAndEqual' -Value {
        param ($Min, $Max);

        [string]$Threshold = [string]::Format('@{0}:{1}', $Min, $Max);

        return $this.CritOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfLowerThan' -Value {
        param ($Value);

        if ($null -ne $Value -And $Value.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Value) {
                $this.WarnIfLowerThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [string]$Threshold = [string]::Format('{0}:', $Value);

        return $this.WarnOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfLowerThan' -Value {
        param ($Value);

        if ($null -ne $Value -And $Value.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Value) {
                $this.CritIfLowerThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [string]$Threshold = [string]::Format('{0}:', $Value);

        return $this.CritOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfGreaterThan' -Value {
        param ($Value);

        if ($null -ne $Value -And $Value.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Value) {
                $this.WarnIfGreaterThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [string]$Threshold = [string]::Format('~:{0}', $Value);

        return $this.WarnOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfGreaterThan' -Value {
        param ($Value);

        if ($null -ne $Value -And $Value.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Value) {
                $this.CritIfGreaterThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [string]$Threshold = [string]::Format('~:{0}', $Value);

        return $this.CritOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfBetween' -Value {
        param ($Min, $Max);

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Minimum', $Min);
        $ThresholdArguments.Add('-Maximum', $Max);
        $ThresholdArguments.Add('-IsBetween', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfBetween' -Value {
        param ($Min, $Max);

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Minimum', $Min);
        $ThresholdArguments.Add('-Maximum', $Max);
        $ThresholdArguments.Add('-IsBetween', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfLowerEqualThan' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnIfLowerEqualThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-IsLowerEqual', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfLowerEqualThan' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritIfLowerEqualThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-IsLowerEqual', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfGreaterEqualThan' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnIfGreaterEqualThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-IsGreaterEqual', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfGreaterEqualThan' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritIfGreaterEqualThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-IsGreaterEqual', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__ValidateThresholdInput' -Value {
        if ($null -eq $this.__WarningValue -Or $null -eq $this.__CriticalValue) {
            return;
        }

        [bool]$OutOfRange = $FALSE;

        # Both thresholds use the mode
        if ($this.__WarningValue.Threshold.Mode -eq $this.__CriticalValue.Threshold.Mode) {

            #Handles 20
            if ($this.__WarningValue.Threshold.Mode -eq $IcingaEnums.IcingaThresholdMethod.Default -And $null -ne $this.__WarningValue.Threshold.Value -And $null -ne $this.__CriticalValue.Threshold.Value) {
                if ($this.__WarningValue.Threshold.Value -gt $this.__CriticalValue.Threshold.Value) {
                    $OutOfRange = $TRUE;
                }
            }

            # Handles: 30:40
            if ($this.__WarningValue.Threshold.Mode -eq $IcingaEnums.IcingaThresholdMethod.Between) {
                if ($this.__WarningValue.Threshold.StartRange -lt $this.__CriticalValue.Threshold.StartRange) {
                    $OutOfRange = $TRUE;
                }
                if ($this.__WarningValue.Threshold.EndRange -gt $this.__CriticalValue.Threshold.EndRange) {
                    $OutOfRange = $TRUE;
                }
            # Handles: @30:40
            } elseif ($this.__WarningValue.Threshold.Mode -eq $IcingaEnums.IcingaThresholdMethod.Outside) {
                if ($this.__WarningValue.Threshold.StartRange -ge $this.__CriticalValue.Threshold.StartRange) {
                    $OutOfRange = $TRUE;
                }
                if ($this.__WarningValue.Threshold.EndRange -le $this.__CriticalValue.Threshold.EndRange) {
                    $OutOfRange = $TRUE;
                }
            }

            # Handles:  20:
            if ($this.__WarningValue.Threshold.Mode -eq $IcingaEnums.IcingaThresholdMethod.Lower -And $null -ne $this.__WarningValue.Threshold.Value -And $null -ne $this.__CriticalValue.Threshold.Value) {
                if ($this.__WarningValue.Threshold.Value -lt $this.__CriticalValue.Threshold.Value) {
                    $OutOfRange = $TRUE;
                }
            }

            # Handles:  ~:20
            if ($this.__WarningValue.Threshold.Mode -eq $IcingaEnums.IcingaThresholdMethod.Greater -And $null -ne $this.__WarningValue.Threshold.Value -And $null -ne $this.__CriticalValue.Threshold.Value) {
                if ($this.__WarningValue.Threshold.Value -gt $this.__CriticalValue.Threshold.Value) {
                    $OutOfRange = $TRUE;
                }
            }
        } else {
            # Todo: Implement handling for mixed modes
        }

        if ($OutOfRange) {
            $this.SetUnknown([string]::Format('Warning threshold range "{0}" is greater than Critical threshold range "{1}"', $this.__WarningValue.Threshold.Threshold, $this.__CriticalValue.Threshold.Threshold), $TRUE) | Out-Null;
        }
    }

    $IcingaCheck.__ValidateObject();
    $IcingaCheck.__ValidateUnit();
    $IcingaCheck.__ValidateMetricsName();
    $IcingaCheck.__SetCurrentExecutionTime();
    $IcingaCheck.__AddCheckDataToCache();
    $IcingaCheck.__SetInternalTimeInterval();
    $IcingaCheck.__ConvertMinMax();

    return $IcingaCheck;
}
