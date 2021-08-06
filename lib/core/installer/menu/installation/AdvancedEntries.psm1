function Add-IcingaForWindowsInstallationAdvancedEntries()
{
    $ConnectionConfiguration = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectConnection';

    $OpenFirewall = '1'; # Do not open firewall
    if ($ConnectionConfiguration -ne '0') {
        $OpenFirewall = '0';
    }

    Disable-IcingaFrameworkConsoleOutput;

    Show-IcingaForWindowsInstallationMenuEnterIcingaPort -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall -DefaultInput $OpenFirewall -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectCertificate -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectGlobalZones -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaAgentVersion -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectIcingaAgentSource -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectIcingaPluginsSource -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectWindowsServiceSource -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory -Automated -Advanced;

    Enable-IcingaFrameworkConsoleOutput;

    $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
}
