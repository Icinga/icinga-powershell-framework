function Test-IcingaForWindowsManagementConsoleContinue()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'c') {
        return $TRUE;
    }

    return $FALSE;
}
