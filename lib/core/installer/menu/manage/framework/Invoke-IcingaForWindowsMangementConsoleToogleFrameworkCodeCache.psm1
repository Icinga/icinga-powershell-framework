function Invoke-IcingaForWindowsMangementConsoleToogleFrameworkCodeCache()
{
    if (Get-IcingaFrameworkCodeCache) {
        Disable-IcingaFrameworkCodeCache;
    } else {
        Enable-IcingaFrameworkCodeCache;
        Write-IcingaFrameworkCodeCache;
    }
}
