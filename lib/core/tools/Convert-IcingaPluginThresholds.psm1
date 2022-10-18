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

    The conversion does currently support the following units:

    Size: B, KB, MB, GB, TB, PT, KiB, MiB, GiB, TiB, PiB
    Time: ms, s, m, h, d w, M, y
.FUNCTIONALITY
    Converts values with units to the lowest unit of this category.
    Accepts Icinga Thresholds.
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '20d';

    Name                           Value
    ----                           -----
    Value                          1728000
    Unit                           s
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '5GB';

    Name                           Value
    ----                           -----
    Value                          5000000000
    Unit                           B
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '10MB:20MB';

    Name                           Value
    ----                           -----
    Value                          10000000:20000000
    Unit                           B
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '10m:1h';

    Name                           Value
    ----                           -----
    Value                          600:3600
    Unit                           s
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '@10m:1h';

    Name                           Value
    ----                           -----
    Value                          @600:3600
    Unit                           s
.EXAMPLE
    Convert-IcingaPluginThresholds -Threshold '~:1M';

    Name                           Value
    ----                           -----
    Value                          ~:2592000
    Unit                           s
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
        [string]$Threshold = $null
    );

    [hashtable]$RetValue = @{
        'Unit'  = '';
        'Value' =  $null;
    };

    if ($null -eq $Threshold) {
        return $RetValue;
    }

    # Always ensure we are using correct digits
    $Threshold = $Threshold.Replace(',', '.');

    [array]$Content    = @();

    if ($Threshold.Contains(':')) {
        # If we have more than one ':' inside our string, lets check if this is a date time value
        # In case it is convert it properly to a FileTime we can work with later on
        if ([Regex]::Matches($Threshold, ":").Count -gt 1) {
            try {
                $DateTimeValue  = [DateTime]::ParseExact($Threshold, 'yyyy\/MM\/dd HH:mm:ss', $null);
                $RetValue.Value = $DateTimeValue.ToFileTime();
                $RetValue.Unit  = 's';
            } catch {
                $RetValue.Value = $Threshold;
            }

            return $RetValue;
        }

        $Content = $Threshold.Split(':');
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
            $HasTilde = $TRUE;
        } elseif ($ThresholdValue.Contains('@')) {
            $HasAt = $TRUE;
            $ThresholdValue = $ThresholdValue.Replace('@', '');
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

    if ([string]::IsNullOrEmpty($Value) -eq $FALSE -And $Value.Contains(':') -eq $FALSE) {
        if ((Test-Numeric $Value)) {
            $RetValue.Value = [decimal]$Value;
            return $RetValue;
        }
    }

    # Always ensure we are using correct digits
    $Value          = ([string]$Value).Replace(',', '.');
    $RetValue.Value = $Value;

    return $RetValue;
}
