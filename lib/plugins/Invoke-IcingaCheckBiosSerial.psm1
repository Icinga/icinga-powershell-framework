Import-IcingaLib provider\bios;

function Invoke-IcingaCheckBiosSerial()
{
    $Bios      = Get-IcingaBiosSerialNumber;
    $BiosCheck = New-IcingaCheck -Name $Bios.Name -Value $Bios.Value -NoPerfData;
    exit (New-IcingaCheckresult -Check $BiosCheck -NoPerfData $TRUE -Compile);
}
