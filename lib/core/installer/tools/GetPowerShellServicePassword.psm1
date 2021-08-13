function Get-IcingaInternalPowerShellServicePassword()
{
    if ($null -eq $global:Icinga -Or $Global:Icinga.ContainsKey('InstallerServicePassword') -eq $FALSE) {
        return $null;
    }

    return $Global:Icinga.InstallerServicePassword;
}
