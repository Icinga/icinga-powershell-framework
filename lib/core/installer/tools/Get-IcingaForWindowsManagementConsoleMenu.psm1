function Get-IcingaForWindowsManagementConsoleMenu()
{
    if ($null -eq $global:Icinga -Or $null -eq $global:Icinga.InstallWizard) {
        return '';
    }

    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.Menu) -Or $global:Icinga.InstallWizard.Menu -eq 'break') {
        return '';
    }

    return (Get-IcingaForWindowsManagementConsoleAlias -Command $global:Icinga.InstallWizard.Menu);
}
