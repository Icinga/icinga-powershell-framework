function Invoke-IcingaForWindowsMangementConsoleToogleFrameworkApiChecks()
{
    if (Get-IcingaFrameworkApiChecks) {
        Disable-IcingaFrameworkApiChecks;
    } else {
        Enable-IcingaFrameworkApiChecks;
    }
}
