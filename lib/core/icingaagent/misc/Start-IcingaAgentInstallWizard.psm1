<#
.SYNOPSIS
   A installation wizard that will guide you through the entire installation and
   configuration of Icinga for Windows including the Icinga Agent
.DESCRIPTION
   A installation wizard that will guide you through the entire installation and
   configuration of Icinga for Windows including the Icinga Agent
.FUNCTIONALITY
   Makes initial installation and first configuration of Icinga for Windows and
   the Icinga Agent very easy
.PARAMETER Hostname
   Set a specific hostname to the system and do not lookup anything automatically
.PARAMETER AutoUseFQDN
   Tells the wizard if you want to use the FQDN for the Icinga Agent or not.
   Set it to 1 to use FQDN and 0 to do not use it. Leave it empty to be prompted the wizard question.
   Ignores `AutoUseHostname`
.PARAMETER AutoUseHostname
   Tells the wizard if you want to use the hostname for the Icinga Agent or not.
   Set it to 1 to use hostname only 0 to not use it. Leave it empty to be prompted the wizard question.
   Overwritten by `AutoUseFQDN`
.PARAMETER LowerCase
   Tells the wizard if the provided hostname should be converted to lower case characters.
   Set it to 1 to lower case the name and 0 to do nothing. Leave it empty to be prompted the wizard question
.PARAMETER UpperCase
   Tells the wizard if the provided hostname should be converted to upper case characters.
   Set it to 1 to upper case the name and 0 to do nothing. Leave it empty to be prompted the wizard question
.PARAMETER AddDirectorGlobal
   Tells the wizard to add the `director-global` zone to your Icinga Agent configuration.
   Set it to 1 to add it and 0 to not add it. Leave it empty to be prompted the wizard question
.PARAMETER AddGlobalTemplates
   Tells the wizard to add the `global-templates` zone to your Icinga Agent configuration.
   Set it to 1 to add it and 0 to not add it. Leave it empty to be prompted the wizard question
.PARAMETER PackageSource
   Tells the wizard from which source we can download the Icinga Agent from. Use https://packages.icinga.com/windows/ if you can reach the internet
   Set the source to either web, local or network share. Leave it empty to be prompted the wizard question
.PARAMETER AgentVersion
   Tells the wizard which Icinga Agent version to install. You can provide latest, snapshot or a specific version like 2.11.6
   Set the value to one mentioned above. Leave it empty to be prompted the wizard question
.PARAMETER InstallDir
   Tells the wizard which directory the Icinga Agent will be installed into. Default is `C:\Program Files\ICINGA2`
   Set the value to one mentioned above.
.PARAMETER AllowVersionChanges
   Tells the wizard if the Icinga Agent should be updated/downgraded in case the current/target version are not matching
   Should be equal to `UpdateAgent`
   Set it to 1 to allow updates/downgrades 0 to not allow it. Leave it empty to be prompted the wizard question
.PARAMETER UpdateAgent
   Tells the wizard if the Icinga Agent should be updated/downgraded in case the current/target version are not matching
   Should be equal to `AllowVersionChanges`
   Set it to 1 to allow updates/downgrades 0 to not allow it. Leave it empty to be prompted the wizard question
.PARAMETER AddFirewallRule
   Tells the wizard if the used Icinga Agent port should be opened for incoming traffic on the Windows Firewall
   Set it to 1 to set the firewall rule 0 to do nothing. Leave it empty to be prompted the wizard question
.PARAMETER AcceptConnections
   Tells the wizard if the Icinga Agent is accepting incoming connections.
   Might require `AddFirewallRule` being enabled in case this value is set to 1
   Set it to 1 to accept connections 0 to not accept them. Leave it empty to be prompted the wizard question
.PARAMETER Endpoints
   Tells the wizard which endpoints this Icinga Agent has as parent. Example: master-icinga1, master-icinga2
   Set all parent endpoint names in a comma separated list. Leave it empty to be prompted the wizard question
.PARAMETER EndpointConnections
   Tells the wizard the connection configuration for provided endpoints. The order of this argument has to match
   the endpoint configuration on the `Endpoints` argument. Example: [master-icinga1.example.com]:5665, 192.168.0.5
   Set all parent endpoint connections as comma separated list. Leave it empty to be prompted the wizard question
.PARAMETER ConvertEndpointIPConfig
   Tells the wizard if FQDN for parent connections should be looked up and resolved to IP addresses. Example: example.com => 93.184.216.34
   Set it to 1 to lookup the up and 0 to do nothing. Leave it empty to be prompted the wizard question
