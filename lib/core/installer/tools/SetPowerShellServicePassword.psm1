function Set-IcingaInternalPowerShellServicePassword()
{
    param (
        [SecureString]$Password = $null
    );

    if ($null -eq $global:Icinga) {
        $Global:Icinga = @{
            'InstallerServicePassword' = $Password;
        }

        return;
    }

    if ($Global:Icinga.ContainsKey('InstallerServicePassword') -eq $FALSE) {
        $Global:Icinga.Add(
            'InstallerServicePassword',
            $Password
        )

        return;
    }

    $Global:Icinga.InstallerServicePassword = $Password;
}
