function Uninstall-IcingaServiceUser()
{
    param (
        $IcingaUser = 'icinga'
    );

    if ([string]::IsNullOrEmpty($IcingaUser)) {
        Write-IcingaConsoleError 'The provided user cannot be empty.';
        return;
    }

    Write-IcingaConsoleNotice 'Uninstalling user "{0}"' -Objects $IcingaUser;

    Stop-IcingaService 'icinga2';
    Stop-IcingaWindowsService;

    Set-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser' -Value '';

    Set-IcingaServiceUser -User 'NT Authority\NetworkService' -Service 'icinga2' | Out-Null;
    Set-IcingaServiceUser -User 'NT Authority\NetworkService' -Service 'icingapowershell' | Out-Null;

    Set-IcingaUserPermissions -IcingaUser $IcingaUser -Remove;

    $UserConfig = Remove-IcingaWindowsUser -IcingaUser $IcingaUser;

    if ($null -ne $UserConfig -And ([string]::IsNullOrEmpty($UserConfig.SID) -eq $FALSE)) {
        Update-IcingaWindowsUserPermission -SID $UserConfig.SID -Remove;
    }

    Restart-IcingaService 'icinga2';
    Restart-IcingaWindowsService;

    Write-IcingaConsoleNotice 'User "{0}" including permissions was removed from this host' -Objects $IcingaUser;
}
