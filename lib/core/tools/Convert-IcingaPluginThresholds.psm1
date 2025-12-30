<#
.SYNOPSIS
    Converts any kind of Icinga threshold with provided units
    to the lowest base of the unit which makes sense. It does
    support the Icinga plugin language, like ~:30, @10:40, 15:30,
    ...

    The conversion does currently support the following units:

    Size: B, KB, MB, GB, TB, PT, KiB, MiB, GiB, TiB, PiB
    Time: ms, s, m, h, d w, M, y
.DESCRIPTION
    Converts any kind of Icinga threshold with provided units
    to the lowest base of the unit. It does support the Icinga
    plugin language, like ~:30, @10:40, 15:30, ...

    You can also provide date time values in the format of "yyyy/MM/dd HH:mm:ss"
    and use Icinga for Windows plugin thresholds in combination. You have to escape
    the ':' inside the date time value with a '`' to ensure the correct conversion.

    Example:
    2024/08/19 12`:42`:00

    The conversion does currently support the following units:

    Size: B, KB, MB, GB, TB, PT, KiB, MiB, GiB, TiB, PiB
    Time: ms, s, m, h, d w, M, y
.FUNCTIONALITY
    Converts values with units to the lowest unit of this category.
    Accepts Icinga Thresholds.
.PARAMETER Threshold
    The threshold value to convert. Supports Icinga plugin threshold
    syntax.
.PARAMETER RawValue
    If set, the function will return the raw value without any conversion.
    This is required for match/not match checks as example
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '20d';

    Name                           Value
    ----                           -----
    EndRange
    Unit                           s
    StartRange
    Threshold                      1728000
    Mode                           0
    Raw                            20d
    IsDateTime                     False
    Value                          1728000
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '5GB';

    Name                           Value
    ----                           -----
    EndRange
    Unit                           B
    StartRange
    Threshold                      5000000000
    Mode                           0
    Raw                            5GB
    IsDateTime                     False
    Value                          5000000000
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '10MB:20MB';

    Name                           Value
    ----                           -----
    EndRange                       20000000
    Unit                           B
    StartRange                     10000000
    Threshold                      10000000:20000000
    Mode                           3
    Raw                            10MB:20MB
    IsDateTime                     False
    Value
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '10m:1h';

    Name                           Value
    ----                           -----
    EndRange                       3600
    Unit                           s
    StartRange                     600
    Threshold                      600:3600
    Mode                           3
    Raw                            10m:1h
    Value
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '@10m:1h';

    Name                           Value
    ----                           -----
    EndRange                       3600
    Unit                           s
    StartRange                     600
    Threshold                      @600:3600
    Mode                           4
    Raw                            @10m:1h
    IsDateTime                     False
    Value
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '~:1M';

    Name                           Value
    ----                           -----
    EndRange
    Unit                           s
    StartRange
    Threshold                      ~:2592000
    Mode                           2
    Raw                            ~:1M
    IsDateTime                     False
    Value                          2592000
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '@2024/08/19 12`:42`:00:2024/08/19 12`:42`:00';
    Name                           Value
    ----                           -----
    EndRange                       133685377200000000
    Unit                           s
    StartRange                     133685377200000000
    Threshold                      @133685377200000000:133685377200000000
    Mode                           4
    Raw                            @2024/08/19 12`:42`:00:2024/08/19 12`:42`:00
    IsDateTime                     True
    Value
.INPUTS
   System.String
