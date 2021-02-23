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
        $Content = $Threshold.Split(':');
    } else {
        $Content += $Threshold;
    }

    [array]$ConvertedValue = @();

    foreach ($ThresholdValue in $Content) {

        [bool]$HasTilde = $FALSE;
        [bool]$HasAt    = $FALSE;
        $Value          = '';
        $WorkUnit       = '';

        if ($ThresholdValue.Contains('~')) {
            $ThresholdValue = $ThresholdValue.Replace('~', '');
            $HasTilde = $TRUE;
        } elseif ($ThresholdValue.Contains('@')) {
            $HasAt = $TRUE;
            $ThresholdValue = $ThresholdValue.Replace('@', '');
        }

        If (($ThresholdValue -Match "(^[\d\.]*) ?(B|KB|MB|GB|TB|PT|KiB|MiB|GiB|TiB|PiB)")) {
            $WorkUnit = 'B';
            if ([string]::IsNullOrEmpty($RetValue.Unit) -eq $FALSE -And $RetValue.Unit -ne $WorkUnit) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.MultipleUnitUsage -Force;
            }
            $Value         = (Convert-Bytes -Value $ThresholdValue -Unit $WorkUnit).Value;
            $RetValue.Unit = $WorkUnit;
        } elseif (($ThresholdValue -Match "(^[\d\.]*) ?(ms|s|m|h|d|w|M|y)")) {
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
        } else {
            $Value = $ThresholdValue;
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
            $RetValue.Value = $Value;
            return $RetValue;
        }
    }

    # Always ensure we are using correct digits
    $Value = ([string]$Value).Replace(',', '.');
    $RetValue.Value = $Value;

    return $RetValue;
}
