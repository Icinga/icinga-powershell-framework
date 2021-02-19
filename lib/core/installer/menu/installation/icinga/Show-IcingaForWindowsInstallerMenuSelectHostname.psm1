function Show-IcingaForWindowsInstallerMenuSelectHostname()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '1',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'How is your host object named in Icinga?' `
        -Entries @(
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (current)', (Get-IcingaHostname -AutoUseFQDN 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and not modify the name at all';
            },
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (lowercase)', (Get-IcingaHostname -AutoUseFQDN 1 -LowerCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and modify all characters to lowercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (uppercase)', (Get-IcingaHostname -AutoUseFQDN 1 -UpperCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and modify all characters to uppercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (current)', (Get-IcingaHostname -AutoUseHostname 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension without modification';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (lowercase)', (Get-IcingaHostname -AutoUseHostname 1 -LowerCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension and modify all characters to lowercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (uppercase)', (Get-IcingaHostname -AutoUseHostname 1 -UpperCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension and modify all characters to uppercase';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-Hostname' -Value 'Show-IcingaForWindowsInstallerMenuSelectHostname';
