function Test-IcingaForWindowsManagementConsoleHelp()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'h') {
        return $TRUE;
    }

    return $FALSE;
}
