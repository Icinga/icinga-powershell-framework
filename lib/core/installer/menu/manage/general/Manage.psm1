function Show-IcingaForWindowsMenuManage()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows:' `
        -Entries @(
            @{
                'Caption'  = 'Icinga Agent';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to manage the installed Icinga Agent';
                'Disabled' = (-Not ([bool](Get-Service 'icinga2' -ErrorAction SilentlyContinue)));
            },
            @{
                'Caption' = 'Icinga PowerShell Framework';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'    = 'Allows you to modify certain settings for the Icinga PowerShell Framework and to register background daemons';
            }<#,
            @{
                'Caption' = 'Health Check';
                'Command' = '';
                'Help'    = 'Check the current health and status information of your installation';
            }#>
        );
}
