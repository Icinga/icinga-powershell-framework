function Show-IcingaForWindowsManagementConsoleFrameworkExperimental()
{
    $ApiChecks = Get-IcingaFrameworkApiChecks;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows experimental features. Not recommended for production!' `
        -Entries @();
}
