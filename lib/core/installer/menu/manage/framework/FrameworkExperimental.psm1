function Show-IcingaForWindowsManagementConsoleFrameworkExperimental()
{
    [array]$Entries = @();

    if ($Entries.Count -ne 0) {
        Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows experimental features. Not recommended for production!' `
        -Entries $Entries;
    } else {
        Show-IcingaForWindowsInstallerMenu `
        -Header 'No experimental features for Icinga for Windows available';
    }
}
