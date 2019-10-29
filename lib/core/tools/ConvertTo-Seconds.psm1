Import-IcingaLib core\tools;

<#
.SYNOPSIS
   Converts unit to seconds.
.DESCRIPTION
   This module converts a given time unit to seconds.
   e.g hours to seconds.

   More Information on https://github.com/LordHepipud/icinga-module-windows

.PARAMETER Value
   Specify unit to be converted to seconds. Allowed units: ms, s, m, h, d, w, M, y
   ms = miliseconds; s = seconds; m = minutes; h = hours; d = days; w = weeks; M = months; y = years;

   Like 20d for 20 days.
.EXAMPLE
   PS> ConvertTo-Seconds 30d
   2592000
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function ConvertTo-Seconds()
{
    param(
        [string]$Value
    );

    if ([string]::IsNullOrEmpty($Value)) {
        return $Value;
    }

    [string]$NumberPart = '';
    [string]$UnitPart   = '';
    [bool]$Negate       = $FALSE;
    [bool]$hasUnit      = $FALSE;

    foreach($char in $Value.ToCharArray()) {
        if ((Test-Numeric $char)) {
            $NumberPart += $char;
        } else {
            if ($char -eq '-') {
                $Negate = $TRUE;
            } elseif ($char -eq '.' -Or $char -eq ',') {
                $NumberPart += '.';
            } else {
                $UnitPart += $char;
                $hasUnit = $TRUE;
            }
        }
    }

    if (-Not $hasUnit) {
        return $Value;
    }

    [single]$ValueSplitted = $NumberPart;
    $result             = 0;

    if ($Negate) {
        $ValueSplitted *= -1;
    }

    [string]$errorMsg   = (
        [string]::Format('Invalid unit type "{0}" specified for convertion. Allowed units: ms, s, m, h, d, w, M, y', $UnitPart)
    );

    if ($UnitPart -Match 'ms') {
        $result = ($ValueSplitted / [math]::Pow(10, 3));
    } else {
        if ($UnitPart.Length -gt 1) {
            Throw $errorMsg;
        }

        switch ([int][char]$UnitPart) {
            { 115 -contains $_ } { $result = $ValueSplitted; break; } # s
            { 109 -contains $_ } { $result = $ValueSplitted * 60; break; } # m
            { 104 -contains $_ } { $result = $ValueSplitted * 3600; break; } # h
            { 100 -contains $_ } { $result = $ValueSplitted * 86400; break; } # d
            { 119 -contains $_ } { $result = $ValueSplitted * 604800; break; } # w
            { 77  -contains $_ } { $result = $ValueSplitted * 2592000; break; } # M
            { 121 -contains $_ } { $result = $ValueSplitted * 31536000; break; } # y
            default { 
                Throw $errorMsg;
                break;
            }
        }
    }

    return $result;
}

function ConvertTo-SecondsFromIcingaThresholds()
{
    param(
        [string]$Threshold
    );

    [array]$Content    = $Threshold.Split(':');
    [array]$NewContent = @();

    foreach ($entry in $Content) {
        $NewContent += (Get-IcingaThresholdsAsSeconds -Value $entry)
    }

    return [string]::Join(':', $NewContent);
}

function Get-IcingaThresholdsAsSeconds()
{
    param(
        [string]$Value
    );

    if ($Value.Contains('~')) {
        $Value = $Value.Replace('~', '');
        return [string]::Format('~{0}', (ConvertTo-Seconds $Value));
    } elseif ($Value.Contains('@')) {
        $Value = $Value.Replace('@', '');
        return [string]::Format('@{0}', (ConvertTo-Seconds $Value));
    }

    return (ConvertTo-Seconds $Value);
}

Export-ModuleMember -Function @( 'ConvertTo-Seconds', 'ConvertTo-SecondsFromIcingaThresholds' );
