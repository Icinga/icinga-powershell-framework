function Test-IcingaForWindowsManagementConsoleDelete()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'd') {
        return $TRUE;
    }

    return $FALSE;
}
