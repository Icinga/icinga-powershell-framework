function Show-IcingaForWindowsMenuListEnvironment()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'Icinga for Windows environment overview:' `
        -Entries @(
            @{
                'Caption' = '';
                'Command' = 'Install-Icinga';
                'Help'    = 'A summary of your current Icinga for Windows installation';
            }
        ) `
        -AddConfig `
        -DefaultValues @(([string]::Join("`n", (Show-Icinga -SkipHeader)))) `
        -ConfigLimit 1 `
        -DefaultIndex 'c' `
        -ReadOnly `
        -PlainTextOutput `
        -Hidden;
}
