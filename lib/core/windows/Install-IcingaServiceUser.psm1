function Install-IcingaServiceUser()
{
    param (
        $IcingaUser = 'icinga'
    );

    if ([string]::IsNullOrEmpty($IcingaUser)) {
        Write-IcingaConsoleError 'The provided user cannot be empty.';
        return;
    }

    Write-IcingaConsoleNotice 'Installing user "{0}"' -Objects $IcingaUser;

    $User = New-IcingaWindowsUser -IcingaUser $IcingaUser;

    Start-Sleep -Seconds 2;

    Set-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser' -Value $User.User;

    Set-IcingaServiceUser -User $IcingaUser -Password $Global:Icinga.ServiceUserPassword -Service 'icinga2' | Out-Null;
    Set-IcingaServiceUser -User $IcingaUser -Password $Global:Icinga.ServiceUserPassword -Service 'icingapowershell' | Out-Null;

    Update-IcingaWindowsUserPermission -SID $User.SID;

    Set-IcingaUserPermissions -IcingaUser $IcingaUser;

    Restart-IcingaService 'icinga2';
    Restart-IcingaWindowsService;

    Clear-IcingaWindowsUserPassword;

    Write-IcingaConsoleNotice 'User "{0}" including permissions was successfully installed on this host' -Objects $IcingaUser;
}