.OUTPUTS
    System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Convert-IcingaPluginThresholds()
{
    param (
        [string]$Threshold = $null,
        [switch]$RawValue  = $false
    );

    [hashtable]$RetValue = @{
        'Raw'        = $Threshold;
        'Unit'       = '';
        'Threshold'  = $null;
        'Value'      = $null;
        'StartRange' = $null;
        'EndRange'   = $null;
        'Mode'       = $IcingaEnums.IcingaThresholdMethod.Default;
        'IsDateTime' = $FALSE;
    };

    # Always ensure Value is set, because we just want the raw value
    if ([string]::IsNullOrEmpty($Threshold) -or $RawValue) {
        $RetValue.Value = $Threshold;

        return $RetValue;
    }

    # Always ensure we are using correct digits
    $Threshold      = $Threshold.Replace(',', '.');
    [array]$Content = @();

    if ($Threshold.Contains(':')) {
        # If we have more than one ':' inside our string, lets check if this is a date time value
        # In case it is convert it properly to a FileTime we can work with later on
        if ([Regex]::Matches($Threshold, '`:').Count -gt 1) {
            [bool]$HasTilde = $FALSE;
            [bool]$HasAt    = $FALSE;

            if ($Threshold.Contains('@')) {
                $HasAt = $TRUE;
            } elseif ($Threshold.Contains('~')) {
                $HasTilde = $TRUE;
            }

            $Threshold               = $Threshold.Replace('`:', '!').Replace('~', '').Replace('@', '');
            [array]$DatimeValueArray = $Threshold.Split(':');

            try {
                [array]$DateTimeValue = @();
                if ([string]::IsNullOrEmpty($DatimeValueArray[0]) -eq $FALSE) {
                    [array]$DateTimeValue += ([DateTime]::ParseExact($DatimeValueArray[0].Replace('!', ':'), 'yyyy\/MM\/dd HH:mm:ss', $null)).ToFileTime();
                }
                if ([string]::IsNullOrEmpty($DatimeValueArray[1]) -eq $FALSE) {
                    [array]$DateTimeValue += ([DateTime]::ParseExact($DatimeValueArray[1].Replace('!', ':'), 'yyyy\/MM\/dd HH:mm:ss', $null)).ToFileTime();
                }

                if ($DateTimeValue.Count -gt 1) {
                    $Threshold     = [string]::Join(':', $DateTimeValue);
                    $RetValue.Mode = $IcingaEnums.IcingaThresholdMethod.Between;

                    if ($HasAt) {
                        $Threshold = [string]::Format('@{0}', $Threshold);
                    }
                } elseif ($DatimeValueArray.Count -gt 1) {
                    if ($HasTilde) {
                        $Threshold = [string]::Format('~:{0}', $DateTimeValue[0]);
                    } else {
                        $Threshold = [string]::Format('{0}:', $DateTimeValue[0]);
                    }
                } else {
                    $Threshold = $DateTimeValue[0];
                }
                $RetValue.Unit = 's';
                $RetValue.IsDateTime = $TRUE;
            } catch {
                $RetValue.Threshold = $Threshold.Replace('!', '`:');
                Exit-IcingaThrowException -CustomMessage ([string]::Format('Could not convert the provided threshold value {0} to a valid Icinga for Windows range', $RetValue.Raw)) -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.InvalidThresholdValue -Force;
                return $RetValue;
            }
        } else {
            $RetValue.Mode  = $IcingaEnums.IcingaThresholdMethod.Between;
        }

        $Content = $Threshold.Split(':');
        if ($Content.Count -eq 2 -And ([string]::IsNullOrEmpty($Content[1]))) {
            $RetValue.Mode  = $IcingaEnums.IcingaThresholdMethod.Lower;
        }
    } else {
        $Content += $Threshold;
    }

    [array]$ConvertedValue = @();

    foreach ($ThresholdValue in $Content) {

        [bool]$HasTilde = $FALSE;
        [bool]$HasAt    = $FALSE;
        [bool]$Negate   = $FALSE;
        $Value          = '';
        $WorkUnit       = '';

        if ($ThresholdValue.Contains('~')) {
            $ThresholdValue = $ThresholdValue.Replace('~', '');
            $HasTilde       = $TRUE;
            $RetValue.Mode  = $IcingaEnums.IcingaThresholdMethod.Greater;
        } elseif ($ThresholdValue.Contains('@')) {
            $HasAt          = $TRUE;
            $ThresholdValue = $ThresholdValue.Replace('@', '');
            $RetValue.Mode  = $IcingaEnums.IcingaThresholdMethod.Outside;
        }

        if ($ThresholdValue[0] -eq '-' -And $ThresholdValue.Length -ge 1) {
            $Negate         = $TRUE;
            $ThresholdValue = $ThresholdValue.Substring(1, $ThresholdValue.Length - 1);
        }

        if (($ThresholdValue -Match "(^-?[0-9]+)((\.|\,)[0-9]+)?(B|KB|MB|GB|TB|PT|KiB|MiB|GiB|TiB|PiB)$")) {
            $WorkUnit = 'B';
            if ([string]::IsNullOrEmpty($RetValue.Unit) -eq $FALSE -And $RetValue.Unit -ne $WorkUnit) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.MultipleUnitUsage -Force;
            }
            $Value         = (Convert-Bytes -Value $ThresholdValue -Unit $WorkUnit).Value;
            $RetValue.Unit = $WorkUnit;
        } elseif (($ThresholdValue -Match "(^-?[0-9]+)((\.|\,)[0-9]+)?(ms|s|m|h|d|w|M|y)$")) {
            $WorkUnit = 's';
            if ([string]::IsNullOrEmpty($RetValue.Unit) -eq $FALSE -And $RetValue.Unit -ne $WorkUnit) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.MultipleUnitUsage -Force;
            }
            $Value         = (ConvertTo-Seconds -Value $ThresholdValue);
            $RetValue.Unit = $WorkUnit;
        } elseif (($ThresholdValue -Match "(^[\d\.]*) ?(%)")) {
            $WorkUnit      = '%';
            $Value         = ([string]$ThresholdValue).Replace(' ', '').Replace('%', '');
            $RetValue.Unit = $WorkUnit;
        } elseif (($ThresholdValue -Match "(^-?[0-9]+)((\.|\,)[0-9]+)?(Kbit|Mbit|Gbit|Tbit|Pbit|Ebit|Zbit|Ybit)$")) {
            $Value         = $Matches[1];
            $RetValue.Unit = $Matches[4];
        } else {
            # Load all other units/values generically
            [string]$StrNumeric = '';
            [bool]$FirstChar    = $TRUE;
            [bool]$Delimiter    = $FALSE;
            foreach ($entry in ([string]($ThresholdValue)).ToCharArray()) {
                if ((Test-Numeric $entry) -Or ($entry -eq '.' -And $Delimiter -eq $FALSE)) {
                    $StrNumeric += $entry;
                    $FirstChar   = $FALSE;
                    if ($entry -eq '.') {
                        $Delimiter = $TRUE;
                    }
                } else {
                    if ([string]::IsNullOrEmpty($RetValue.Unit) -And $FirstChar -eq $FALSE) {
                        $RetValue.Unit = $entry;
                    } else {
                        $StrNumeric    = '';
                        $RetValue.Unit = '';
                        break;
                    }
                }
            }
            if ([string]::IsNullOrEmpty($StrNumeric)) {
                $Value = $ThresholdValue;
            } else {
                $Value = [decimal]$StrNumeric;
            }
        }

        if ((Test-Numeric $Value) -And $Negate) {
            $Value = $Value * -1;
        } elseif ($Negate) {
            $Value = [string]::Format('-{0}', $Value);
        }

        if ($HasTilde) {
            $ConvertedValue += [string]::Format('~{0}', $Value);
        } elseif ($HasAt) {
            $ConvertedValue += [string]::Format('@{0}', $Value);
        } else {
            $ConvertedValue += $Value;
        }
    }

    [string]$Value = [string]::Join(':', $ConvertedValue);

    switch ($RetValue.Mode) {
        $IcingaEnums.IcingaThresholdMethod.Default {
            $RetValue.Value = $ConvertedValue[0];

            if ([string]::IsNullOrEmpty($RetValue.Value)) {
                Exit-IcingaThrowException -CustomMessage ([string]::Format('Could not convert the provided threshold value {0} to a valid Icinga for Windows range', $RetValue.Raw)) -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.InvalidThresholdValue -Force;
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Lower {
            $RetValue.Value = $ConvertedValue[0];

            if ([string]::IsNullOrEmpty($RetValue.Value)) {
                Exit-IcingaThrowException -CustomMessage ([string]::Format('Could not convert the provided threshold value {0} to a valid Icinga for Windows range', $RetValue.Raw)) -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.InvalidThresholdValue -Force;
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Greater {
            $RetValue.Value = $ConvertedValue[1];

            if ([string]::IsNullOrEmpty($RetValue.Value)) {
                Exit-IcingaThrowException -CustomMessage ([string]::Format('Could not convert the provided threshold value {0} to a valid Icinga for Windows range', $RetValue.Raw)) -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.InvalidThresholdValue -Force;
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Between {
            $RetValue.StartRange = [decimal]$ConvertedValue[0];
            $RetValue.EndRange   = [decimal]$ConvertedValue[1];

            if ([string]::IsNullOrEmpty($RetValue.StartRange) -Or [string]::IsNullOrEmpty($RetValue.EndRange)) {
                Exit-IcingaThrowException -CustomMessage ([string]::Format('Could not convert the provided threshold value {0} to a valid Icinga for Windows range', $RetValue.Raw)) -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.InvalidThresholdValue -Force;
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Outside {
            $RetValue.StartRange = [decimal]($ConvertedValue[0].Replace('@', ''));
            $RetValue.EndRange   = [decimal]$ConvertedValue[1];

            if ([string]::IsNullOrEmpty($RetValue.StartRange) -Or [string]::IsNullOrEmpty($RetValue.EndRange)) {
                Exit-IcingaThrowException -CustomMessage ([string]::Format('Could not convert the provided threshold value {0} to a valid Icinga for Windows range', ($RetValue.Raw))) -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.InvalidThresholdValue -Force;
                return $RetValue;
            }
            break;
        };
    }

    if ([string]::IsNullOrEmpty($Value) -eq $FALSE -And $Value.Contains(':') -eq $FALSE) {
        if ((Test-Numeric $Value)) {
            $RetValue.Threshold = [decimal]$Value;
            $RetValue.Value     = [decimal]$Value;
            return $RetValue;
        }
    }

    # Always ensure we are using correct digits
    $Value              = ([string]$Value).Replace(',', '.');
    $RetValue.Threshold = $Value;

    return $RetValue;
}
