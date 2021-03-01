function Add-IcingaForWindowsManagementConsoleLastParent()
{
    $Menu = Get-IcingaForWindowsManagementConsoleAlias -Command (Get-IcingaForWindowsManagementConsoleMenu);

    if ($Menu -eq (Get-IcingaForWindowsInstallerLastParent)) {
        return;
    }

    # Do not add Yes/No Dialog to the list
    if ($Menu -eq 'Show-IcingaWindowsManagementConsoleYesNoDialog') {
        return;
    }

    $global:Icinga.InstallWizard.LastParent.Add($Menu) | Out-Null;
}
