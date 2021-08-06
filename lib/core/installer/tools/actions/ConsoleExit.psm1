function Test-IcingaForWindowsManagementConsoleExit()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'x') {
        return $TRUE;
    }

    return $FALSE;
}
