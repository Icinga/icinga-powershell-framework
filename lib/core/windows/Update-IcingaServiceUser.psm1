function Update-IcingaServiceUser()
{
    $IcingaUser = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser';

    if ([string]::IsNullOrEmpty($IcingaUser)) {
        return;
    }

    if ((Test-IcingaManagedUser -IcingaUser $IcingaUser) -eq $FALSE) {
        return;
    }

    $UserConfig = Get-IcingaWindowsUserConfig -UserName $IcingaUser;
    $User       = New-IcingaWindowsUser -IcingaUser $UserConfig.Name;

    Set-IcingaServiceUser -User $IcingaUser -Password $Global:Icinga.ServiceUserPassword -Service 'icinga2' | Out-Null;
    Set-IcingaServiceUser -User $IcingaUser -Password $Global:Icinga.ServiceUserPassword -Service 'icingapowershell' | Out-Null;

    Restart-IcingaService 'icinga2';
    Restart-IcingaWindowsService;
}