.PARAMETER ParentZone
   Tells the wizard which parent zone name to use for Icinga Agent configuration.
   Set it to the name of the parent zone. Leave it empty to be prompted the wizard question
.PARAMETER GlobalZones
   Tells the wizard to add additional global zones to your configuration. You can provide a comma separated list for this
   Add additional global zones as comma separated list, use @() to not add anything. Leave it empty to be prompted the wizard question
.PARAMETER CAEndpoint
   Tells the wizard which address/fqdn to use for Icinga Agent certificate signing.
   Set the IP/FQDN of your CA Server/Icinga parent node or leave it empty if no connection is possible
.PARAMETER CAPort
   Tells the wizard which port to use for Icinga Agent certificate signing.
   Set the port of your CA Server/Icinga parent node or leave it empty if no connection is possible
.PARAMETER Ticket
   Tells the wizard which ticket to use for Icinga Agent certificate signing.
   Set the ticket of your certificate request for this host or leave it empty if no ticket is available.
   If you leave this argument empty, you will have to set `-EmptyTicket` to 1 and otherwise to 0
.PARAMETER EmptyTicket
   Tells the wizard to use a provided `-Ticket` or skip it. If `-Ticket` is empty you do not want to use it,
   set this argument to 1. If you set `-Ticket` with a ticket to use, set this argument to 0
   Leave it empty to be prompted the wizard question
.PARAMETER CAFile
   Tells the wizard if the Icinga CA Server ca.crt shall be used for signing certificate request.
   You can specify a web, local or network share as source to lookup the `ca.crt`.
   If this argument is set to be empty, ensure to also set `-EmptyCA` to 1
.PARAMETER EmptyCA
   Tells the wizard if the argument `-CAFile` is set or not. Set this argument to 1 if `-CAFile` is
   set and to 0 if `-CAFile` is not used
.PARAMETER RunInstaller
   Tells the wizard to skip the question if the configuration is correct and skips the question if you
   want to execute the wizard.
.PARAMETER Reconfigure
   Tells the wizard to execute all arguments again and configure certificates any thing else even if no
   change to the Icinga Agent was made. This is mostly required if you run the wizard again with the same
   Icinga Agent version being installed and available
.PARAMETER ServiceUser
   Tells the wizard which service user should be used for the Icinga Agent and PowerShell Service.
   Add 'NT Authority\NetworkService' to use the default one or specify a custom user
   Leave it empty to be prompted the wizard question.
.PARAMETER ServicePass
   Tells the wizard to use a special password for service users in case you are running a custom user
   instead of local service accounts.
.PARAMETER InstallFrameworkService
   Tells the wizard if you want to install the Icinga PowerShell service
   Set it to 1 to install it and 0 to not install it. Leave it empty to be prompted the wizard question
.PARAMETER FrameworkServiceUrl
   Tells the wizard where to download the Icinga PowerShell Service binary from. Example: https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip
   This argument is only required if `-InstallFrameworkService` is set to 1
.PARAMETER ServiceDirectory
   Tells the wizard where to install the Icinga PowerShell Service binary into. Use `C:\Program Files\icinga-framework-service` as default
   This argument is only required if `-InstallFrameworkService` is set to 1
.PARAMETER ServiceBin
   Tells the wizard the exact path of the service binary. Must match the path of `-ServiceDirectory` and add the binary at the end. Use `C:\Program Files\icinga-framework-service\icinga-service.exe` as default
   This argument is only required if `-InstallFrameworkService` is set to 1
.PARAMETER UseDirectorSelfService
   Tells the wizard to use the Icinga Director Self-Service API.
   Set it to 1 to use the SelfService and 0 to not use it. Leave it empty to prompt the wizard question
.PARAMETER SkipDirectorQuestion
   Tells the wizard to skip all related Icinga Director questions.
   Set it to 1 to skip possible questions and 0 if you continue with Icinga Director. Leave it empty to prompt the wizard question
.PARAMETER DirectorUrl
   Tells the wizard which URL to use for the Icinga Director. Only required if `-UseDirectorSelfService` is set to 1
   Specify the URL targeting your Icinga Director. Leave it empty to prompt the wizard question
.PARAMETER SelfServiceAPIKey
   Tells the wizard which SelfService API key to use for registering this host. In case wizard already run once,
   this argument is always overwritten by the local stored argument. Only required if `-UseDirectorSelfService` is set to 1
   Specify the SelfService API key being used for configuration. Leave it empty to prompt the wizard question in case the registration was not yet done for this host
.PARAMETER OverrideDirectorVars
   Tells the wizard of variables shipped by the Icinga Director SelfService should be overwritten. Only required if `-UseDirectorSelfService` is set to 1
   Set it to 1 to override arguments and 0 to do nothing. Leave it empty to prompt the wizard question
