function Test-IcingaForWindowsManagementConsolePrevious()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'p') {
        return $TRUE;
    }

    return $FALSE;
}
