function Show-IcingaForWindowsInstallerMenuContinueConfiguration()
{
    $SwapConfig                         = Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap';
    $global:Icinga.InstallWizard.Config = Convert-IcingaForwindowsManagementConsoleJSONConfig -Config $SwapConfig;
    [string]$Menu                       = Get-IcingaForWindowsInstallerLastParent;

    # We don't need the last entry, as this will be added anyways because we are
    # starting right from there and it will be added anyway
    Remove-IcingaForWindowsInstallerLastParent;

    if ($Menu.Contains(':')) {
        $Menu = Get-IcingaForWindowsInstallerLastParent;
    }

    $global:Icinga.InstallWizard.NextCommand = $Menu;
}
