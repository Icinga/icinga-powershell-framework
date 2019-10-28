function Start-IcingaAgentInstallWizard()
{
    param(
        [string]$Hostname,
        [switch]$AutoUseFQDN         = $FALSE,
        [switch]$AutoUseHostname     = $FALSE,
        [switch]$LowerCase           = $FALSE,
        [switch]$UpperCase           = $FALSE,
        $AddDirectorGlobal           = $null,
        $AddGlobalTemplates          = $null,
        [string]$PackageSource,
        [string]$AgentVersion,
        [switch]$AllowVersionChanges = $FALSE,
        $UpdateAgent                 = $null,
        $AcceptConnections           = $null,
        [array]$Endpoints            = @(),
        [array]$EndpointConnections  = @(),
        [string]$ParentZone,
        [array]$GlobalZones          = $null,
        [string]$CAEndpoint,
        $CAPort                      = $null,
        [string]$Ticket,
        [string]$CAFile,
        [switch]$RunInstaller,
        [switch]$Reconfigure,
        [string]$ServiceUser,
        [securestring]$ServicePass   = $null
    );

    [array]$InstallerArguments = @();
    [array]$GlobalZoneConfig   = @();

    if ([string]::IsNullOrEmpty($Hostname) -And $AutoUseFQDN -eq $FALSE -And $AutoUseHostname -eq $FALSE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to manually specify a hostname?' -Default 'n').result -eq 1) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to automatically fetch the hostname with its FQDN?' -Default 'y').result -eq 1) {
                $InstallerArguments += '-AutoUseFQDN';
                $AutoUseFQDN = $TRUE;
            } else {
                $InstallerArguments += '-AutoUseHostname';
                $AutoUseHostname = $TRUE;
            }
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to modify the hostname to only include lower case characters?' -Default 'y').result -eq 1) {
                $InstallerArguments += '-LowerCase';
                $LowerCase = $TRUE;
            } else {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to modify the hostname to only include upper case characters?' -Default 'n').result -eq 0) {
                    $InstallerArguments += '-UpperCase';
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
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to use a different package source then "https://packages.icinga.com/windows/" ?' -Default 'n').result -eq 0) {
                    $PackageSource = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your package source' -Default 'v').answer;
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                } else {
                    $PackageSource = 'https://packages.icinga.com/windows/'
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                }

                Write-Host ([string]::Format('Using package source "{0}" for the Icinga 2 Agent package', $PackageSource));
            }

            if ([string]::IsNullOrEmpty($AgentVersion)) {
                $AgentVersion = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the version you wish to install ("latest", "snapshot", or a version like "2.11.0")' -Default 'v').answer;
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
                $InstallerArguments += '-AllowVersionChanges';

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

    if ($EndpointConnections.Count -eq 0 -And $AcceptConnections -eq 1) {
        $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the network destinations this agent will connect to ("," separated, like: "[127.0.0.1], [127.0.0.2]")' -Default 'v').answer;
        $EndpointConnections = ($ArrayString.Replace(' ', '')).Split(',');
        $InstallerArguments += ("-EndpointConnections " + ([string]::Join(',', $EndpointConnections)));
    }

    if ([string]::IsNullOrEmpty($ParentZone)) {
        $ParentZone = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the parent zone this agent will connect to' -Default 'v').answer;
        $InstallerArguments += "-ParentZone $ParentZone";
    }

    if ($null -eq $AddDirectorGlobal) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to add the global zone "director-global"?' -Default 'y').result -eq 1) {
            $AddDirectorGlobal = $TRUE;
        } else {
            $AddDirectorGlobal = $FALSE;
        }
    }

    $InstallerArguments += ("-AddDirectorGlobal $AddDirectorGlobal");
    if ($AddDirectorGlobal) {
        $GlobalZoneConfig += 'director-global';
    }

    if ($null -eq $AddGlobalTemplates) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to add the global zone "global-templates"?' -Default 'y').result -eq 1) {
            $AddGlobalTemplates = $TRUE;
        } else {
            $AddGlobalTemplates = $FALSE;
        }
    }

    $InstallerArguments += ("-AddGlobalTemplates $AddGlobalTemplates");
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

    if ($AcceptConnections -eq 0) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is this Agent able to connect to its parent node for certificate generation?' -Default 'y').result -eq 1) {
            $CanConnectToParent = $TRUE;
        }
    } else {
        $CanConnectToParent = $TRUE;
    }

    if ($CanConnectToParent) {
        if ([string]::IsNullOrEmpty($CAEndpoint)) {
            $CAEndpoint = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the FQDN for either ONE of your Icinga parent node/nodes or your Icinga 2 CA master (if you can connect to it)' -Default 'v').answer;
            $InstallerArguments += "-CAEndpoint $CAEndpoint";
        }
        if ($null -eq $CAPort) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Are you using a different port then 5665 for Icinga communications?' -Default 'n').result -eq 0) {
                $CAPort = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter your port to communicate with the Icinga 2 CA' -Default 'v').answer;
                $InstallerArguments += "-CAPort $CAPort";
            } else {
                $InstallerArguments += "-CAPort 5665";
                $CAPort = 5665;
            }
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
        if ([string]::IsNullOrEmpty($CAFile)) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is your public Icinga 2 CA (ca.crt) available on a local, network or web share?' -Default 'y').result -eq 1) {
                $CAFile = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please provide the full path to your ca.crt file' -Default 'v').answer;
                $InstallerArguments += "-CAFile $CAFile";
            }
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

    if ($InstallerArguments.Count -ne 0) {
        $InstallerArguments += "-RunInstaller";
        Write-Host 'The wizard is complete. These are the configured settings:';
        Write-Host ($InstallerArguments | Out-String);

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
        Get-IcingaAgentInstallCommand -InstallerArguments $InstallerArguments -PrintConsole;
    }

    if ($RunInstaller) {
        if ((Install-IcingaAgent -Version $AgentVersion -Source $PackageSource -AllowUpdates $AllowVersionChanges) -Or $Reconfigure) {
            Move-IcingaAgentDefaultConfig;
            Set-IcingaAgentServiceUser -User $ServiceUser -Password $ServicePass;
            Set-IcingaAgentServicePermission;
            Set-IcingaAcl "$Env:ProgramData\icinga2\etc";
            Set-IcingaAcl "$Env:ProgramData\icinga2\var";
            Set-IcingaAcl (Get-IcingaCacheDir);
            Install-IcingaAgentBaseFeatures;
            Install-IcingaAgentCertificates -Hostname $Hostname -Endpoint $CAEndpoint -Port $CAPort -CACert $CAFile -Ticket $Ticket | Out-Null;
            Write-IcingaAgentApiConfig -Port $CAPort;
            Write-IcingaAgentZonesConfig -Endpoints $Endpoints -EndpointConnections $EndpointConnections -ParentZone $ParentZone -GlobalZones $GlobalZoneConfig -Hostname $Hostname;
            Test-IcingaAgent;
            Restart-Service icinga2;
        }
    }
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
        Write-Host '####'
        Write-Host $Installer -ForegroundColor ([System.ConsoleColor]::Cyan);
        Write-Host '####'
    } else {
        return $Installer;
    }
}

function Get-IcingaAgentInstallerAnswerInput()
{
    param(
        $Prompt,
        [ValidateSet("y","n","v")]
        $Default,
        [switch]$Secure
    );

    $DefaultAnswer = '';

    if ($Default -eq 'y') {
        $DefaultAnswer = ' (Y/n)';
    } elseif ($Default -eq 'n') {
        $DefaultAnswer = ' (y/N)';
    }

    if (-Not $Secure) {
        $answer = Read-Host -Prompt ([string]::Format('{0}{1}', $Prompt, $DefaultAnswer));
    } else {
        $answer = Read-Host -Prompt ([string]::Format('{0}{1}', $Prompt, $DefaultAnswer)) -AsSecureString;
    }

    if ($Default -ne 'v') {
        $answer = $answer.ToLower();

        $returnValue = 0;
        if ([string]::IsNullOrEmpty($answer) -Or $answer -eq $Default) {
            $returnValue = 1;
        } else {
            $returnValue = 0;
        }

        return @{
            'result' = $returnValue;
            'answer' = '';
        }
    }

    return @{
        'result' = 2;
        'answer' = $answer;
    }
}

Export-ModuleMember -Function @( 'Start-IcingaAgentInstallWizard' );
