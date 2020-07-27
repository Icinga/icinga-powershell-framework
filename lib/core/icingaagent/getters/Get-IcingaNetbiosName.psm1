function Get-IcingaNetbiosName()
{
    $ComputerData = Get-IcingaWindowsInformation Win32_ComputerSystem;

    return $ComputerData.Name;
}
