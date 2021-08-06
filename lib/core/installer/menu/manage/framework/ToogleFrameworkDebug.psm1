function Invoke-IcingaForWindowsMangementConsoleToogleFrameworkDebug()
{
    if (Get-IcingaFrameworkDebugMode) {
        Disable-IcingaFrameworkDebugMode;
    } else {
        Enable-IcingaFrameworkDebugMode;
    }
}
