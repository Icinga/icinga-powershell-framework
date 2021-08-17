function Start-IcingaForWindowsInstallation()
{
    param (
        [switch]$Automated
    );

    if ((Get-IcingaFrameworkDebugMode) -eq $FALSE) {
        Clear-Host;
    }

    Write-IcingaConsoleNotice 'Starting Icinga for Windows installation';

    $ConnectionType        = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectConnection';
    $HostnameType          = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectHostname';
    $FirewallType          = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall';

    # Certificate handler
    $CertificateType       = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectCertificate';
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

    if ([string]::IsNullOrEmpty($IcingaStableRepo) -eq $FALSE) {
        Add-IcingaRepository -Name 'Icinga Stable' -RemotePath $IcingaStableRepo;
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

    if ($InstallAgent) {
        Set-IcingaPowerShellConfig -Path 'Framework.Icinga.AgentLocation' -Value $AgentInstallDir;
        Install-IcingaComponent -Name 'agent' -Version $AgentVersion -Confirm -Release;
        Reset-IcingaAgentConfigFile;
        Move-IcingaAgentDefaultConfig;
        Set-IcingaAgentNodeName -Hostname $Hostname;
        Set-IcingaAgentServiceUser -User $ServiceUser -Password (ConvertTo-IcingaSecureString $ServicePassword) -SetPermission | Out-Null;
        Install-IcingaAgentBaseFeatures;
        Write-IcingaAgentApiConfig -Port $IcingaPort;
    }

    if ((Install-IcingaAgentCertificates -Hostname $Hostname -Endpoint $IcingaCAServer -Port $IcingaPort -CACert $CertificateCAFile -Ticket $CertificateTicket) -eq $FALSE) {
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
        Restart-IcingaService 'icingapowershell';
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
        }
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
