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
    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaAgent -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuStableRepository -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectInstallJEAProfile -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaCAServer -Automated -Advanced;

    Enable-IcingaFrameworkConsoleOutput;

    $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
}
