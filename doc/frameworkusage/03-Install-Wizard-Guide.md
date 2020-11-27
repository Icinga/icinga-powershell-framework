# Install Wizard Guide

The Icinga for Windows installation wizard can be started with `Start-IcingaAgentInstallWizard`. In case you only execute the command, the wizard will prompt you with a bunch of questions to configure Icinga for Windows and the Icinga Agent properly.

## Configuration Methods

The wizard is designed to catch every possible configuration for the Icinga Agent, regardless if communication to parent nodes is possible or not, or certificate generation is handled differently.

In addition you can define if you want to use the Icinga Director SelfService API or if the entire configuration is done by using local arguments provided or even a mix of both worlds.

## Example 1: Use Icinga Director SelfService API

Fetches all information on how to configure the Icinga Agent of the SelfService API and installs the Icinga PowerShell Plugins as well as the Icinga PowerShell Service. Possible FQDN entries for connections will be resolved to IP addresses:

```powershell
Start-IcingaAgentInstallWizard `
    -SelfServiceAPIKey 'your template API key' `
    -UseDirectorSelfService 1 `
    -DirectorUrl 'https://example.com/icingaweb2/director/' `
    -OverrideDirectorVars 0 `
    -ConvertEndpointIPConfig 1 `
    -Ticket '' `
    -EmptyTicket 1 `
    -InstallFrameworkPlugins 1 `
    -PluginsUrl 'https://github.com/Icinga/icinga-powershell-plugins/archive/v1.2.0.zip' `
    -InstallFrameworkService 1 `
    -FrameworkServiceUrl 'https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip' `
    -ServiceDirectory 'C:\Program Files\icinga-framework-service\' `
    -ServiceBin 'C:\Program Files\icinga-framework-service\icinga-service.exe' `
    -RunInstaller;
```

## Example 2: Configure Icinga Agent to connect to parents

In this scenario we will connect to our parent Icinga nodes and use the FQQN of our hostname as object name for Icinga 2.

**Note:** If you do not set a ticket with `-Ticket`, you will have to set `-EmptyTicket` to 1

```powershell
Start-IcingaAgentInstallWizard `
    -AutoUseFQDN 1 `
    -AutoUseHostname 0 `
    -LowerCase 1 `
    -UpperCase 0 `
    -UseDirectorSelfService 0 `
    -OverrideDirectorVars 0 `
    -SkipDirectorQuestion 1 `
    -ConvertEndpointIPConfig 1 `
    -Endpoints 'icinga2-master-1', 'icinga2-master-2' `
    -EndpointConnections '[icinga2-master-1.example.com]:5665', '[icinga2-master-2.example.com]:5665' `
    -ParentZone 'master' `
    -CAEndpoint 'icinga2-master-1.example.com' `
    -CAPort '5665' `
    -AddDirectorGlobal 1 `
    -AddGlobalTemplates 1 `
    -GlobalZones @() `
    -Ticket 'enter your ticket of leave empty for signing on CA master' `
    -EmptyTicket 0 `
    -PackageSource 'https://packages.icinga.com/windows/' `
    -AgentVersion 'release' `
    -AllowVersionChanges 1 `
    -UpdateAgent 1 `
    -ServiceUser 'NT Authority\NetworkService' `
    -AddFirewallRule 0 `
    -AcceptConnections 0 `
    -InstallFrameworkPlugins 1 `
    -PluginsUrl 'https://github.com/Icinga/icinga-powershell-plugins/archive/v1.2.0.zip' `
    -InstallFrameworkService 1 `
    -FrameworkServiceUrl 'https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip' `
    -ServiceDirectory 'C:\Program Files\icinga-framework-service\' `
    -ServiceBin 'C:\Program Files\icinga-framework-service\icinga-service.exe' `
    -RunInstaller;
```

## Example 3: Configure Icinga Agent to receive connections only

In this scenario we will receive connections from our parent Icinga nodes and use the FQQN of our hostname as object name for Icinga 2.

```powershell
Start-IcingaAgentInstallWizard `
    -AutoUseFQDN 1 `
    -AutoUseHostname 0 `
    -LowerCase 1 `
    -UpperCase 0 `
    -UseDirectorSelfService 0 `
    -OverrideDirectorVars 0 `
    -SkipDirectorQuestion 1 `
    -ConvertEndpointIPConfig 0 `
    -Endpoints 'icinga2-master-1', 'icinga2-master-2' `
    -ParentZone 'master' `
    -CAPort '5665' `
    -EmptyCA 1 `
    -AddDirectorGlobal 1 `
    -AddGlobalTemplates 1 `
    -GlobalZones @() `
    -Ticket '' `
    -EmptyTicket 1 `
    -PackageSource 'https://packages.icinga.com/windows/' `
    -AgentVersion 'release' `
    -AllowVersionChanges 1 `
    -UpdateAgent 1 `
    -ServiceUser 'NT Authority\NetworkService' `
    -AddFirewallRule 1 `
    -AcceptConnections 1 `
    -InstallFrameworkPlugins 1 `
    -PluginsUrl 'https://github.com/Icinga/icinga-powershell-plugins/archive/v1.2.0.zip' `
    -InstallFrameworkService 1 `
    -FrameworkServiceUrl 'https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip' `
    -ServiceDirectory 'C:\Program Files\icinga-framework-service\' `
    -ServiceBin 'C:\Program Files\icinga-framework-service\icinga-service.exe' `
    -RunInstaller;
```

