function Start-IcingaForWindowsInstallation()
{
    param (
        [switch]$Automated
    );

    if ($global:Icinga.InstallWizard.DirectorInstallError -eq $FALSE -And (Get-IcingaFrameworkDebugMode) -eq $FALSE) {
        Clear-Host;
    }

    Write-IcingaConsoleNotice 'Starting Icinga for Windows installation';

    if ($global:Icinga.InstallWizard.DirectorInstallError) {
        Write-IcingaConsoleError 'Failed to start Icinga for Windows installation, caused by an error while communicating with Icinga Director: {0}' -Objects $global:Icinga.InstallWizard.DirectorError;
        throw $global:Icinga.InstallWizard.DirectorError;
        return;
    }

    $ConnectionType        = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectConnection';
    $HostnameType          = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectHostname';
    $FirewallType          = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall';

    # Certificate handler
    $CertificateType       = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectCertificate';
    $CertificateForceGen   = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectForceCertificateGeneration';
    $CertificateTicket     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
    $CertificateCAFile     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';

    # Icinga Agent
    $AgentVersion          = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentVersion';
    $InstallIcingaAgent    = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaAgent';
    $AgentInstallDir       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory';
    $ServiceUser           = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser';
    $ServicePassword       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';

    # Icinga for Windows Service
    $InstallPSService      = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService';
    $WindowsServiceDir     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory';

    # Icinga for Windows Plugins
    $InstallPluginChoice   = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins';

    # Global Zones
    $GlobalZonesType       = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectGlobalZones';
    $GlobalZonesCustom     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones';

    # Icinga Endpoint Configuration
    $IcingaZone            = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
    $IcingaEndpoints       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';
    $IcingaPort            = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaPort';
    $IcingaCAServer        = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaCAServer';

    # Repository
    $IcingaStableRepo      = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuStableRepository';

    # JEA Profile
    $InstallJEAProfile     = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallJEAProfile';

    # Api Checks
    $InstallApiChecks      = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallApiChecks';

    $Hostname              = '';
    $GlobalZones           = @();
    $IcingaParentAddresses = @();
    $ServicePackageSource  = ''
    $ServiceSourceGitHub   = $FALSE;
    $InstallAgent          = $TRUE;
    $InstallService        = $TRUE;
    $InstallPlugins        = $TRUE;
    $PluginPackageRelease  = $FALSE;
    $PluginPackageSnapshot = $FALSE;
    $ForceCertificateGen   = $FALSE;

    if ([string]::IsNullOrEmpty($IcingaStableRepo) -eq $FALSE) {
        Add-IcingaRepository -Name 'Icinga Stable' -RemotePath $IcingaStableRepo -Force;
    }

    foreach ($endpoint in $IcingaEndpoints) {
        $EndpointAddress = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $endpoint;

        $IcingaParentAddresses += $EndpointAddress;
    }

    switch ($HostnameType) {
        '0' {
            $Hostname = (Get-IcingaHostname -AutoUseFQDN 1);
            break;
        };
        '1' {
            $Hostname = (Get-IcingaHostname -AutoUseFQDN 1 -LowerCase 1);
            break;
        };
        '2' {
            $Hostname = (Get-IcingaHostname -AutoUseFQDN 1 -UpperCase 1);
            break;
        };
        '3' {
            $Hostname = (Get-IcingaHostname -AutoUseHostname 1);
            break;
        };
        '4' {
            $Hostname = (Get-IcingaHostname -AutoUseHostname 1 -LowerCase 1);
            break;
        };
        '5' {
            $Hostname = (Get-IcingaHostname -AutoUseHostname 1 -UpperCase 1);
            break;
        };
    }

    switch ($GlobalZonesType) {
        '0' {
            $GlobalZones += 'director-global';
            $GlobalZones += 'global-templates';
            break;
        };
        '1' {
            $GlobalZones += 'director-global';
            break;
        }
        '2' {
            $GlobalZones += 'global-templates';
            break;
        }
    }

    foreach ($zone in $GlobalZonesCustom) {
        if ([string]::IsNullOrEmpty($zone) -eq $FALSE) {
            if ($GlobalZones -Contains $zone) {
                continue;
            }

            $GlobalZones += $zone;
        }
    }

    switch ($InstallIcingaAgent) {
        '0' {
            # Install Icinga Agent from packages.icinga.com
            $InstallAgent = $TRUE;
            break;
        };
        '1' {
            # Do not install Icinga Agent
            $InstallAgent = $FALSE;
            break;
        }
    }

    switch ($InstallPSService) {
        '0' {
            # Install Icinga for Windows Service
            $InstallService = $TRUE;
            break;
        };
        '1' {
            # Do not install Icinga for Windows service
            $InstallService = $FALSE;
            break;
        }
    }

    switch ($InstallPluginChoice) {
        '0' {
            # Download stable release
            $PluginPackageRelease = $TRUE;
            break;
        };
        '1' {
            # Do not install plugins
            $InstallPlugins = $FALSE;
            break;
        }
    }

    if ($CertificateForceGen -eq 1) {
        $ForceCertificateGen = $TRUE;
    }

    if ($InstallAgent) {
        Set-IcingaPowerShellConfig -Path 'Framework.Icinga.AgentLocation' -Value $AgentInstallDir;
        Install-IcingaComponent -Name 'agent' -Version $AgentVersion -Confirm -Release;

        # Only continue this, if our installation was successful
        if ((Get-IcingaAgentInstallation).Installed) {
            Reset-IcingaAgentConfigFile;
            Move-IcingaAgentDefaultConfig;
            Set-IcingaAgentNodeName -Hostname $Hostname;
            Set-IcingaServiceUser -User $ServiceUser -Password (ConvertTo-IcingaSecureString $ServicePassword) -SetPermission | Out-Null;
            Install-IcingaAgentBaseFeatures;
            Write-IcingaAgentApiConfig -Port $IcingaPort;
        }
    }

    # Only continue this, if our installation was successful
    if ((Get-IcingaAgentInstallation).Installed) {
        if ((Install-IcingaAgentCertificates -Hostname $Hostname -Endpoint $IcingaCAServer -Port $IcingaPort -CACert $CertificateCAFile -Ticket $CertificateTicket -Force:$ForceCertificateGen) -eq $FALSE) {
            Disable-IcingaAgentFeature 'api';
            Write-IcingaConsoleWarning `
                -Message '{0}{1}{2}{3}{4}' `
                -Objects (
                    'Your Icinga Agent API feature has been disabled. Please provide either your ca.crt ',
                    'or connect to a parent node for certificate requests. You can run "Install-IcingaAgentCertificates" ',
                    'with your configuration to properly create the host certificate and a valid certificate request. ',
                    'After this you can enable the API feature by using "Enable-IcingaAgentFeature api" and restart the ',
                    'Icinga Agent service "Restart-IcingaService icinga2"'
                );
        }

        Write-IcingaAgentZonesConfig -Endpoints $IcingaEndpoints -EndpointConnections $IcingaParentAddresses -ParentZone $IcingaZone -GlobalZones $GlobalZones -Hostname $Hostname;
    }

    if ($InstallService) {
        Set-IcingaPowerShellConfig -Path 'Framework.Icinga.IcingaForWindowsService' -Value $WindowsServiceDir;
        Set-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser' -User $ServiceUser;
        Set-IcingaInternalPowerShellServicePassword -Password (ConvertTo-IcingaSecureString $ServicePassword);

        Install-IcingaComponent -Name 'service' -Release -Confirm;
        Register-IcingaBackgroundDaemon -Command 'Start-IcingaServiceCheckDaemon';
    }

    if ($InstallPlugins) {
        Install-IcingaComponent -Name 'plugins' -Release:$PluginPackageRelease -Snapshot:$PluginPackageSnapshot -Confirm;
    }

    switch ($FirewallType) {
        '0' {
            # Open Windows Firewall
            Enable-IcingaFirewall -IcingaPort $IcingaPort -Force;
            break;
        };
        '1' {
            # Close Windows Firewall
            Disable-IcingaFirewall;
            break;
        }
    }

    Write-IcingaFrameworkCodeCache;
    Test-IcingaAgent;

    if ($InstallAgent) {
        Restart-IcingaService 'icinga2';
    }

    if ($InstallService) {
        Restart-IcingaWindowsService;
    }

    switch ($InstallJEAProfile) {
        '0' {
            Install-IcingaJEAProfile;
            break;
        };
        '1' {
            Install-IcingaSecurity;
            break;
        };
        '2' {
            # Do not install JEA profile
        };
    }

    switch ($InstallApiChecks) {
        '0' {
            Disable-IcingaFrameworkApiChecks;
            break;
        };
        '1' {
            Register-IcingaBackgroundDaemon -Command 'Start-IcingaWindowsRESTApi';
            Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'apichecks';
            Enable-IcingaFrameworkApiChecks;
            if ($InstallService) {
                Restart-IcingaWindowsService;
            } else {
                Write-IcingaConsoleWarning -Message 'You have selected to install the Api-Check feature and all required configurations were made. The Icinga for Windows service is however not marked for installation, which will cause this feature to not work.';
            }
            break;
        };
    }

    # Update configuration and clear swap
    $ConfigSwap = Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap';
    Set-IcingaPowerShellConfig -Path 'Framework.Config.Swap' -Value $null;
    Set-IcingaPowerShellConfig -Path 'Framework.Config.Live' -Value $ConfigSwap;
    $global:Icinga.InstallWizard.Config = @{ };
    Set-IcingaPowerShellConfig -Path 'Framework.Installed' -Value $TRUE;

    if ($Automated -eq $FALSE) {
        Write-IcingaConsoleNotice 'Icinga for Windows is installed. Returning to main menu in 5 seconds'
        Start-Sleep -Seconds 5;
    }

    $global:Icinga.InstallWizard.NextCommand   = 'Install-Icinga';
    $global:Icinga.InstallWizard.NextArguments = @{ };
}
