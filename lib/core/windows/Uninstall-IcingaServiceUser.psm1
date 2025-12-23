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

    # Fetch the current service user and SID
    $ServiceUser    = Get-IcingaServiceUser;
    $ServiceUserSID = Get-IcingaUserSID $ServiceUser;

    Stop-IcingaService 'icinga2';
    Stop-IcingaForWindows;

    Set-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser' -Value '';

    Set-IcingaServiceUser -User 'NT Authority\NetworkService' -Service 'icinga2' | Out-Null;
    Set-IcingaServiceUser -User 'NT Authority\NetworkService' -Service 'icingapowershell' | Out-Null;

    Set-IcingaUserPermissions -IcingaUser $IcingaUser -Remove;
    Update-IcingaWindowsUserPermission -SID $ServiceUserSID -Remove;

    Remove-IcingaWindowsUser -IcingaUser $IcingaUser | Out-Null;

    Restart-IcingaService 'icinga2';
    Restart-IcingaForWindows;

    Write-IcingaConsoleNotice 'User "{0}" including permissions was removed from this host' -Objects $IcingaUser;
}
