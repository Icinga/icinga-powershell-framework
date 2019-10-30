Import-IcingaLib provider\bios;

<#
.SYNOPSIS
   Finds out the Bios Serial
.DESCRIPTION
   Invoke-IcingaCheckBiosSerial returns either the Bios Serial or nothing.
   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to be used to find out the Bios Serial of a given system
   Either the a Bios Serial is returned or not. Thereby the Check is always okay.
.EXAMPLE
   PS>Invoke-IcingaCheckBiosSerial
   [OK]: SerialNumber is 1234-5678-9101-1121-3141-5161-7100
.OUTPUTS
   System.String
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckBiosSerial()
{
    $Bios      = Get-IcingaBiosSerialNumber;
    $BiosCheck = New-IcingaCheck -Name ([string]::Format('BIOS {0}', $Bios.Name)) -Value $Bios.Value -NoPerfData;
    return (New-IcingaCheckresult -Check $BiosCheck -NoPerfData $TRUE -Compile);
}