.PARAMETER InstallFrameworkPlugins
   Tells the wizard if you want to install the Icinga PowerShell Plugins
   Set it to 1 to install them and 0 to not install them. Leave it empty to be prompted the wizard question
.PARAMETER PluginsUrl
   Tells the wizard where to download the Icinga PowerShell Plugins from. Example: https://github.com/Icinga/icinga-powershell-plugins/archive/v1.2.0.zip
   This argument is only required if `-InstallFrameworkPlugins` is set to 1
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

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
        [string]$InstallDir,
        $AllowVersionChanges,
        $UpdateAgent                 = $null,
        $AddFirewallRule             = $null,
        $AcceptConnections           = $null,
        [array]$Endpoints            = @(),
        [array]$EndpointConnections  = @(),
        $ConvertEndpointIPConfig     = $null,
        [string]$ParentZone,
        [array]$GlobalZones          = $null,
        [string]$CAEndpoint,
        $CAPort                      = $null,
        [string]$Ticket,
        $EmptyTicket,
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
                -Hostname $Hostname `
                -RunInstaller $RunInstaller;

            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'DirectorUrl' -Value $DirectorUrl -InstallerArguments $InstallerArguments;
            $DirectorUrl         = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'SelfServiceAPIKey' -Value $SelfServiceAPIKey -InstallerArguments $InstallerArguments -Default $null;

            if ([string]::IsNullOrEmpty($Result.Value) -eq $FALSE) {
                $SelfServiceAPIKey   = $Result.Value;
                $InstallerArguments  = $Result.Args;
            }

            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'Ticket' -Value $Ticket -InstallerArguments $InstallerArguments;
            $Ticket                  = $Result.Value;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'PackageSource' -Value $PackageSource -InstallerArguments $InstallerArguments;
            $PackageSource           = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AgentVersion' -Value $AgentVersion -InstallerArguments $InstallerArguments;
            $AgentVersion            = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'InstallDir' -Value $InstallDir -InstallerArguments $InstallerArguments;
            $InstallDir              = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'CAPort' -Value $CAPort -InstallerArguments $InstallerArguments;
            $CAPort                  = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AllowVersionChanges' -Value $AllowVersionChanges -InstallerArguments $InstallerArguments;
            $AllowVersionChanges     = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'GlobalZones' -Value $GlobalZones -InstallerArguments $InstallerArguments;
            $GlobalZones             = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ParentZone' -Value $ParentZone -InstallerArguments $InstallerArguments;
            $ParentZone              = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'CAEndpoint' -Value $CAEndpoint -InstallerArguments $InstallerArguments;
            $CAEndpoint              = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'Endpoints' -Value $Endpoints -InstallerArguments $InstallerArguments;
            $Endpoints               = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddFirewallRule' -Value $AddFirewallRule -InstallerArguments $InstallerArguments;
            $AddFirewallRule         = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AcceptConnections' -Value $AcceptConnections -InstallerArguments $InstallerArguments;
            $AcceptConnections       = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ServiceUser' -Value $ServiceUser -InstallerArguments $InstallerArguments;
            $ServiceUser             = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'UpdateAgent' -Value $UpdateAgent -InstallerArguments $InstallerArguments;
            $UpdateAgent             = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddDirectorGlobal' -Value $AddDirectorGlobal -InstallerArguments $InstallerArguments;
            $AddDirectorGlobal       = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddGlobalTemplates' -Value $AddGlobalTemplates -InstallerArguments $InstallerArguments;
            $AddGlobalTemplates      = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'LowerCase' -Value $LowerCase -Default $FALSE -InstallerArguments $InstallerArguments;
            $LowerCase               = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'UpperCase' -Value $UpperCase -Default $FALSE -InstallerArguments $InstallerArguments;
            $UpperCase               = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AutoUseFQDN' -Value $AutoUseFQDN -Default $FALSE -InstallerArguments $InstallerArguments;
            $AutoUseFQDN             = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AutoUseHostname' -Value $AutoUseHostname -Default $FALSE -InstallerArguments $InstallerArguments;
            $AutoUseHostname         = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'EndpointConnections' -Value $EndpointConnections -InstallerArguments $InstallerArguments;
            $EndpointConnections     = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'OverrideDirectorVars' -Value $OverrideDirectorVars -InstallerArguments $InstallerArguments;
            $OverrideDirectorVars    = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'InstallFrameworkService' -Value $InstallFrameworkService -InstallerArguments $InstallerArguments;
            $InstallFrameworkService = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ServiceDirectory' -Value $ServiceDirectory -InstallerArguments $InstallerArguments;
            $ServiceDirectory        = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'FrameworkServiceUrl' -Value $FrameworkServiceUrl -InstallerArguments $InstallerArguments;
            $FrameworkServiceUrl     = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'InstallFrameworkPlugins' -Value $InstallFrameworkPlugins -InstallerArguments $InstallerArguments;
            $InstallFrameworkPlugins = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'PluginsUrl' -Value $PluginsUrl -InstallerArguments $InstallerArguments;
            $PluginsUrl              = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ConvertEndpointIPConfig' -Value $ConvertEndpointIPConfig -InstallerArguments $InstallerArguments;
            $ConvertEndpointIPConfig = $Result.Value;
            $InstallerArguments      = $Result.Args;
        }
    }

    # 'latest' is deprecated starting with 1.1.0
    if ($AgentVersion -eq 'latest') {
        $AgentVersion = 'release';
        Write-IcingaConsoleWarning -Message 'The value "latest" for the argument "AgentVersion" is deprecated. Please use the value "release" in the future!';
    }

    if ([string]::IsNullOrEmpty($Hostname) -And $null -eq $AutoUseFQDN -And $null -eq $AutoUseHostname) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to specify the hostname manually?' -Default 'n').result -eq 1) {
            $HostFQDN     = Get-IcingaHostname -AutoUseFQDN 1 -AutoUseHostname 0 -LowerCase 1 -UpperCase 0;
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to automatically fetch the hostname as FQDN? (Result: "{0}")', $HostFQDN)) -Default 'y').result -eq 1) {
                $InstallerArguments += '-AutoUseFQDN 1';
                $InstallerArguments += '-AutoUseHostname 0';
                $AutoUseFQDN         = $TRUE;
                $AutoUseHostname     = $FALSE;
            } else {
                $InstallerArguments += '-AutoUseFQDN 0';
                $InstallerArguments += '-AutoUseHostname 1';
                $AutoUseFQDN         = $FALSE;
                $AutoUseHostname     = $TRUE;
            }
            $Hostname = Get-IcingaHostname -AutoUseFQDN $AutoUseFQDN -AutoUseHostname $AutoUseHostname -LowerCase 1 -UpperCase 0;
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to convert the hostname into lower case characters? (Result: "{0}")', $Hostname)) -Default 'y').result -eq 1) {
                $InstallerArguments += '-LowerCase 1';
                $InstallerArguments += '-UpperCase 0';
                $LowerCase = $TRUE;
                $UpperCase = $FALSE;
            } else {
                $Hostname = Get-IcingaHostname -AutoUseFQDN $AutoUseFQDN -AutoUseHostname $AutoUseHostname -LowerCase 0 -UpperCase 1;
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to convert the hostname into upper case characters? (Result: "{0}")', $Hostname)) -Default 'y').result -eq 1) {
                    $InstallerArguments += '-LowerCase 0';
                    $InstallerArguments += '-UpperCase 1';
                    $LowerCase = $FALSE;
                    $UpperCase = $TRUE;
                } else {
                    $InstallerArguments += '-LowerCase 0';
                    $InstallerArguments += '-UpperCase 0';
                    $LowerCase = $FALSE;
                    $UpperCase = $FALSE;
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

    Write-IcingaConsoleNotice ([string]::Format('Using hostname "{0}" for the Icinga Agent configuration', $Hostname));

    $IcingaAgent = Get-IcingaAgentInstallation;
    if ($IcingaAgent.Installed -eq $FALSE) {
        if ([string]::IsNullOrEmpty($PackageSource)) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the Icinga Agent now?' -Default 'y').result -eq 1) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to use a different package source? (Defaults: "https://packages.icinga.com/windows/")' -Default 'n').result -eq 0) {
                    $PackageSource = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your package source' -Default 'v').answer;
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                } else {
                    $PackageSource = 'https://packages.icinga.com/windows/'
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                }

                Write-IcingaConsoleNotice ([string]::Format('Using package source "{0}" for the Icinga Agent package', $PackageSource));
                $AllowVersionChanges = $TRUE;
                $InstallerArguments += '-AllowVersionChanges 1';

                if ([string]::IsNullOrEmpty($AgentVersion)) {
                    $AgentVersion = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the version you want to install ("release", "snapshot" or a specific version like "2.11.3")' -Default 'v' -DefaultInput 'release').answer;
                    $InstallerArguments += "-AgentVersion '$AgentVersion'";

                    Write-IcingaConsoleNotice ([string]::Format('Installing Icinga version: "{0}"', $AgentVersion));
                }
            } else {
                $AllowVersionChanges = $FALSE;
                $InstallerArguments += '-AllowVersionChanges 0';
                $InstallerArguments += "-AgentVersion '$AgentVersion'";
                $AgentVersion        = '';
            }
        }
    } else {
        if ($null -eq $UpdateAgent) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'The Icinga Agent is already installed. Would you like to update it?' -Default 'y').result -eq 1) {
                $UpdateAgent = 1;
                $AllowVersionChanges = $TRUE;
                $InstallerArguments += '-AllowVersionChanges 1';
            } else {
                $UpdateAgent = 0;
                $AllowVersionChanges = $FALSE;
                $InstallerArguments += '-AllowVersionChanges 0';
            }
            $InstallerArguments += "-UpdateAgent $UpdateAgent";
        }

        if ($UpdateAgent -eq 1) {
            if ([string]::IsNullOrEmpty($AgentVersion)) {
                $AgentVersion = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the version you want to install ("release", "snapshot" or a specific version like "2.11.3")' -Default 'v' -DefaultInput 'release').answer;
                $InstallerArguments += "-AgentVersion '$AgentVersion'";

                Write-IcingaConsoleNotice ([string]::Format('Updating/Downgrading Icinga 2 Agent to version: "{0}"', $AgentVersion));
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

    if ($Endpoints.Count -eq 0) {
        $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the parent node(s) separated by "," (Examples: "master1, master2" or "master1.example.com, master2.example.com")' -Default 'v').answer;
        $Endpoints = ($ArrayString.Replace(' ', '')).Split(',');
        $InstallerArguments += ("-Endpoints " + ([string]::Join(',', $Endpoints)));
    }

    if ($null -eq $CAPort) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Are you using another port than 5665 for Icinga communication?' -Default 'n').result -eq 0) {
            $CAPort = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the port for Icinga communication' -Default 'v' -DefaultInput '5665').answer;
            $InstallerArguments += "-CAPort $CAPort";
        } else {
            $InstallerArguments += "-CAPort 5665";
            $CAPort = 5665;
        }
    }

    [bool]$CanConnectToParent = $FALSE;

    if ($null -eq $AcceptConnections) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt "Is this Agent able to connect to its parent node(s)?" -Default 'y').result -eq 1) {
            $CanConnectToParent = $TRUE;
            $AcceptConnections = 0;
            $InstallerArguments += ("-AcceptConnections 0");
        } else {
            $AcceptConnections = 1;
            $InstallerArguments += ("-AcceptConnections 1");
        }
    } else {
        if ((Test-IcingaWizardArgument -Argument 'AcceptConnections') -eq $FALSE) {
            $InstallerArguments += ([string]::Format('-AcceptConnections {0}', [int]$AcceptConnections));
        }

        if ($AcceptConnections -eq $FALSE) {
            $CanConnectToParent = $TRUE;
        }
    }

    if ($null -eq $AddFirewallRule -And $CanConnectToParent -eq $FALSE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to open the Windows Firewall for incoming traffic on Port "{0}"?', $CAPort)) -Default 'y').result -eq 1) {
            $InstallerArguments += "-AddFirewallRule 1";
            $AddFirewallRule = $TRUE;
        } else {
            $InstallerArguments += "-AddFirewallRule 0";
            $AddFirewallRule = $FALSE;
        }
    } else {
        if ($CanConnectToParent -eq $TRUE) {
            $InstallerArguments += "-AddFirewallRule 0";
            $AddFirewallRule = $FALSE;
        }
    }

    if ($null -eq $ConvertEndpointIPConfig -And $CanConnectToParent -eq $TRUE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to convert parent node(s) connection data to IP addresses?' -Default 'y').result -eq 1) {
            $InstallerArguments     += "-ConvertEndpointIPConfig 1";
            $ConvertEndpointIPConfig = $TRUE;
            if ($EndpointConnections.Count -eq 0) {
                $EndpointsConversion = Convert-IcingaEndpointsToIPv4 -NetworkConfig $Endpoints.Split(',');
            } else {
                $EndpointsConversion = Convert-IcingaEndpointsToIPv4 -NetworkConfig $EndpointConnections;
            }
            if ($EndpointsConversion.HasErrors) {
                Write-IcingaConsoleWarning -Message 'Not all of your endpoint connection data could be resolved. These endpoints were dropped: {0}' -Objects ([string]::Join(', ', $EndpointsConversion.Unresolved));
            }
            $EndpointConnections     = $EndpointsConversion.Network;
        } else {
            $InstallerArguments     += "-ConvertEndpointIPConfig 0";
            $ConvertEndpointIPConfig = $FALSE;
        }
    }

    if ($EndpointConnections.Count -eq 0 -And $AcceptConnections -eq 0) {
        $NetworkDefault = '';
        foreach ($Endpoint in $Endpoints) {
            $NetworkDefault += [string]::Format('[{0}]:{1},', $Endpoint, $CAPort);
        }
        if ([string]::IsNullOrEmpty($NetworkDefault) -eq $FALSE) {
            $NetworkDefault = $NetworkDefault.Substring(0, $NetworkDefault.Length - 1);
        }
        $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the network destinations this Agent will connect to separated by "," (Examples: 192.168.0.1, [192.168.0.2]:5665, [icinga2.example.com]:5665)' -Default 'v' -DefaultInput $NetworkDefault).answer;
        $EndpointConnections = ($ArrayString.Replace(' ', '')).Split(',');

        if ($ConvertEndpointIPConfig) {
            $EndpointsConversion = Convert-IcingaEndpointsToIPv4 -NetworkConfig $EndpointConnections.Split(',');
            if ($EndpointsConversion.HasErrors -eq $FALSE) {
                $EndpointConnections = $EndpointsConversion.Network;
            }
        }
        $InstallerArguments += ("-EndpointConnections " + ([string]::Join(',', $EndpointConnections)));
    } elseif ($EndpointConnections.Count -ne 0 -And $AcceptConnections -eq 0 -And $ConvertEndpointIPConfig) {
        $EndpointsConversion = Convert-IcingaEndpointsToIPv4 -NetworkConfig $EndpointConnections;
        if ($EndpointsConversion.HasErrors) {
            Write-IcingaConsoleWarning -Message 'Not all of your endpoint connection data could be resolved. These endpoints were dropped: {0}' -Objects ([string]::Join(', ', $EndpointsConversion.Unresolved));
        }
        $EndpointConnections = $EndpointsConversion.Network;
    }

    if ([string]::IsNullOrEmpty($ParentZone)) {
        $ParentZone = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the parent zone this Agent will connect to' -Default 'v' -DefaultInput 'master').answer;
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
            $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your additional zones separated by "," (Example: "global-zone1, global-zone2")' -Default 'v').answer;
            if ([string]::IsNullOrEmpty($ArrayString) -eq $FALSE) {
                $GlobalZones = ($ArrayString.Replace(' ', '')).Split(',')
                $GlobalZoneConfig += $GlobalZones;
                $InstallerArguments += ("-GlobalZones " + ([string]::Join(',', $GlobalZones)));
            } else {
                $GlobalZones = @();
                $InstallerArguments += ("-GlobalZones @()");
            }
        } else {
            $GlobalZones = @();
            $InstallerArguments += ("-GlobalZones @()");
        }
    } else {
        $GlobalZoneConfig += $GlobalZones;
    }

    if ($CanConnectToParent) {
        if ([string]::IsNullOrEmpty($CAEndpoint)) {
            $CAEndpoint = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the connection data of the parent node that handles certificate requests' -Default 'v' -DefaultInput (Get-IPConfigFromString $EndpointConnections[0]).address).answer;
            $InstallerArguments += "-CAEndpoint $CAEndpoint";
        }
        if ([string]::IsNullOrEmpty($Ticket) -And $null -eq $EmptyTicket) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you have a PKI Ticket to sign your certificate request?' -Default 'y').result -eq 1) {
                $Ticket = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter your PKI Ticket' -Default 'v').answer;
                if ([string]::IsNullOrEmpty($Ticket)) {
                    $InstallerArguments += "-EmptyTicket 1"
                } else {
                    $InstallerArguments += "-EmptyTicket 0"
                }
                $InstallerArguments += "-Ticket '$Ticket'";
            } else {
                $InstallerArguments += "-Ticket ''";
                $InstallerArguments += "-EmptyTicket 1"
            }
        } else {
            if ([string]::IsNullOrEmpty($Ticket)) {
                $InstallerArguments += "-Ticket ''";
            } else {
                $InstallerArguments += "-Ticket '$Ticket'";
            }
            if ($null -eq $EmptyTicket) {
                $InstallerArguments += "-EmptyTicket 1"
            } else {
                $InstallerArguments += "-EmptyTicket $EmptyTicket"
            }
        }
    } else {
        if ([string]::IsNullOrEmpty($CAFile) -And $null -eq $EmptyCA) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is your public Icinga 2 CA (ca.crt) available on a local, network or web share?' -Default 'y').result -eq 1) {
                $CAFile = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please provide the full path to your ca.crt file (Examples: "C:\icinga2\ca.crt", "https://icinga.example.com/ca.crt"' -Default 'v').answer;
                if ([string]::IsNullOrEmpty($CAFile)) {
                    $InstallerArguments += "-EmptyCA 1"
                } else {
                    $InstallerArguments += "-EmptyCA 0"
                }
                $InstallerArguments += "-CAFile '$CAFile'";
            } else {
                $InstallerArguments += "-CAFile ''";
                $InstallerArguments += "-EmptyCA 1";
                $EmptyCA             = $TRUE;
            }
        } else {
            if ([string]::IsNullOrEmpty($CAFile)) {
                $InstallerArguments += "-CAFile ''";
            } else {
                $InstallerArguments += "-CAFile '$CAFile'";
            }
            if ($null -eq $EmptyCA) {
                $InstallerArguments += "-EmptyCA 1"
            } else {
                $InstallerArguments += "-EmptyCA $EmptyCA"
            }
        }
    }

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to change the user of the Icinga Agent service? (Defaults: "NT Authority\NetworkService")' -Default 'n').result -eq 0) {
            $ServiceUser = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter a custom user for the Icinga Agent service' -Default 'v' -DefaultInput 'NT Authority\NetworkService').answer;
            $InstallerArguments += "-ServiceUser $ServiceUser";
            if ($null -eq $ServicePass) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Does your Icinga Agent service user require a password to login? (Not required for System users)' -Default 'y').result -eq 1) {
                    $ServicePass = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the password for your service user' -Secure -Default 'v').answer;
                    $InstallerArguments += "-ServicePass $ServicePass";
                } else {
                    $ServicePass         = $null
                    $InstallerArguments += '-ServicePass $null';
                }
            }
        } else {
            $InstallerArguments += "-ServiceUser 'NT Authority\NetworkService'";
            $ServiceUser = 'NT Authority\NetworkService';
        }
    }

    if ($null -eq $InstallFrameworkPlugins) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the Icinga PowerShell Plugins?' -Default 'y').result -eq 1) {
            $result = Install-IcingaFrameworkPlugins -PluginsUrl $PluginsUrl;
            $PluginsUrl = $result.PluginUrl;
            $InstallerArguments += "-InstallFrameworkPlugins 1";
            $InstallerArguments += "-PluginsUrl '$PluginsUrl'";
        } else {
            $InstallerArguments += "-InstallFrameworkPlugins 0";
        }
    } elseif ($InstallFrameworkPlugins -eq 1) {
        $result = Install-IcingaFrameworkPlugins -PluginsUrl $PluginsUrl;
        $InstallerArguments += "-InstallFrameworkPlugins 1";
        $InstallerArguments += "-PluginsUrl '$PluginsUrl'";
    } else {
        if ((Test-IcingaWizardArgument -Argument 'InstallFrameworkPlugins') -eq $FALSE) {
            $InstallerArguments += "-InstallFrameworkPlugins 0";
        }
    }

    if ($null -eq $InstallFrameworkService) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the Icinga PowerShell Framework as a service?' -Default 'y').result -eq 1) {
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
        Write-IcingaConsoleNotice 'The wizard is complete. These are the configured settings:';

        Write-IcingaConsolePlain '========';
        Write-IcingaConsolePlain ($InstallerArguments | Out-String);
        Write-IcingaConsolePlain '========';

        if (-Not $RunInstaller) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is this configuration correct?' -Default 'y').result -eq 1) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to run the installer now? (Otherwise only the configuration command will be printed)' -Default 'y').result -eq 1) {
                    Write-IcingaConsoleNotice 'To execute your Icinga Agent installation based on your answers again on this or another machine, simply run this command:';

                    $RunInstaller = $TRUE;
                } else {
                    Write-IcingaConsoleNotice 'To execute your Icinga Agent installation based on your answers, simply run this command:';
                }
            } else {
                Write-IcingaConsoleNotice 'Please run the wizard again to modify your answers or modify the command below:';
            }
        }
        Get-IcingaAgentInstallCommand -InstallerArguments $InstallerArguments -PrintConsole;
    }

    if ($RunInstaller) {
        if ((Test-IcingaAgentNETFrameworkDependency) -eq $FALSE) {
            Write-IcingaConsoleError -Message 'You cannot install the Icinga Agent on this system as the required .NET Framework version is not installed. Please install .NET Framework 4.6.0 or later and use the above provided install arguments to try again.'
            return;
        }

        if ((Install-IcingaAgent -Version $AgentVersion -Source $PackageSource -AllowUpdates $AllowVersionChanges -InstallDir $InstallDir) -Or $Reconfigure) {
            Reset-IcingaAgentConfigFile;
            Move-IcingaAgentDefaultConfig;
            Set-IcingaAgentNodeName -Hostname $Hostname;
            Set-IcingaServiceUser -User $ServiceUser -Password $ServicePass -SetPermission | Out-Null;
            if ($InstallFrameworkService) {
                Install-IcingaForWindowsService -Path $ServiceBin -User $ServiceUser -Password $ServicePass | Out-Null;
            }
            Register-IcingaBackgroundDaemon -Command 'Start-IcingaServiceCheckDaemon';
            Install-IcingaAgentBaseFeatures;
            $CertsInstalled = Install-IcingaAgentCertificates -Hostname $Hostname -Endpoint $CAEndpoint -Port $CAPort -CACert $CAFile -Ticket $Ticket;
            Write-IcingaAgentApiConfig -Port $CAPort;
            if ($EmptyCA -eq $TRUE -And $CertsInstalled -eq $FALSE) {
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
            Write-IcingaAgentZonesConfig -Endpoints $Endpoints -EndpointConnections $EndpointConnections -ParentZone $ParentZone -GlobalZones $GlobalZoneConfig -Hostname $Hostname;
            if ($AddFirewallRule) {
                # First cleanup the system by removing all old Firewalls
                Enable-IcingaFirewall -IcingaPort $CAPort -Force;
            }
            Test-IcingaAgent;
            if ($InstallFrameworkService) {
                Restart-IcingaWindowsService;
            }
            Restart-IcingaService 'icinga2';
        }
    }
}

function Add-InstallerArgument()
{
    param(
        $InstallerArguments,
        [string]$Key,
        $Value,
        [switch]$ReturnValue
    );

    [bool]$IsArray = $Value -is [array];

    # Check for arrays
    if ($IsArray) {
        [array]$NewArray = @();
        foreach ($entry in $Value) {
            $NewArray += Add-InstallerArgument -Value $entry -ReturnValue;
        }

        if ($ReturnValue) {
            return ([string]::Join(',', $NewArray));
        }

        $InstallerArguments += [string]::Format(
            '-{0} {1}',
            $Key,
            [string]::Join(',', $NewArray)
        );

        return $InstallerArguments;
    }

    # Check for integers
    if (Test-Numeric $Value) {
        if ($ReturnValue) {
            return $Value;
        }

        $InstallerArguments += [string]::Format(
            '-{0} {1}',
            $Key,
            $Value
        );

        return $InstallerArguments;
    }

    # Check for integer conversion
    $IntValue = ConvertTo-Integer -Value $Value;
    if ([string]$Value -ne [string]$IntValue) {
        if ($ReturnValue) {
            return $IntValue;
        }

        $InstallerArguments += [string]::Format(
            '-{0} {1}',
            $Key,
            $IntValue
        );

        return $InstallerArguments;
    }

    $Type     = $Value.GetType().Name;
    $NewValue = $null;

    if ($Type -eq 'String') {
        $NewValue = [string]::Format(
            "'{0}'",
            $Value
        );

        if ($ReturnValue) {
            return $NewValue;
        }

        $InstallerArguments += [string]::Format(
            '-{0} {1}',
            $Key,
            $NewValue
        );

        return $InstallerArguments;
    }
}

function Test-IcingaWizardArgument()
{
    param(
        [string]$Argument
    );

    foreach ($entry in $InstallerArguments) {
        if ($entry -like [string]::Format('-{0} *', $Argument)) {
            return $TRUE;
        }
    }

    return $FALSE;
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

        $InstallerArguments = Add-InstallerArgument `
            -InstallerArguments $InstallerArguments `
            -Key $WizardArg `
            -Value $DirectorArgs.Overrides[$WizardArg];

        return @{
            'Value' = $DirectorArgs.Overrides[$WizardArg];
            'Args'  = $InstallerArguments;
        };
    }

    $RetValue = $null;

    if ($DirectorArgs.Arguments.ContainsKey($WizardArg)) {
        $RetValue = $DirectorArgs.Arguments[$WizardArg];
    } else {

        if ($null -ne $Value -And [string]::IsNullOrEmpty($Value) -eq $FALSE) {
            $InstallerArguments = Add-InstallerArgument `
                -InstallerArguments $InstallerArguments `
                -Key $WizardArg `
                -Value $Value;

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

        $InstallerArguments = Add-InstallerArgument `
            -InstallerArguments $InstallerArguments `
            -Key $WizardArg `
            -Value $Value;

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
        Write-IcingaConsolePlain '===='
        Write-IcingaConsolePlain $Installer;
        Write-IcingaConsolePlain '===='
    } else {
        return $Installer;
    }
}