## Arguments

Of course, you can customize the above wizard depending on your requirements. A list of all available arguments can be found in this table:

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Hostname | String | false |  | Set a specific hostname to the system and do not lookup anything automatically |
| AutoUseFQDN | Object | false |  | Tells the wizard if you want to use the FQDN for the Icinga Agent or not. Set it to 1 to use FQDN and 0 to do not use it. Leave it empty to be prompted the wizard question. Ignores `AutoUseHostname` |
| AutoUseHostname | Object | false |  | Tells the wizard if you want to use the hostname for the Icinga Agent or not. Set it to 1 to use hostname only 0 to not use it. Leave it empty to be prompted the wizard question. Overwritten by `AutoUseFQDN` |
| LowerCase | Object | false |  | Tells the wizard if the provided hostname should be converted to lower case characters. Set it to 1 to lower case the name and 0 to do nothing. Leave it empty to be prompted the wizard question |
| UpperCase | Object | false |  | Tells the wizard if the provided hostname should be converted to upper case characters. Set it to 1 to upper case the name and 0 to do nothing. Leave it empty to be prompted the wizard question |
| AddDirectorGlobal | Object | false |  | Tells the wizard to add the `director-global` zone to your Icinga Agent configuration. Set it to 1 to add it and 0 to not add it. Leave it empty to be prompted the wizard question |
| AddGlobalTemplates | Object | false |  | Tells the wizard to add the `global-templates` zone to your Icinga Agent configuration. Set it to 1 to add it and 0 to not add it. Leave it empty to be prompted the wizard question |
| PackageSource | String | false |  | Tells the wizard from which source we can download the Icinga Agent from. Use https://packages.icinga.com/windows/ if you can reach the internet Set the source to either web, local or network share. Leave it empty to be prompted the wizard question |
| AgentVersion | String | false |  | Tells the wizard which Icinga Agent version to install. You can provide latest, snapshot or a specific version like 2.11.6 Set the value to one mentioned above. Leave it empty to be prompted the wizard question |
| InstallDir | String | false |  | Tells the wizard which directory the Icinga Agent will beinstalled into. Default is `C:\Program Files\ICINGA2` Set the value to one mentioned above. |
| AllowVersionChanges | Object | false |  | Tells the wizard if the Icinga Agent should be updated/downgraded in case the current/target version are not matching Should be equal to `UpdateAgent` Set it to 1 to allow updates/downgrades 0 to not allow it. Leave it empty to be prompted the wizard question |
| UpdateAgent | Object | false |  | Tells the wizard if the Icinga Agent should be updated/downgraded in case the current/target version are not matching Should be equal to `AllowVersionChanges` Set it to 1 to allow updates/downgrades 0 to not allow it. Leave it empty to be prompted the wizard question |
| AddFirewallRule | Object | false |  | Tells the wizard if the used Icinga Agent port should be opened for incoming traffic on the Windows Firewall Set it to 1 to set the firewall rule 0 to do nothing. Leave it empty to be prompted the wizard question |
| AcceptConnections | Object | false |  | Tells the wizard if the Icinga Agent is accepting incoming connections. Might require `AddFirewallRule` being enabled in case this value is set to 1 Set it to 1 to accept connections 0 to not accept them. Leave it empty to be prompted the wizard question |
| Endpoints | Array | false | @() | Tells the wizard which endpoints this Icinga Agent has as parent. Example: master-icinga1, master-icinga2 Set all parent endpoint names in a comma separated list. Leave it empty to be prompted the wizard question |
| EndpointConnections | Array | false | @() | Tells the wizard the connection configuration for provided endpoints. The order of this argument has to match the endpoint configuration on the `Endpoints` argument. Example: [master-icinga1.example.com]:5665, 192.168.0.5 Set all parent endpoint connections as comma separated list. Leave it empty to be prompted the wizard question |
| ConvertEndpointIPConfig | Object | false |  | Tells the wizard if FQDN for parent connections should be looked up and resolved to IP addresses. Example: example.com => 93.184.216.34 Set it to 1 to lookup the up and 0 to do nothing. Leave it empty to be prompted the wizard question |
| ParentZone | String | false |  | Tells the wizard which parent zone name to use for Icinga Agent configuration. Set it to the name of the parent zone. Leave it empty to be prompted the wizard question |
| GlobalZones | Array | false |  | Tells the wizard to add additional global zones to your configuration. You can provide a comma separated list for this Add additional global zones as comma separated list, use @() to not add anything. Leave it empty to be prompted the wizard question |
| CAEndpoint | String | false |  | Tells the wizard which address/fqdn to use for Icinga Agent certificate signing. Set the IP/FQDN of your CA Server/Icinga parent node or leave it empty if no connection is possible |
| CAPort | Object | false |  | Tells the wizard which port to use for Icinga Agent certificate signing. Set the port of your CA Server/Icinga parent node or leave it empty if no connection is possible |
| Ticket | String | false |  | Tells the wizard which ticket to use for Icinga Agent certificate signing. Set the ticket of your certificate request for this host or leave it empty if no ticket is available. If you leave this argument empty, you will have to set `-EmptyTicket` to 1 and otherwise to 0 |
| EmptyTicket | Object | false |  | Tells the wizard to use a provided `-Ticket` or skip it. If `-Ticket` is empty you do not want to use it, set this argument to 1. If you set `-Ticket` with a ticket to use, set this argument to 0 Leave it empty to be prompted the wizard question |
| CAFile | String | false |  | Tells the wizard if the Icinga CA Server ca.crt shall be used for signing certificate request. You can specify a web, local or network share as source to lookup the `ca.crt`. If this argument is set to be empty, ensure to also set `-EmptyCA` to 1 |
| EmptyCA | Object | false |  | Tells the wizard if the argument `-CAFile` is set or not. Set this argument to 1 if `-CAFile` is set and to 0 if `-CAFile` is not used |
| RunInstaller | SwitchParameter | false | False | Tells the wizard to skip the question if the configuration is correct and skips the question if you want to execute the wizard. |
| Reconfigure | SwitchParameter | false | False | Tells the wizard to execute all arguments again and configure certificates any thing else even if no change to the Icinga Agent was made. This is mostly required if you run the wizard again with the same Icinga Agent version being installed and available |
| ServiceUser | String | false |  | Tells the wizard which service user should be used for the Icinga Agent and PowerShell Service. Add `NT Authority\NetworkService` to use the default one or specify a custom user Leave it empty to be prompted the wizard question. |
| ServicePass | SecureString | false |  | Tells the wizard to use a special password for service users in case you are running a custom user instead of local service accounts. |
| InstallFrameworkService | Object | false |  | Tells the wizard if you want to install the Icinga PowerShell service Set it to 1 to install it and 0 to not install it. Leave it empty to be prompted the wizard question |
| FrameworkServiceUrl | Object | false |  | Tells the wizard where to download the Icinga PowerShell Service binary from. Example: https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip This argument is only required if `-InstallFrameworkService` is set to 1 |
| ServiceDirectory | Object | false |  | Tells the wizard where to install the Icinga PowerShell Service binary into. Use `C:\Program Files\icinga-framework-service` as default This argument is only required if `-InstallFrameworkService` is set to 1 |
| ServiceBin | Object | false |  | Tells the wizard the exact path of the service binary. Must match the path of `-ServiceDirectory` and add the binary at the end. Use `C:\Program Files\icinga-framework-service\icinga-service.exe` as default This argument is only required if `-InstallFrameworkService` is set to 1 |
| UseDirectorSelfService | Object | false |  | Tells the wizard to use the Icinga Director Self-Service API. Set it to 1 to use the SelfService and 0 to not use it. Leave it empty to prompt the wizard question |
| SkipDirectorQuestion | Boolean | false | False | Tells the wizard to skip all related Icinga Director questions. Set it to 1 to skip possible questions and 0 if you continue with Icinga Director. Leave it empty to prompt the wizard question |
| DirectorUrl | String | false |  | Tells the wizard which URL to use for the Icinga Director. Only required if `-UseDirectorSelfService` is set to 1 Specify the URL targeting your Icinga Director. Leave it empty to prompt the wizard question |
| SelfServiceAPIKey | String | false |  | Tells the wizard which SelfService API key to use for registering this host. In case wizard already run once, this argument is always overwritten by the local stored argument. Only required if `-UseDirectorSelfService` is set to 1 Specify the SelfService API key being used for configuration. Leave it empty to prompt the wizard question in case the registration was not yet done for this host |
| OverrideDirectorVars | Object | false |  | Tells the wizard of variables shipped by the Icinga Director SelfService should be overwritten. Only required if `-UseDirectorSelfService` is set to 1 Set it to 1 to override arguments and 0 to do nothing. Leave it empty to prompt the wizard question |
| InstallFrameworkPlugins | Object | false |  | Tells the wizard if you want to install the Icinga PowerShell Plugins Set it to 1 to install them and 0 to not install them. Leave it empty to be prompted the wizard question |
| PluginsUrl | Object | false |  | Tells the wizard where to download the Icinga PowerShell Plugins from. Example: https://github.com/Icinga/icinga-powershell-plugins/archive/v1.2.0.zip This argument is only required if `-InstallFrameworkPlugins` is set to 1 |
