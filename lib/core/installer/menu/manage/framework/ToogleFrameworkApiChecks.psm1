function Invoke-IcingaForWindowsManagementConsoleToggleFrameworkApiChecks()
{
    if (Get-IcingaFrameworkApiChecks) {
        Disable-IcingaFrameworkApiChecks;
    } else {
        Enable-IcingaFrameworkApiChecks;
    }
}
