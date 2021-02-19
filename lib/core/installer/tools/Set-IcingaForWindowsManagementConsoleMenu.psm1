function Set-IcingaForWindowsManagementConsoleMenu()
{
    param (
        [string]$Menu
    );

    if ([string]::IsNullOrEmpty($Menu) -Or $Menu -eq 'break') {
        return;
    }

    $global:Icinga.InstallWizard.Menu = (Get-IcingaForWindowsManagementConsoleAlias -Command $Menu);
}
