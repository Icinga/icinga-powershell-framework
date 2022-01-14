function Invoke-IcingaForWindowsManagementConsoleToggleFrameworkDebug()
{
    if (Get-IcingaFrameworkDebugMode) {
        Disable-IcingaFrameworkDebugMode;
    } else {
        Enable-IcingaFrameworkDebugMode;
    }
}
