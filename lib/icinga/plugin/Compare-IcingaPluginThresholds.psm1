function Compare-IcingaPluginThresholds()
{
    param (
        [string]$Threshold      = $null,
        $InputValue             = $null,
        $BaseValue              = $null,
        [switch]$Matches        = $FALSE,
        [switch]$NotMatches     = $FALSE,
        [string]$Unit           = '',
        $ThresholdCache         = $null,
        [string]$CheckName      = '',
        [hashtable]$Translation = @{ },
        $Minium                 = $null,
        $Maximum                = $null,
        [switch]$IsBetween      = $FALSE,
        [switch]$IsLowerEqual   = $FALSE,
        [switch]$IsGreaterEqual = $FALSE,
        [string]$TimeInterval   = $null
    );

    $IcingaThresholds = New-Object -TypeName PSObject;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Value'           -Value $InputValue;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'BaseValue'       -Value $BaseValue;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'RawValue'        -Value $InputValue;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Unit'            -Value $Unit;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'OriginalUnit'    -Value $Unit;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'PerfUnit'        -Value $Unit;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'IcingaThreshold' -Value $Threshold;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'RawThreshold'    -Value $Threshold;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'CompareValue'    -Value $null;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'MinRangeValue'   -Value $null;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'MaxRangeValue'   -Value $null;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'PercentValue'    -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'TimeSpan'        -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'InRange'         -Value $TRUE;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Message'         -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Range'           -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'FullMessage'     -Value (
        [string]::Format('{0}', (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $Unit -Value $InputValue)))
    );
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'HeaderValue'     -Value $IcingaThresholds.FullMessage;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'ErrorMessage'    -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'HasError'        -Value $FALSE;

    # In case we are using % values, we should set the BaseValue always to 100
    if ($Unit -eq '%' -And $null -eq $BaseValue) {
        $BaseValue = 100;
    }

    if ([string]::IsNullOrEmpty($TimeInterval) -eq $FALSE -And $null -ne $ThresholdCache) {
        $TimeSeconds        = ConvertTo-Seconds $TimeInterval;
        $MinuteInterval     = ([TimeSpan]::FromSeconds($TimeSeconds)).Minutes;
        $CheckPerfDataLabel = [string]::Format('{0}_{1}', (Format-IcingaPerfDataLabel $CheckName), $MinuteInterval);

        if ($null -ne $ThresholdCache.$CheckPerfDataLabel) {
            $InputValue                = $ThresholdCache.$CheckPerfDataLabel;
            $InputValue                = [math]::round([decimal]$InputValue, 6);
            $IcingaThresholds.TimeSpan = $MinuteInterval;
        } else {
            $IcingaThresholds.HasError     = $TRUE;
            $IcingaThresholds.ErrorMessage = [string]::Format(
                'The provided time interval "{0}" which translates to "{1}m" in your "-ThresholdInterval" argument does not exist',
                $TimeInterval,
                $MinuteInterval
            );
        }
    } <#else {
        # The symbol splitting our threshold from the time index value
        # Examples:
        # @20:40#15m
        # ~:40#15m
        # 40#15m
        $TimeIndexSeparator = '#';

        # In case we found a ~ not starting at the beginning, we should load the
        # time index values created by our background daemon
        # Allows us to specify something like "40:50#15"
        if ($Threshold.Contains($TimeIndexSeparator) -And $null -ne $ThresholdCache) {
            [int]$LastIndex = $Threshold.LastIndexOf($TimeIndexSeparator);
            if ($LastIndex -ne 0) {
                $TmpValue       = $Threshold;
                $Threshold      = $TmpValue.Substring(0, $LastIndex);
                $TimeIndex      = $TmpValue.Substring($LastIndex + 1, $TmpValue.Length - $LastIndex - 1);
                $TimeSeconds    = ConvertTo-Seconds $TimeIndex;
                $MinuteInterval = ([TimeSpan]::FromSeconds($TimeSeconds)).Minutes;

                $CheckPerfDataLabel = [string]::Format('{0}_{1}', (Format-IcingaPerfDataLabel $CheckName), $MinuteInterval);

                if ($null -ne $ThresholdCache.$CheckPerfDataLabel) {
                    $InputValue                = $ThresholdCache.$CheckPerfDataLabel;
                    $InputValue                = [math]::round([decimal]$InputValue, 6);
                    $IcingaThresholds.TimeSpan = $MinuteInterval;
                } else {
                    $IcingaThresholds.HasError     = $TRUE;
                    $IcingaThresholds.ErrorMessage = [string]::Format(
                        'The provided time interval "{0}{1}" which translates to "{2}m" in your "-ThresholdInterval" argument does not exist',
                        $TimeIndexSeparator,
                        $TimeIndex,
                        $MinuteInterval
                    );
                }
            }
        }
    }#>

    [bool]$UseDynamicPercentage       = $FALSE;
    [hashtable]$ConvertedThreshold    = Convert-IcingaPluginThresholds -Threshold $Threshold;
    $Minimum                          = (Convert-IcingaPluginThresholds -Threshold $Minimum).Value;
    $Maximum                          = (Convert-IcingaPluginThresholds -Threshold $Maximum).Value;
    [string]$ThresholdValue           = $ConvertedThreshold.Value;
    $IcingaThresholds.Unit            = $ConvertedThreshold.Unit;
    $IcingaThresholds.IcingaThreshold = $ThresholdValue;
    $TempValue                        = (Convert-IcingaPluginThresholds -Threshold ([string]::Format('{0}{1}', $InputValue, $Unit)));
    $InputValue                       = $TempValue.Value;
    $TmpUnit                          = $TempValue.Unit;

    if (Test-Numeric $InputValue) {
        [decimal]$InputValue = [decimal]$InputValue;
    }

    $IcingaThresholds.RawValue        = $InputValue;
    $TempValue                        = (Convert-IcingaPluginThresholds -Threshold ([string]::Format('{0}{1}', $BaseValue, $Unit)));
    $BaseValue                        = $TempValue.Value;
    $Unit                             = $TmpUnit;
    $IcingaThresholds.PerfUnit        = $Unit;
    $IcingaThresholds.BaseValue       = $BaseValue;

    if ([string]::IsNullOrEmpty($IcingaThresholds.Unit)) {
        $IcingaThresholds.Unit = $Unit;
    }

    # Calculate % value from base value of set
    if ($null -ne $BaseValue -And $IcingaThresholds.Unit -eq '%') {
        $InputValue           = $InputValue / $BaseValue * 100;
        $UseDynamicPercentage = $TRUE;
    } elseif ($null -eq $BaseValue -And $IcingaThresholds.Unit -eq '%') {
        $IcingaThresholds.HasError = $TRUE;
        $IcingaThresholds.ErrorMessage = 'This argument does not support the % unit';
    }

    # Always override our InputValue, case we might have change it
    $IcingaThresholds.Value = $InputValue;

    # If we simply provide a numeric number, we always check Value > Threshold or Value < 0
    if ($Matches) {
        # Checks if the InputValue Matches the Threshold
        if ($InputValue -Like $ThresholdValue) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is matching threshold';
            $IcingaThresholds.Range   = [string]::Format(
                '{0}{1}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value $ThresholdValue),
                $IcingaThresholds.Unit
            );
        }
    } elseif ($NotMatches) {
        # Checks if the InputValue not Matches the Threshold
        if ($InputValue -NotLike $ThresholdValue) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is not matching threshold';
            $IcingaThresholds.Range   = [string]::Format(
                '{0}{1}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value $ThresholdValue),
                $IcingaThresholds.Unit
            );
        }
    } elseif ($IsBetween) {
        if ($InputValue -gt $Minium -And $InputValue -lt $Maximum) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is inside range';
            $IcingaThresholds.Range   = [string]::Format(
                '{0} and {1}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $Minium -OriginalUnit $IcingaThresholds.OriginalUnit)),
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $Maximum -OriginalUnit $IcingaThresholds.OriginalUnit))
            );
        }

        if ($IcingaThresholds.Unit -eq '%') {
            $IcingaThresholds.RawThreshold = [string]::Format(
                '{0}% ({2}) {1}% ({3})',
                (ConvertFrom-Percent -Value $BaseValue -Percent $Minium),
                (ConvertFrom-Percent -Value $BaseValue -Percent $Maximum),
                (Convert-IcingaPluginValueToString -Unit $Unit -Value $Minium -OriginalUnit $IcingaThresholds.OriginalUnit),
                (Convert-IcingaPluginValueToString -Unit $Unit -Value $Maximum -OriginalUnit $IcingaThresholds.OriginalUnit)
            );
            $IcingaThresholds.PercentValue = [string]::Format(
                '@{0}:{1}',
                (ConvertFrom-Percent -Value $BaseValue -Percent $Minium),
                (ConvertFrom-Percent -Value $BaseValue -Percent $Maximum)
            );
        }
    } elseif ($IsLowerEqual) {
        if ($InputValue -le $ThresholdValue) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is lower equal than threshold';
            $IcingaThresholds.Range   = [string]::Format(
                '{0}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit))
            );
        }

        if ($IcingaThresholds.Unit -eq '%') {
            $IcingaThresholds.RawThreshold = [string]::Format(
                '{0}% ({1})',
                (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue),
                (Convert-IcingaPluginValueToString -Unit $Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit)
            );
            $IcingaThresholds.PercentValue = [string]::Format(
                '{0}:',
                (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue)
            );
        }
    } elseif ($IsGreaterEqual) {
        if ($InputValue -ge $ThresholdValue) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is greater equal than threshold';
            $IcingaThresholds.Range   = [string]::Format(
                '{0}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit))
            );
        }

        if ($IcingaThresholds.Unit -eq '%') {
            $IcingaThresholds.RawThreshold = [string]::Format(
                '{0}% ({1})',
                (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue),
                (Convert-IcingaPluginValueToString -Unit $Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit)
            );

            $IcingaThresholds.PercentValue = [string]::Format(
                '~:{0}',
                (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue)
            );
        }
    } else {
        if ((Test-Numeric $ThresholdValue)) {
            if ($InputValue -gt $ThresholdValue -Or $InputValue -lt 0) {
                $IcingaThresholds.InRange = $FALSE;
                $IcingaThresholds.Message = 'is greater than threshold';
                $IcingaThresholds.Range   = [string]::Format('{0}', (Convert-IcingaPluginValueToString -Unit $Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit));
            }

            $IcingaThresholds.CompareValue = [decimal]$ThresholdValue;

            if ($IcingaThresholds.Unit -eq '%') {
                $IcingaThresholds.RawThreshold = [string]::Format('{0}% ({1})', $ThresholdValue, (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue) -OriginalUnit $IcingaThresholds.OriginalUnit));

                $IcingaThresholds.PercentValue = [string]::Format(
                    '{0}',
                    (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue)
                );
            }
        } else {
            # Transform our provided thresholds to split everything into single objects
            [array]$thresholds = $ThresholdValue.Split(':');
            [string]$rangeMin  = $thresholds[0];
            [string]$rangeMax  = $thresholds[1];
            [bool]$IsNegating  = $rangeMin.Contains('@');
            [string]$rangeMin  = $rangeMin.Replace('@', '');

            if ((Test-Numeric ($rangeMin.Replace('@', '').Replace('~', '')))) {
                $IcingaThresholds.MinRangeValue = [decimal]($rangeMin.Replace('@', '').Replace('~', ''));
                [decimal]$rangeMin = [decimal]$rangeMin;
            }
            if ((Test-Numeric $rangeMax)) {
                $IcingaThresholds.MaxRangeValue = [decimal]$rangeMax;
                [decimal]$rangeMax = [decimal]$rangeMax;
            }

            if ($IsNegating -eq $FALSE -And (Test-Numeric $rangeMin) -And (Test-Numeric $rangeMax)) {
                # Handles:  30:40
                # Error on: < 30 or > 40
                # Ok on:    between {30 .. 40}

                if ($InputValue -lt $rangeMin -Or $InputValue -gt $rangeMax) {
                    $IcingaThresholds.InRange = $FALSE;
                    $IcingaThresholds.Message = 'is outside range';
                    $IcingaThresholds.Range   = [string]::Format(
                        '{0} and {1}',
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit)),
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );
                }

                if ($IcingaThresholds.Unit -eq '%') {
                    $IcingaThresholds.RawThreshold = [string]::Format(
                        '{0}% ({2}) and {1}% ({3})',
                        $rangeMin,
                        $rangeMax,
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit)),
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );

                    $IcingaThresholds.PercentValue = [string]::Format(
                        '{0}:{1}',
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin),
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax)
                    );
                }
            } elseif ((Test-Numeric $rangeMin) -And [string]::IsNullOrEmpty($rangeMax) -eq $TRUE) {
                # Handles:  20:
                # Error on: 20:
                # Ok on:    between 20 .. ∞

                if ($InputValue -lt $rangeMin) {
                    $IcingaThresholds.InRange = $FALSE;
                    $IcingaThresholds.Message = 'is lower than threshold';
                    $IcingaThresholds.Range   = [string]::Format(
                        '{0}',
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );
                }

                if ($IcingaThresholds.Unit -eq '%') {
                    $IcingaThresholds.RawThreshold = [string]::Format(
                        '{0}% ({1})',
                        $rangeMin,
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );

                    $IcingaThresholds.PercentValue = [string]::Format(
                        '{0}:',
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin)
                    );
                }
            } elseif ($rangeMin -eq '~' -And (Test-Numeric $rangeMax)) {
                # Handles:  ~:20
                # Error on: > 20
                # Ok on:    between -∞ .. 20

                if ($InputValue -gt $rangeMax) {
                    $IcingaThresholds.InRange = $FALSE;
                    $IcingaThresholds.Message = 'is greater than threshold';
                    $IcingaThresholds.Range   = [string]::Format(
                        '{0}',
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );
                }

                if ($IcingaThresholds.Unit -eq '%') {
                    $IcingaThresholds.RawThreshold = [string]::Format(
                        '{0}% ({1})',
                        $rangeMax,
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );

                    $IcingaThresholds.PercentValue = [string]::Format(
                        '~:{0}',
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax)
                    );
                }
            } elseif ($IsNegating -And (Test-Numeric $rangeMin) -And (Test-Numeric $rangeMax)) {
                # Handles:  @30:40
                # Error on: ≥ 30 and ≤ 40
                # Ok on:    -∞ .. 29 and 41 .. ∞

                if ($InputValue -ge $rangeMin -And $InputValue -le $rangeMax) {
                    $IcingaThresholds.InRange = $FALSE;
                    $IcingaThresholds.Message = 'is inside range';
                    $IcingaThresholds.Range   = [string]::Format(
                        '{0} and {1}',
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit)),
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );
                }

                if ($IcingaThresholds.Unit -eq '%') {
                    $IcingaThresholds.RawThreshold = [string]::Format(
                        '{0}% ({2}) {1}% ({3})',
                        $rangeMin,
                        $rangeMax,
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit)),
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );

                    $IcingaThresholds.PercentValue = [string]::Format(
                        '@{0}:{1}',
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin),
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax)
                    );
                }
            } else {
                if ([string]::IsNullOrEmpty($Threshold) -eq $FALSE) {
                    # Unhandled
                    $IcingaThresholds.ErrorMessage = [string]::Format(
                        'Invalid range specified for threshold: InputValue "{0}" and Threshold {1}',
                        $InputValue,
                        $Threshold
                    );
                    $IcingaThresholds.HasError = $TRUE;
                }
            }
        }
    }

    $PluginOutputMessage = [System.Text.StringBuilder]::New();

    [string]$PluginCurrentValue = [string]::Format(
        '{0}',
        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $IcingaThresholds.Value -OriginalUnit $IcingaThresholds.OriginalUnit))
    );

    [string]$PluginThresholdValue = $IcingaThresholds.Range;

    if ($UseDynamicPercentage -And $Unit -ne '%') {
        $IcingaThresholds.IcingaThreshold = $IcingaThresholds.PercentValue;
        $PluginCurrentValue       = [string]::Format('{0}% ({1})', ([math]::Round($IcingaThresholds.Value, 2)), (Convert-IcingaPluginValueToString -Unit $Unit -Value $IcingaThresholds.RawValue -OriginalUnit $IcingaThresholds.OriginalUnit));
        $PluginThresholdValue     = $IcingaThresholds.RawThreshold;
    }

    $IcingaThresholds.HeaderValue = $PluginCurrentValue;
    $PluginOutputMessage.Append($PluginCurrentValue) | Out-Null;

    if ([string]::IsNullOrEmpty($IcingaThresholds.Message) -eq $FALSE) {
        $PluginOutputMessage.Append(' ') | Out-Null;
        $PluginOutputMessage.Append($IcingaThresholds.Message) | Out-Null;

        if ([string]::IsNullOrEmpty($PluginThresholdValue) -eq $FALSE) {
            $PluginOutputMessage.Append(' ') | Out-Null;
            $PluginOutputMessage.Append($PluginThresholdValue) | Out-Null;
        }
    }

    # Lets build our full message for adding on the value
    $IcingaThresholds.FullMessage = $PluginOutputMessage.ToString();

    return $IcingaThresholds;
}
