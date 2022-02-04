function Invoke-IcingaForWindowsManagementConsoleReconfigureAgent()
{
    $LiveConfig = Get-IcingaPowerShellConfig -Path 'Framework.Config.Live';

    if ($null -eq $LiveConfig) {
        $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerMenuInstallWindows';
        $global:Icinga.InstallWizard.LastError   += 'Unable to load any previous live configuration. Reconfiguring not possible.';
        return;
    }

    $global:Icinga.InstallWizard.Config      = Convert-IcingaForwindowsManagementConsoleJSONConfig -Config $LiveConfig;
    $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
}
