function Get-IcingaNetbiosName()
{
    $ComputerData = Get-WmiObject Win32_ComputerSystem;

    return $ComputerData.Name;
}
