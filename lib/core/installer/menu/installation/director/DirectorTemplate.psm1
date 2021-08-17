function Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate()
{
    param (
        [switch]$Register = $FALSE
    );

    $DirectorUrl    = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl';
    $SelfServiceKey = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';
    $UsedEnteredKey = $SelfServiceKey;

    # Once we run this menu, we require to reset everything to have a proper state
    if ($Register -eq $FALSE) {
        $global:Icinga.InstallWizard.Config = @{ };

        Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $DirectorUrl -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl';
        Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $SelfServiceKey -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';
    } else {
        $HostnameType = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectHostname';
        $Hostname     = '';

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

        try {
            $SelfServiceKey = Register-IcingaDirectorSelfServiceHost -DirectorUrl $DirectorUrl -ApiKey $SelfServiceKey -Hostname $Hostname;
            $UsedEnteredKey = $SelfServiceKey;
        } catch {
            Write-IcingaConsoleNotice 'Host seems already to be registered within Icinga Director. Trying local Api key if present'
            $SelfServiceKey = Get-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey';

            if ([string]::IsNullOrEmpty($SelfServiceKey)) {
                Write-IcingaConsoleNotice 'No local Api key was found and using your provided template key failed. Please ensure the host is not already registered and drop the set Self-Service key within the Icinga Director for this host.'
            }
        }
        Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $UsedEnteredKey -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';
    }

    try {
        $DirectorConfig = Get-IcingaDirectorSelfServiceConfig -DirectorUrl $DirectorUrl -ApiKey $SelfServiceKey;
    } catch {
        Set-IcingaForWindowsManagementConsoleMenu 'Show-IcingaForWindowsInstallerConfigurationSummary';
        $global:Icinga.InstallWizard.LastError = 'Failed to fetch host configuration with the given Director Url and Self-Service key. Please ensure the template key is correct and in case a previous host key was used, that it matches the one configured within the Icinga Director. In case this form was loaded previously with a key, it might be that the host key is no longer valid and requires to be dropped. In addition please ensure that this host can connect to the Icinga Director and the SSL certificate is trusted. Otherwise run "Enable-IcingaUntrustedCertificateValidation" before starting the management console. Otherwise modify the "DirectorSelfServiceKey" configuration element above with the correct key and try again.';
        return;
    }

    # No we need to identify which host selection is matching our config
    $HostnameSelection        = -1;
    $InstallPluginsSelection  = -1;
    $InstallServiceSelection  = -1;
    $WindowsFirewallSelection = 1;

    $ServiceUserName          = $DirectorConfig.icinga_service_user;
    $AgentPackageSelection    = 1; #Always use custom source
    $AgentPackageSource       = $DirectorConfig.download_url;
    $AgentVersion             = $DirectorConfig.release;
    $IcingaPort               = $DirectorConfig.agent_listen_port;
    $GlobalZones              = @();
    $IcingaParents            = @();
    $IcingaParentAddresses    = New-Object PSCustomObject;
    $ParentZone               = '';
    $MasterAddress            = '';
    $Ticket                   = '';

    if ($DirectorUrl.ToLower().Contains('https://') -Or $DirectorUrl.ToLower().Contains('http://')) {
        $MasterAddress = $DirectorUrl.Split('/')[2];
    } else {
        $MasterAddress = $DirectorUrl.Split('/')[0];
    }

    if ($Register) {
        if ($null -ne $DirectorConfig.agent_add_firewall_rule -And $DirectorConfig.agent_add_firewall_rule) {
            # Open Windows Firewall
            $WindowsFirewallSelection = 0;
        }

        if ($null -ne $DirectorConfig.global_zones) {
            $GlobalZones = $DirectorConfig.global_zones;
        }

        if ($null -ne $DirectorConfig.parent_endpoints) {
            $IcingaParents = $DirectorConfig.parent_endpoints;
        }

        if ($null -ne $DirectorConfig.endpoints_config) {
            [int]$Index = 0;
            foreach ($entry in $DirectorConfig.endpoints_config) {
                $IcingaParentAddresses | Add-Member -MemberType NoteProperty -Name ($IcingaParents[$Index]) -Value (($entry.Split(';')[0]));
                $Index += 1;
            }
        }

        if ($null -ne $DirectorConfig.parent_zone) {
            $ParentZone = $DirectorConfig.parent_zone;
        }

        $Ticket = Get-IcingaDirectorSelfServiceTicket -DirectorUrl $DirectorUrl -ApiKey $SelfServiceKey;
    }

    if ($DirectorConfig.fetch_agent_fqdn) {
        switch ($DirectorConfig.transform_hostname) {
            '0' {
                # FQDN as it is
                $HostnameSelection = 0;
                break;
            };
            '1' {
                # FQDN to lowercase
                $HostnameSelection = 1;
                break;
            };
            '2' {
                # FQDN to uppercase
                $HostnameSelection = 2;
                break;
            }
        }
    } elseif ($DirectorConfig.fetch_agent_name) {
        switch ($DirectorConfig.transform_hostname) {
            '0' {
                # Hostname as it is
                $HostnameSelection = 3;
                break;
            };
            '1' {
                # Hostname to lowercase
                $HostnameSelection = 4;
                break;
            };
            '2' {
                # Hostname to uppercase
                $HostnameSelection = 5;
                break;
            }
        }
    }

    if ($DirectorConfig.install_framework_service -eq 0) {
        # Do not install
        $InstallServiceSelection = 1;
    } else {
        $InstallServiceSelection = 0;
    }

    if ($DirectorConfig.install_framework_plugins -eq 0) {
        # Do not install
        $InstallPluginsSelection = 1;
    } else {
        # TODO: This is currently not supported. We use the "default" config for installing from GitHub by now
        $InstallPluginsSelection = 0;
    }

    Disable-IcingaFrameworkConsoleOutput;
    Show-IcingaForWindowsInstallerMenuSelectHostname -DefaultInput $HostnameSelection -Automated;
    Add-IcingaForWindowsInstallationAdvancedEntries;
    Disable-IcingaFrameworkConsoleOutput;

    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins -DefaultInput $InstallPluginsSelection -Value @() -Automated;
    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService -DefaultInput $InstallServiceSelection -Value @() -Automated;
    Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall -DefaultInput $WindowsFirewallSelection -Value @() -Automated;

    if ($Register) {
        Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones -Value $GlobalZones -Automated;
        Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes -Value $IcingaParents -Automated;
        Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses -Value $IcingaParentAddresses -Automated;
        Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone -Value $ParentZone -Automated;
    }

    Show-IcingaForWindowsInstallationMenuEnterIcingaCAServer -Automated -Value $MasterAddress;

    Show-IcingaForWindowsInstallerMenuSelectCertificate -Automated -DefaultInput '1';
    Show-IcingaForWindowsInstallerMenuEnterIcingaTicket -Automated -Value $Ticket;

    Show-IcingaForWindowsManagementConsoleInstallationDirectorRegisterHost -Automated;

    Enable-IcingaFrameworkConsoleOutput;
    Reset-IcingaForWindowsManagementConsoleInstallationDirectorConfigModifyState;
}
