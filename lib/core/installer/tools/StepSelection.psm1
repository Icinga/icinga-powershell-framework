function Get-IcingaForWindowsInstallerStepSelection()
{
    param (
        [string]$InstallerStep
    );

    if ([string]::IsNullOrEmpty($InstallerStep)) {
        $InstallerStep = Get-IcingaForWindowsManagementConsoleMenu;
    } else {
        $InstallerStep = Get-IcingaForWindowsManagementConsoleAlias -Command $InstallerStep;
    }

    if ($global:Icinga.InstallWizard.Config.ContainsKey($InstallerStep)) {
        return $global:Icinga.InstallWizard.Config[$InstallerStep].Selection;
    }

    return $null;
}
