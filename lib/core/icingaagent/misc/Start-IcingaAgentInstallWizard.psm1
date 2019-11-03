function Start-IcingaAgentInstallWizard()
{
    param(
        [string]$Hostname,
        $AutoUseFQDN,
        $AutoUseHostname,
        $LowerCase,
        $UpperCase,
        $AddDirectorGlobal           = $null,
        $AddGlobalTemplates          = $null,
        [string]$PackageSource,
        [string]$AgentVersion,
        $AllowVersionChanges,
        $UpdateAgent                 = $null,
        $AddFirewallRule             = $null,
        $AcceptConnections           = $null,
        [array]$Endpoints            = @(),
        [array]$EndpointConnections  = @(),
        [string]$ParentZone,
        [array]$GlobalZones          = $null,
        [string]$CAEndpoint,
        $CAPort                      = $null,
        [string]$Ticket,
        [string]$CAFile              = $null,
        $EmptyCA                     = $null,
        [switch]$RunInstaller,
        [switch]$Reconfigure,
        [string]$ServiceUser,
        [securestring]$ServicePass   = $null,
        $InstallFrameworkService     = $null,
        $FrameworkServiceUrl         = $null,
        $ServiceDirectory            = $null,
        $ServiceBin                  = $null,
        $UseDirectorSelfService      = $null,
        [bool]$SkipDirectorQuestion  = $FALSE,
        [string]$DirectorUrl,
        [string]$SelfServiceAPIKey   = $null,
        $OverrideDirectorVars        = $null,
        $InstallFrameworkPlugins     = $null,
        $PluginsUrl                  = $null
    );

    [array]$InstallerArguments = @();
    [array]$GlobalZoneConfig   = @();

    if ($SkipDirectorQuestion -eq $FALSE) {
        if ($null -eq $UseDirectorSelfService) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to use the Icinga Director Self-Service API?' -Default 'y').result -eq 1) {
                $UseDirectorSelfService = $TRUE;
            } else {
                $UseDirectorSelfService = $FALSE;
                $InstallerArguments += '-UseDirectorSelfService 0';
            }
        }
        if ($UseDirectorSelfService) {

            $InstallerArguments += '-UseDirectorSelfService 1';
            $DirectorArgs = Start-IcingaAgentDirectorWizard `
                -DirectorUrl $DirectorUrl `
                -SelfServiceAPIKey $SelfServiceAPIKey `
                -OverrideDirectorVars $OverrideDirectorVars `
                -RunInstaller $RunInstaller;

            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'DirectorUrl' -Value $DirectorUrl -InstallerArguments $InstallerArguments;
            $DirectorUrl         = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'SelfServiceAPIKey' -Value $SelfServiceAPIKey -InstallerArguments $InstallerArguments -Default $null;
            if ([string]::IsNullOrEmpty($Result.Value) -eq $FALSE) {
                Write-Host 'Setting self service arg'
                $SelfServiceAPIKey   = $Result.Value;
                $InstallerArguments  = $Result.Args;
            }
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'Ticket' -Value $Ticket -InstallerArguments $InstallerArguments;
            $Ticket              = $Result.Value;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'PackageSource' -Value $PackageSource -InstallerArguments $InstallerArguments;
            $PackageSource       = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AgentVersion' -Value $AgentVersion -InstallerArguments $InstallerArguments;
            $AgentVersion        = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'CAPort' -Value $CAPort -InstallerArguments $InstallerArguments;
            $CAPort              = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AllowVersionChanges' -Value $AllowVersionChanges -InstallerArguments $InstallerArguments;
            $AllowVersionChanges = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'GlobalZones' -Value $GlobalZones -InstallerArguments $InstallerArguments;
            $GlobalZones         = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ParentZone' -Value $ParentZone -InstallerArguments $InstallerArguments;
            $ParentZone          = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'CAEndpoint' -Value $CAEndpoint -InstallerArguments $InstallerArguments;
            $CAEndpoint          = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'Endpoints' -Value $Endpoints -InstallerArguments $InstallerArguments;
            $Endpoints           = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddFirewallRule' -Value $AddFirewallRule -InstallerArguments $InstallerArguments;
            $AddFirewallRule     = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AcceptConnections' -Value $AcceptConnections -InstallerArguments $InstallerArguments;
            $AcceptConnections   = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddFirewallRule' -Value $AddFirewallRule -InstallerArguments $InstallerArguments;
            $AddFirewallRule     = $Result.Value;
            $InstallerArguments  = $Result.Args;            
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ServiceUser' -Value $ServiceUser -InstallerArguments $InstallerArguments;
            $ServiceUser         = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'UpdateAgent' -Value $UpdateAgent -InstallerArguments $InstallerArguments;
            $UpdateAgent         = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddDirectorGlobal' -Value $AddDirectorGlobal -InstallerArguments $InstallerArguments;
            $AddDirectorGlobal   = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddGlobalTemplates' -Value $AddGlobalTemplates -InstallerArguments $InstallerArguments;
            $AddGlobalTemplates  = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'LowerCase' -Value $LowerCase -Default $FALSE -InstallerArguments $InstallerArguments;
            $LowerCase           = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'UpperCase' -Value $UpperCase -Default $FALSE -InstallerArguments $InstallerArguments;
            $UpperCase           = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AutoUseFQDN' -Value $AutoUseFQDN -Default $FALSE -InstallerArguments $InstallerArguments;
            $AutoUseFQDN         = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AutoUseHostname' -Value $AutoUseHostname -Default $FALSE -InstallerArguments $InstallerArguments;
            $AutoUseHostname     = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'EndpointConnections' -Value $EndpointConnections -InstallerArguments $InstallerArguments;
            $EndpointConnections = $Result.Value;
            $InstallerArguments  = $Result.Args;
        }
    }

    if ([string]::IsNullOrEmpty($Hostname) -And $AutoUseFQDN -eq $FALSE -And $AutoUseHostname -eq $FALSE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to manually specify a hostname?' -Default 'n').result -eq 1) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to automatically fetch the hostname with its FQDN?' -Default 'y').result -eq 1) {
                $InstallerArguments += '-AutoUseFQDN 1';
                $AutoUseFQDN = $TRUE;
            } else {
                $InstallerArguments += '-AutoUseHostname 1';
                $AutoUseHostname = $TRUE;
            }
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to modify the hostname to only include lower case characters?' -Default 'y').result -eq 1) {
                $InstallerArguments += '-LowerCase 1';
                $LowerCase = $TRUE;
            } else {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to modify the hostname to only include upper case characters?' -Default 'n').result -eq 0) {
                    $InstallerArguments += '-UpperCase 1';
                    $UpperCase = $TRUE;
                }
            }
            $Hostname = Get-IcingaHostname -AutoUseFQDN $AutoUseFQDN -AutoUseHostname $AutoUseHostname -LowerCase $LowerCase -UpperCase $UpperCase;
        } else {
            $Hostname = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the hostname to use' -Default 'v').answer;
        }
    } else {
        if ($AutoUseFQDN -Or $AutoUseHostname) {
            $Hostname = Get-IcingaHostname -AutoUseFQDN $AutoUseFQDN -AutoUseHostname $AutoUseHostname -LowerCase $LowerCase -UpperCase $UpperCase;
        }
    }

    Write-Host ([string]::Format('Using hostname "{0}" for the Icinga 2 Agent configuration', $Hostname));

    $IcingaAgent = Get-IcingaAgentInstallation;
    if ($IcingaAgent.Installed -eq $FALSE) {
        if ([string]::IsNullOrEmpty($PackageSource)) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the Icinga Agent now?' -Default 'y').result -eq 1) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to use a different package source then "https://packages.icinga.com/windows/"?' -Default 'n').result -eq 0) {
                    $PackageSource = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your package source' -Default 'v').answer;
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                } else {
                    $PackageSource = 'https://packages.icinga.com/windows/'
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                }

                Write-Host ([string]::Format('Using package source "{0}" for the Icinga 2 Agent package', $PackageSource));
            }

            if ([string]::IsNullOrEmpty($AgentVersion)) {
                $AgentVersion = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the version you wish to install ("latest", "snapshot", or a version like "2.11.0")' -Default 'v' -DefaultInput 'latest').answer;
                $InstallerArguments += "-AgentVersion '$AgentVersion'";

                Write-Host ([string]::Format('Installing Icinga Version: "{0}"', $AgentVersion));
            }
        }
    } else {
        if ($null -eq $UpdateAgent) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'The Icinga 2 Agent is already installed. Would you like to update it?' -Default 'y').result -eq 1) {
                $UpdateAgent = 1;
            } else {
                $UpdateAgent = 0;
            }
            $InstallerArguments += "-UpdateAgent $UpdateAgent";
        }

        if ($UpdateAgent -eq 1) {
            if ([string]::IsNullOrEmpty($AgentVersion)) {
                $AgentVersion = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the version you wish to install ("latest", "snapshot", or a version like "2.11.0")' -Default 'v').answer;
                $AllowVersionChanges = $TRUE;
                $InstallerArguments += "-AgentVersion '$AgentVersion'";
                $InstallerArguments += '-AllowVersionChanges 1';

                Write-Host ([string]::Format('Updating/Downgrading Icinga 2 Agent to version: "{0}"', $AgentVersion));
            }

            if ([string]::IsNullOrEmpty($PackageSource)) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to use a different package source then "https://packages.icinga.com/windows/" ?' -Default 'n').result -eq 0) {
                    $PackageSource = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your package source' -Default 'v').answer;
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                } else {
                    $PackageSource = 'https://packages.icinga.com/windows/'
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                }
            }
        }
    }

    if ($null -eq $AcceptConnections) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Will this Agent connect to its parent endpoint(s)?' -Default 'y').result -eq 1) {
            $InstallerArguments += "-AcceptConnections 1";
            $AcceptConnections = 1;
        } else {
            $InstallerArguments += "-AcceptConnections 0";
            $AcceptConnections = 0;
        }
    }

    if ($Endpoints.Count -eq 0) {
        $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify all endpoints this Agent will report to (separated by ",")' -Default 'v').answer;
        $Endpoints = ($ArrayString.Replace(' ', '')).Split(',');
        $InstallerArguments += ("-Endpoints " + ([string]::Join(',', $Endpoints)));
    }

    if ($null -eq $CAPort) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Are you using a different port than 5665 for Icinga communications?' -Default 'n').result -eq 0) {
            $CAPort = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the port for Icinga 2 communication' -Default 'v').answer;
            $InstallerArguments += "-CAPort $CAPort";
        } else {
            $InstallerArguments += "-CAPort 5665";
            $CAPort = 5665;
        }
    }

    if ($AcceptConnections -eq 0) {
        if ($null -eq $AddFirewallRule) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to open the Windows Firewall for incoming traffic on Port "{0}"?', $CAPort)) -Default 'y').result -eq 1) {
                $InstallerArguments += "-AddFirewallRule 1";
                $AddFirewallRule = $TRUE;
            } else {
                $InstallerArguments += "-AddFirewallRule 0";
                $AddFirewallRule = $FALSE;
            }
        }
    }

    if ($EndpointConnections.Count -eq 0 -And $AcceptConnections -eq 1) {
        $NetworkDefault = '';
        foreach ($Endpoint in $Endpoints) {
            $NetworkDefault += [string]::Format('[{0}]:{1},', $Endpoint, $CAPort);
        }
        if ([string]::IsNullOrEmpty($NetworkDefault) -eq $FALSE) {
            $NetworkDefault = $NetworkDefault.Substring(0, $NetworkDefault.Length - 1);
        }
        $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the network destinations this agent will connect to, separated by ","' -Default 'v' -DefaultInput $NetworkDefault).answer;
        $EndpointConnections = ($ArrayString.Replace(' ', '')).Split(',');
        $InstallerArguments += ("-EndpointConnections " + ([string]::Join(',', $EndpointConnections)));
    }

    if ([string]::IsNullOrEmpty($ParentZone)) {
        $ParentZone = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the parent zone this agent will connect to' -Default 'v' -DefaultInput 'master').answer;
        $InstallerArguments += "-ParentZone $ParentZone";
    }

    if ($null -eq $AddDirectorGlobal) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to add the global zone "director-global"?' -Default 'y').result -eq 1) {
            $AddDirectorGlobal = $TRUE;
            $InstallerArguments += ("-AddDirectorGlobal 1");
        } else {
            $AddDirectorGlobal = $FALSE;
            $InstallerArguments += ("-AddDirectorGlobal 0");
        }
    }

    if ($AddDirectorGlobal) {
        $GlobalZoneConfig += 'director-global';
    }

    if ($null -eq $AddGlobalTemplates) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to add the global zone "global-templates"?' -Default 'y').result -eq 1) {
            $AddGlobalTemplates = $TRUE;
            $InstallerArguments += ("-AddGlobalTemplates 1");
        } else {
            $AddGlobalTemplates = $FALSE;
            $InstallerArguments += ("-AddGlobalTemplates 0");
        }
    }

    if ($AddGlobalTemplates) {
        $GlobalZoneConfig += 'global-templates';
    }

    if ($null -eq $GlobalZones) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to add custom global zones?' -Default 'n').result -eq 0) {
            $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your additional zones seperated by ","' -Default 'v').answer;
            $GlobalZones = ($ArrayString.Replace(' ', '')).Split(',')
            $GlobalZoneConfig += $GlobalZones;
            $InstallerArguments += ("-GlobalZones " + ([string]::Join(',', $GlobalZones)));
        } else {
            $GlobalZones = @();
            $InstallerArguments += ("-GlobalZones @()");
        }
    } else {
        $GlobalZoneConfig += $GlobalZones;
    }

    [bool]$CanConnectToParent = $FALSE;

    if ($null -eq $AcceptConnections) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is this Agent able to connect to its parent node for certificate generation?' -Default 'y').result -eq 1) {
            $CanConnectToParent = $TRUE;
            $InstallerArguments += ("-AcceptConnections 1");
        } else {
            $InstallerArguments += ("-AcceptConnections 0");
        }
    } elseif ($AcceptConnections) {
        $CanConnectToParent = $TRUE;
        $InstallerArguments += ("-AcceptConnections 1");
    }

    if ($CanConnectToParent) {
        if ([string]::IsNullOrEmpty($CAEndpoint)) {
            $CAEndpoint = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the FQDN for either ONE of your Icinga parent node/nodes or your Icinga 2 CA master' -Default 'v' -DefaultInput (Get-IPConfigFromString $EndpointConnections[0]).address).answer;
            $InstallerArguments += "-CAEndpoint $CAEndpoint";
        }
        if ($null -eq $Ticket) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you have a Icinga Ticket available to sign your certificate?' -Default 'y').result -eq 1) {
                $Ticket = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter your Icinga Ticket' -Default 'v').answer;
                $InstallerArguments += "-Ticket $Ticket";
            } else {
                $InstallerArguments += "-Ticket ''";
            }
        }
    } else {
        if ([string]::IsNullOrEmpty($CAFile) -And $null -eq $EmptyCA) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is your public Icinga 2 CA (ca.crt) available on a local, network or web share?' -Default 'y').result -eq 1) {
                $CAFile = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please provide the full path to your ca.crt file' -Default 'v').answer;
                $InstallerArguments += "-CAFile $CAFile";
                $InstallerArguments += "-EmptyCA 0";
            } else {
                $InstallerArguments += "-CAFile ''";
                $InstallerArguments += "-EmptyCA 1"
            }
        } else {
            if ([string]::IsNullOrEmpty($CAFile)) {
                $InstallerArguments += "-CAFile ''";
            } else {
                $InstallerArguments += "-CAFile $CAFile";
            }
            $InstallerArguments += "-EmptyCA $EmptyCA"
        }
    }

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to change the user the Icinga Agent service is running with (Default: "NT Authority\NetworkService")?' -Default 'n').result -eq 0) {
            $ServiceUser = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the user you wish the Icinga Agent service to run with' -Default 'v').answer;
            $InstallerArguments += "-ServiceUser $ServiceUser";
            if ($null -eq $ServicePass) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Does your Icinga Service user require a password to login (not required for System users)?' -Default 'y').result -eq 1) {
                    $ServicePass = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the password for your service user' -Secure -Default 'v').answer;
                    $InstallerArguments += "-ServicePass $ServicePass";
                } else {
                    $ServicePass = '';
                    $InstallerArguments += "-ServicePass ''";
                }
            }
        } else {
            $InstallerArguments += "-ServiceUser 'NT Authority\NetworkService'";
            $ServiceUser = 'NT Authority\NetworkService';
        }
    }

    if ($null -eq $InstallFrameworkPlugins) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the Icinga Plugins?' -Default 'y').result -eq 1) {
            $result = Install-IcingaFrameworkPlugins -PluginsUrl $PluginsUrl;
            $PluginsUrl = $result.PluginsUrl;
            $InstallerArguments += "-InstallFrameworkPlugins 1";
            $InstallerArguments += "-$PluginsUrl '$PluginsUrl'";
        } else {
            $InstallerArguments += "-InstallFrameworkPlugins 0";
        }
    }

    if ($null -eq $InstallFrameworkService) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the PowerShell Framework as a Service?' -Default 'y').result -eq 1) {
            $result = Get-IcingaFrameworkServiceBinary;
            $InstallerArguments += "-InstallFrameworkService 1";
            $InstallerArguments += [string]::Format("-FrameworkServiceUrl '{0}'", $result.FrameworkServiceUrl);
            $InstallerArguments += [string]::Format("-ServiceDirectory '{0}'", $result.ServiceDirectory);
            $InstallerArguments += [string]::Format("-ServiceBin '{0}'", $result.ServiceBin);
            $ServiceBin = $result.ServiceBin;
        } else {
            $InstallerArguments += "-InstallFrameworkService 0";
        }
    } elseif ($InstallFrameworkService -eq $TRUE) {
        $result     = Get-IcingaFrameworkServiceBinary -FrameworkServiceUrl $FrameworkServiceUrl -ServiceDirectory $ServiceDirectory;
        $ServiceBin = $result.ServiceBin;
    } else {
        $InstallerArguments += "-InstallFrameworkService 0";
    }

    if ($InstallerArguments.Count -ne 0) {
        $InstallerArguments += "-RunInstaller";
        Write-Host 'The wizard is complete. These are the configured settings:';

        Write-Host '========'
        Write-Host ($InstallerArguments | Out-String);
        Write-Host '========'

        if (-Not $RunInstaller) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is this configuration correct?' -Default 'y').result -eq 1) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to run the installer now? (Otherwise only the configration command will be printed)' -Default 'y').result -eq 1) {
                    Write-Host 'To execute your Icinga Agent installation based on your answers again on this or another machine, simply run this command:'

                    $RunInstaller = $TRUE;
                } else {
                    Write-Host 'To execute your Icinga Agent installation based on your answers, simply run this command:'
                }
            } else {
                Write-Host 'Please run the wizard again to modify your answers or modify the command below:'
            }
        }
        Get-IcingaAgentInstallCommand -InstallerArguments $InstallerArguments -PrintConsole;
    }

    if ($RunInstaller) {
        if ((Install-IcingaAgent -Version $AgentVersion -Source $PackageSource -AllowUpdates $AllowVersionChanges) -Or $Reconfigure) {
            Move-IcingaAgentDefaultConfig;
            Set-IcingaAgentServiceUser -User $ServiceUser -Password $ServicePass -SetPermission | Out-Null;
            Install-IcingaFrameworkService -Path $ServiceBin -User $ServiceUser -Password $ServicePass | Out-Null;
            Register-IcingaBackgroundDaemon -Command 'Start-IcingaServiceCheckDaemon';
            Install-IcingaAgentBaseFeatures;
            Install-IcingaAgentCertificates -Hostname $Hostname -Endpoint $CAEndpoint -Port $CAPort -CACert $CAFile -Ticket $Ticket | Out-Null;
            Write-IcingaAgentApiConfig -Port $CAPort;
            Write-IcingaAgentZonesConfig -Endpoints $Endpoints -EndpointConnections $EndpointConnections -ParentZone $ParentZone -GlobalZones $GlobalZoneConfig -Hostname $Hostname;
            if ($AddFirewallRule) {
                # First cleanup the system by removing all old Firewalls
                Enable-IcingaFirewall -IcingaPort $CAPort -Force;
            }
            Test-IcingaAgent;
            Restart-IcingaService 'icingapowershell';
            Restart-IcingaService 'icinga2';
        }
    }
}

