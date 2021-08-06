function Remove-IcingaForWindowsInstallerConfigEntry()
{
    param (
        [string]$Menu,
        [string]$Parent
    );

    $Menu = Get-IcingaForWindowsManagementConsoleAlias -Command $Menu;

    if ([string]::IsNullOrEmpty($Parent) -eq $FALSE) {
        $Menu = [string]::Format('{0}:{1}', $Menu, $Parent);
    }

    if ($global:Icinga.InstallWizard.Config.ContainsKey($Menu)) {
        $global:Icinga.InstallWizard.Config.Remove($Menu);
    }

    Write-IcingaforWindowsManagementConsoleConfigSwap -Config $global:Icinga.InstallWizard.Config;
}
