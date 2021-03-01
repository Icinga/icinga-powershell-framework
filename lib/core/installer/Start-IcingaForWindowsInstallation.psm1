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
    $AgentPackageType      = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectIcingaAgentSource';
    $AgentInstallDir       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory';
    $ServiceUser           = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser';
    $ServicePassword       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';

    # Icinga for Windows Service
    $WindowsServiceType    = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectWindowsServiceSource';
    $WindowsServiceDir     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory';

    # Icinga for Windows Plugins
    $WindowsPluginsType    = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectIcingaPluginsSource';
    $WindowsPluginsPackage = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterPluginsPackageSource';

    # Global Zones
    $GlobalZonesType       = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectGlobalZones';
    $GlobalZonesCustom     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones';

    # Icinga Endpoint Configuration
    $IcingaZone            = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
    $IcingaEndpoints       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';
    $IcingaPort            = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaPort';

    # Icinga for Windows PowerShell Framework
    $CodeCacheType         = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsManagementConsoleEnableCodeCache';

    $Hostname              = '';
    $GlobalZones           = @();
    $IcingaParentAddresses = @();
    $AgentPackageSource    = ''
    $ServicePackageSource  = ''
    $ServiceSourceGitHub   = $FALSE;
    $InstallAgent          = $TRUE;
    $InstallService        = $TRUE;
    $InstallPlugins        = $TRUE;
    $PluginPackageRelease  = $FALSE;
    $PluginPackageSnapshot = $FALSE;

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

    switch ($AgentPackageType) {
        '0' {
            # Install Icinga Agent from packages.icinga.com
            $AgentPackageSource = ' https://packages.icinga.com/windows';
            break;
        };
        '1' {
            # Install Icinga Agent from custom source
            $AgentPackageSource = (Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaAgentPackageSource');
            break;
        };
        '2' {
            # Do not install Icinga Agent
            $InstallAgent = $FALSE;
            break;
        }
    }

    switch ($WindowsServiceType) {
        '0' {
            #GitHub
            $ServiceSourceGitHub = $TRUE;
            break;
        };
        '1' {
            # Custom location
            $ServicePackageSource = (Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterWindowsServicePackageSource');
            break;
        };
        '2' {
            # Do not install Icinga for Windows service
            $InstallService = $FALSE;
            break;
        }
    }

    switch ($WindowsPluginsType) {
        '0' {
            # Download Release from GitHub
            $PluginPackageRelease = $TRUE;
            break;
        };
        '1' {
            # Download Snapshot (master) from GitHub
            $PluginPackageSnapshot = $TRUE;
            break;
        };
        '2' {
            # Use custom package source
            break;
        };
        '3' {
            # Do not install plugins
            $InstallPlugins = $FALSE;
            break;
        }
    }

    if ($InstallAgent) {
        Install-IcingaAgent -Version $AgentVersion -Source $AgentPackageSource -InstallDir $AgentInstallDir -AllowUpdates $TRUE | Out-Null;
        Reset-IcingaAgentConfigFile;
        Move-IcingaAgentDefaultConfig;
        Set-IcingaAgentNodeName -Hostname $Hostname;
        Set-IcingaAgentServiceUser -User $ServiceUser -Password (ConvertTo-IcingaSecureString $ServicePassword) -SetPermission | Out-Null;
        Install-IcingaAgentBaseFeatures;
        Write-IcingaAgentApiConfig -Port $IcingaPort;
    }

    if ((Install-IcingaAgentCertificates -Hostname $Hostname -Endpoint $IcingaParentAddresses[0] -Port $IcingaPort -CACert $CertificateCAFile -Ticket $CertificateTicket) -eq $FALSE) {
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
        $ServiceData = Get-IcingaFrameworkServiceBinary -FrameworkServiceUrl $ServicePackageSource -Release:$ServiceSourceGitHub -ServiceDirectory $WindowsServiceDir;

        Install-IcingaFrameworkService -Path $ServiceData.ServiceBin -User $ServiceUser -Password (ConvertTo-IcingaSecureString $ServicePassword) | Out-Null;
        Register-IcingaBackgroundDaemon -Command 'Start-IcingaServiceCheckDaemon';
    }

    if ($InstallPlugins) {
        Install-IcingaFrameworkComponent -Name 'plugins' -Release:$PluginPackageRelease -Snapshot:$PluginPackageSnapshot -Url $WindowsPluginsPackage | Out-Null;
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

    switch ($CodeCacheType) {
        '0' {
            # Enable Code Cache
            Enable-IcingaFrameworkCodeCache;
            Write-IcingaConsoleNotice 'Writing Icinga Framework Code Cache file';
            Write-IcingaFrameworkCodeCache;
            break;
        };
        '1' {
            # Disable Code Cache
            Disable-IcingaFrameworkCodeCache;
            break;
        }
    }

    Test-IcingaAgent;

    if ($InstallAgent) {
        Restart-IcingaService 'icinga2';
    }

    if ($InstallService) {
        Restart-IcingaService 'icingapowershell';
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