function Set-IcingaWizardArgument()
{
    param(
        [hashtable]$DirectorArgs,
        [string]$WizardArg,
        $Value,
        $Default                 = $null,
        $InstallerArguments
    );

    if ($DirectorArgs.Overrides.ContainsKey($WizardArg)) {
        $Override = $DirectorArgs.Overrides[$WizardArg];
        if ($Value -is [array]) {
            $Override = [string]::Join(',', $Override);
        }
        $InstallerArguments += "-$WizardArg $Override";
        return @{
            'Value' = $Override;
            'Args'  = $InstallerArguments;
        };
    }

    $RetValue = $null;

    if ($DirectorArgs.Arguments.ContainsKey($WizardArg)) {
        $RetValue = $DirectorArgs.Arguments[$WizardArg];
        if ($Value -is [array]) {
            $RetValue = [string]::Join(',', $RetValue);
        }
    } else {
        if ($null -ne $Value -Or [string]::IsNullOrEmpty($Value) -eq $FALSE) {
            if ($Value -is [array]) {
                $Value = [string]::Join(',', $Value);
            }
            $InstallerArguments += "-$WizardArg $Value";
            return @{
                'Value' = $Value;
                'Args'  = $InstallerArguments;
            };
        } else {
            return @{
                'Value' = $Default;
                'Args'  = $InstallerArguments;
            };
        }
    }

    if ([string]::IsNullOrEmpty($Value) -eq $FALSE) {
        if ($Value -is [array]) {
            $Value = [string]::Join(',', $Value);
        }
        $InstallerArguments += "-$WizardArg $Value";
        return @{
            'Value' = $Value;
            'Args'  = $InstallerArguments;
        };
    }

    return @{
        'Value' = $RetValue;
        'Args'  = $InstallerArguments;
    };
}
function Get-IcingaAgentInstallCommand()
{
    param(
        $InstallerArguments,
        [switch]$PrintConsole
    );

    [string]$Installer = (
        [string]::Format(
            'Start-IcingaAgentInstallWizard {0}',
            ([string]::Join(' ', $InstallerArguments))
        )
    );

    if ($PrintConsole) {
        Write-Host '===='
        Write-Host $Installer -ForegroundColor ([System.ConsoleColor]::Cyan);
        Write-Host '===='
    } else {
        return $Installer;
    }
}
