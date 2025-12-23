function Set-IcingaAgentServicePermission()
{
    if (Test-IcingaAgentServicePermission -Silent) {
        Write-IcingaConsoleNotice 'The Icinga Service User already has permission to run as service';
        return;
    }

    $ServiceUser    = Get-IcingaServiceUser;
    $ServiceUserSID = Get-IcingaUserSID $ServiceUser;

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'There is no user assigned to the Icinga 2 service or the service is not yet installed';
        return $FALSE;
    }

    Update-IcingaWindowsUserPermission -SID $ServiceUserSID;

    Test-IcingaAgentServicePermission | Out-Null;
}
