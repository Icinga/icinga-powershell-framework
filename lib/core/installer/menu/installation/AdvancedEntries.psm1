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
    # Only apply the certificate menu in case it was not selected previously, if
    # we choose IfW-Connection 1 for example, which tells the Parent to connect to Agent only
    if ($null -eq (Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectCertificate')) {
        Show-IcingaForWindowsInstallerMenuSelectCertificate -Automated -Advanced;
    }
    Show-IcingaForWindowsInstallerMenuSelectForceCertificateGeneration -Automated -Advanced;
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
    Show-IcingaForWindowsInstallerMenuSelectInstallApiChecks -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectServiceRecovery -Automated -Advanced;

    Enable-IcingaFrameworkConsoleOutput;

    $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
}
