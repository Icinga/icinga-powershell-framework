function New-IcingaCheck()
{
    param(
        [string]$Name       = '',
        $Value              = $null,
        $BaseValue          = $null,
        $Unit               = '',
        [string]$Minimum    = '',
        [string]$Maximum    = '',
        $ObjectExists       = -1,
        $Translation        = $null,
        [string]$LabelName  = $null,
        [switch]$NoPerfData = $FALSE
    );

    $IcingaCheck = New-IcingaCheckBaseObject;

    $IcingaCheck.Name         = $Name;
    $IcingaCheck.__ObjectType = 'IcingaCheck';

    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Value'             -Value $Value;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'BaseValue'         -Value $BaseValue;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Unit'              -Value $Unit;
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
                    if ($SetArg -eq '-ThresholdInterval') {
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

    # Override shared function
    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__SetCheckOutput' -Value {
        param ($PluginOutput);

        if ($this.__InLockState()) {
            return;
        }

        $PluginThresholds = '';
        $TimeSpan         = '';

        if ($null -ne $this.__ThresholdObject) {
            $PluginThresholds = $this.__ThresholdObject.FullMessage;
        } elseif ($null -ne $this.Value) {
            # In case we simply added a value to a check and not did anything with it, output the raw value properly formatted like anything else
            $PluginThresholds = (ConvertTo-IcingaPluginOutputTranslation -Translation $this.Translation -Value (Convert-IcingaPluginValueToString -Unit $this.Unit -Value $this.Value));
        }

        if ([string]::IsNullOrEmpty($PluginOutput) -eq $FALSE) {
            $PluginThresholds = $PluginOutput;
        }

        if ($null -ne $this.__ThresholdObject -And [string]::IsNullOrEmpty($this.__ThresholdObject.TimeSpan) -eq $FALSE) {
            $TimeSpan = [string]::Format(
                '{0}({1}m avg.)',
                (&{ if ([string]::IsNullOrEmpty($PluginThresholds)) { return ''; } else { return ' ' } }),
                $this.__ThresholdObject.TimeSpan
            );
        }

        $this.__CheckOutput = [string]::Format(
            '{0} {1}: {2}{3}',
            $IcingaEnums.IcingaExitCodeText[$this.__CheckState],
            $this.Name,
            $PluginThresholds,
            $TimeSpan
        );

        $this.__SetPerformanceData();
    }

    # __GetTimeSpanThreshold(0, 'Core_30_20', 'Core_30')
    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__GetTimeSpanThreshold' -Value {
        param ($TimeSpanLabel, $Label);

        [hashtable]$TimeSpans = @{
            'Warning'  = '';
            'Critical' = '';
        }

        [string]$LabelName = (Format-IcingaPerfDataLabel $this.Name);
        if ([string]::IsNullOrEmpty($this.LabelName) -eq $FALSE) {
            $LabelName = $this.LabelName;
        }

        if ($Label -ne $LabelName) {
            return $TimeSpans;
        }

        $TimeSpan = $TimeSpanLabel.Replace($Label, '').Replace('_', '');

        if ($null -ne $this.__WarningValue -And [string]::IsNullOrEmpty($this.__WarningValue.TimeSpan) -eq $FALSE -And $this.__WarningValue.TimeSpan -eq $TimeSpan) {
            $TimeSpans.Warning = $this.__WarningValue.IcingaThreshold;
        }
        if ($null -ne $this.__CriticalValue -And [string]::IsNullOrEmpty($this.__CriticalValue.TimeSpan) -eq $FALSE -And $this.__CriticalValue.TimeSpan -eq $TimeSpan) {
            $TimeSpans.Critical = $this.__CriticalValue.IcingaThreshold;
        }

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

        [string]$LabelName = (Format-IcingaPerfDataLabel $this.Name);
        $value             = ConvertTo-Integer -Value $this.__ThresholdObject.RawValue -NullAsEmpty;
        $warning           = '';
        $critical          = '';

        # Set our threshold to nothing if we use time spans, as it would cause performance metrics to
        # contain warning/critical values for everything, which is not correct
        if ([string]::IsNullOrEmpty($this.__WarningValue.TimeSpan)) {
            $warning = ConvertTo-Integer -Value $this.__WarningValue.IcingaThreshold -NullAsEmpty;
        }
        if ([string]::IsNullOrEmpty($this.__CriticalValue.TimeSpan)) {
            $critical = ConvertTo-Integer -Value $this.__CriticalValue.IcingaThreshold -NullAsEmpty;
        }

        if ([string]::IsNullOrEmpty($this.LabelName) -eq $FALSE) {
            $LabelName = $this.LabelName;
        }

        if ([string]::IsNullOrEmpty($this.Minimum) -And [string]::IsNullOrEmpty($this.Maximum)) {
            if ($this.Unit -eq '%') {
                $this.Minimum = '0';
                $this.Maximum = '100';
            } elseif ($null -ne $this.BaseValue) {
                $this.Minimum = '0';
                $this.Maximum = $this.__ThresholdObject.BaseValue;
            }

            if ($this.Value -gt $this.Maximum) {
                $this.Maximum = $this.__ThresholdObject.RawValue;
            }
        }

        $this.__CheckPerfData = @{
            'label'    = $LabelName;
            'perfdata' = '';
            'unit'     = $this.__ThresholdObject.PerfUnit;
            'value'    = (Format-IcingaPerfDataValue $value);
            'warning'  = (Format-IcingaPerfDataValue $warning);
            'critical' = (Format-IcingaPerfDataValue $critical);
            'minimum'  = (Format-IcingaPerfDataValue $this.Minimum);
            'maximum'  = (Format-IcingaPerfDataValue $this.Maximum);
            'package'  = $FALSE;
        };
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

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__AddCheckDataToCache' -Value {

        # We only require this in case we are running as daemon
        if ([string]::IsNullOrEmpty($this.__CheckCommand) -Or $global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
            return;
        }

        # If no check table has been created, do nothing
        if ($null -eq $global:Icinga -Or $global:Icinga.ContainsKey('CheckData') -eq $FALSE) {
            return;
        }

        if ($global:Icinga.CheckData.ContainsKey($this.__CheckCommand) -eq $FALSE) {
            return;
        }

        # Fix possible error for identical time stamps due to internal exceptions
        # and check execution within the same time slot because of this
        [string]$TimeIndex = Get-IcingaUnixTime;

        Add-IcingaHashtableItem -Hashtable $global:Icinga.CheckData[$this.__CheckCommand]['results'] -Key $this.Name -Value @{ } | Out-Null;
        Add-IcingaHashtableItem -Hashtable $global:Icinga.CheckData[$this.__CheckCommand]['results'][$this.Name] -Key $TimeIndex -Value $this.Value -Override | Out-Null;
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
            $this.__SetCheckOutput($this.__ThresholdObject.ErrorMessage);
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

        if ($ThresholdObject.InRange -eq $FALSE) {
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
            '-ThresholdCache' = $Global:Icinga.ThresholdCache[$this.__CheckCommand];
            '-Translation'    = $this.Translation;
            '-TimeInterval'   = $this.__TimeInterval;
        };
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnOutOfRange' -Value {
        param ($Threshold);

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfLike' -Value {
        param ($Threshold);

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

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfLike' -Value {
        param ($Threshold);

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

        [string]$Threshold = [string]::Format('{0}:', $Value);

        return $this.WarnOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfLowerThan' -Value {
        param ($Value);

        [string]$Threshold = [string]::Format('{0}:', $Value);

        return $this.CritOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfGreaterThan' -Value {
        param ($Value);

        [string]$Threshold = [string]::Format('~:{0}', $Value);

        return $this.WarnOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfGreaterThan' -Value {
        param ($Value);

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

        #Handles 20
        if ($null -ne $this.__WarningValue.CompareValue -And $null -ne $this.__CriticalValue.CompareValue) {
            if ($this.__WarningValue.CompareValue -gt $this.__CriticalValue.CompareValue) {
                $OutOfRange = $TRUE;
            }
        }

        # Handles:  @30:40 and 30:40
        # Never throw an "error" here, as these ranges can be dynamic
        if ($null -ne $this.__WarningValue.MinRangeValue -And $null -ne $this.__CriticalValue.MinRangeValue -And $null -ne $this.__WarningValue.MaxRangeValue -And $null -ne $this.__CriticalValue.MaxRangeValue) {
            return;
        }

        # Handles:  20:
        if ($null -ne $this.__WarningValue.MinRangeValue -And $null -ne $this.__CriticalValue.MinRangeValue -And $null -eq $this.__WarningValue.MaxRangeValue -And $null -eq $this.__CriticalValue.MaxRangeValue) {
            if ($this.__WarningValue.MinRangeValue -lt $this.__CriticalValue.MinRangeValue) {
                $OutOfRange = $TRUE;
            }
        }

        # Handles:  ~:20
        if ($null -eq $this.__WarningValue.MinRangeValue -And $null -eq $this.__CriticalValue.MinRangeValue -And $null -ne $this.__WarningValue.MaxRangeValue -And $null -ne $this.__CriticalValue.MaxRangeValue) {
            if ($this.__WarningValue.MaxRangeValue -gt $this.__CriticalValue.MaxRangeValue) {
                $OutOfRange = $TRUE;
            }
        }

        if ($OutOfRange) {
            $this.SetUnknown([string]::Format('Warning threshold range "{0}" is greater than Critical threshold range "{1}"', $this.__WarningValue.RawThreshold, $this.__CriticalValue.RawThreshold), $TRUE) | Out-Null;
        }
    }

    $IcingaCheck.__ValidateObject();
    $IcingaCheck.__ValidateUnit();
    $IcingaCheck.__AddCheckDataToCache();
    $IcingaCheck.__SetInternalTimeInterval();
    $IcingaCheck.__ConvertMinMax();

    return $IcingaCheck;
}
