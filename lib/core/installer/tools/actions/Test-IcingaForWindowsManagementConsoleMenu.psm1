function Test-IcingaForWindowsManagementConsoleMenu()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'm') {
        return $TRUE;
    }

    return $FALSE;
}
