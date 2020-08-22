# Icinga Agent installation wizard

It doesn't matter if you installed the Icinga PowerShell Framework with he [Kickstart Script](01-Kickstart-Script.md) or [Manually](02-Manual-Installation.md). In the and you can use the Icinga Agent installation wizard to configure the system additional, to install the Agent and deploy plugins as well install the Icinga PowerShell Service.

## Start the Icinga Agent wizard

To start the Icinga Agent installation wizard you will have to open a PowerShell as Administrator first and enter

```powershell
Use-Icinga
```

*Note:* Starting with Icinga PowerShell Framework `1.2.0` you can simply type `icinga` to open an Icinga PowerShell Framework shell,

Once the command is executed, the Framework and all required components are loaded. To get started, we can now run

```powershell
Start-IcingaAgentInstallWizard;
```

The wizard will ask a bunch of questions, for example if you are using the semi-automated Director Self-Service API or if you configure everything by yourself.

Depending on how you configure the system, there might different questions occur. The goal of the wizard is to cover most of the possible configurations available for the Icinga Agent. This includes

* How your certificates are generated
* If you Icinga Agent or the Master/Satellites are establishing the connection
* Definition of the service user the Icinga Agent will run with
* Ensuring that the Icinga Agent with the provided configuration and settings is able to start and everything is valid

Once you completed the wizard you are asked if the configuration is correct and if you want to execute the configuration. In any way, you are always printed the configuration command with your configured settings. 
This command can be executed on `any` Windows machine which has the Icinga PowerShell Framework installed. It contains the entire configuration for the system. Of course you can modify the values to match certain network zones or requirements.

## Configuration Command Examples

Below you will find some examples for different kind of configuration commands which can be executed to configure the Icinga Agent and to install plugins.

**Important Note:** Each argument represents a corresponding question during the wizard. Some questions will result in more than one argument being set. In general it is not required to set every single available argument, as some of them are only required if certain configurations are set.

### Config Example 1: Director Self-Service

This example will use the Icinga Director Self-Service API and use a host template key to register the current machine within the Icinga Director and fetch the correct configuration for the host. In addition we will not override any provided variables and convert our Icinga endpoint configuration to actual IPs. For example if our Icinga parent node is registered with address `icinga2-master.example.com` the FQDN will automatically be translated to the referring IP address. This is important as in case of a DNS failure we want to ensure the monitoring is still working properly. In addition we leave the Ticket handling empty as the Self-Service will take care of it and we neither want to install the Plugins nor the Icinga PowerShell Service.

Last but not least we want to directly run the installer.

```powershell
Start-IcingaAgentInstallWizard -SelfServiceAPIKey '56756378658n56t85679765n97649m7649m76' -UseDirectorSelfService 1 -DirectorUrl 'https://example.com/icingaweb2/director/' -OverrideDirectorVars 0 -ConvertEndpointIPConfig 1 -Ticket '' -EmptyTicket 1 -InstallFrameworkPlugins 0 -InstallFrameworkService 0 -RunInstaller;
```

### Config Example 2: Director Self-Service with Argument override

This is the same example as above, but this time we will override our `CAEndpoint` for the Icinga certificate authority:

```powershell
Start-IcingaAgentInstallWizard -SelfServiceAPIKey '56756378658n56t85679765n97649m7649m76' -UseDirectorSelfService 1 -DirectorUrl 'https://example.com/icingaweb2/director/' -OverrideDirectorVars 0 -ConvertEndpointIPConfig 1 -Ticket '' -EmptyTicket 1 -InstallFrameworkPlugins 0 -InstallFrameworkService 0 -CAEndpoint 'icinga2-ca.example.com' -RunInstaller;
```

### Config Example 3: Configure Icinga Agent to connect to Parents and use Cert-Proxy

This example will configure the Icinga Agent to use the local hostname including the FQDN as lower case, download the latest stable version of the Icinga Agent from packages.icinga.com and connect to the parent nodes. As we are not providing a `Ticket` with the installation, we will later have to sign the request on our Icinga master with `icinga2 ca sign <request>` (to get all pending requests you can use `icinga2 ca list` on your Icinga master).

Like before, we are not installing the Icinga PowerShell Service or the plugins in this step.

```powershell
Start-IcingaAgentInstallWizard -UseDirectorSelfService 0 -AutoUseFQDN 1 -AutoUseHostname 0 -LowerCase 1 -UpperCase 0 -AllowVersionChanges 1 -UpdateAgent 1 -AgentVersion 'release' -PackageSource 'https://packages.icinga.com/windows/' -Endpoints icinga2a,icinga2b -CAPort 5665 -AcceptConnections 0 -AddFirewallRule 0 -ConvertEndpointIPConfig 1 -EndpointConnections 192.168.0.1,192.168.0.2 -ParentZone master -AddDirectorGlobal 1 -AddGlobalTemplates 1 -GlobalZones @() -CAEndpoint 192.168.0.1 -Ticket '' -EmptyTicket 1 -ServiceUser 'NT Authority\NetworkService' -InstallFrameworkPlugins 0 -InstallFrameworkService 0 -RunInstaller;
```

### Config Example 4: Install the Icinga PowerShell Service during wizard run

Of course you can install the Icinga PowerShell Service directly during the runtime of the wizard. To do so, take the above examples and `replace` the argument `-InstallFrameworkService 0` with:

```powershell
-InstallFrameworkService 1 -FrameworkServiceUrl 'https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip' -ServiceDirectory 'C:\Program Files\icinga-framework-service\'
```

**Explanation:**

The argument `FrameworkServiceUrl` is asking for a path pointing to the `.zip` file which contains the service binary. The file can either be located on a web resource or a local/network share. The `ServiceDirectory` argument will point to the target on where the `.exe` file itself is being extracted to. This location is then being used to register the Windows Service object to which is later executed. In general there is an additional argument `ServiceBin` available which will define the direct path to the service binary. This can be left empty how ever of the official `.zip` file of Icinga for the service package is used.

### Config Example 5: Install the Icinga Plugins during wizard run

Just like the service you can also directly run the installation of the plugins during the wizard runtime. For this you will have to replace `-InstallFrameworkPlugins 0` of the above mentioned examples with:

```powershell
-InstallFrameworkPlugins 1 -PluginsUrl 'https://github.com/Icinga/icinga-powershell-plugins/archive/master.zip'
```

Just like the service binary, you can specify a different path to the `.zip` file of the plugins. This can either be a web resource or a local/network share path.

## Install Icinga PowerShell Components

Besides installing the Icinga PowerShell Plugins during the installation, you can also install them with a dedicated Cmdlet: `Install-IcingaFrameworkComponent`

This Cmdlet is using a namespace to ensure that the location is handled and each resource can be accessed properly. As with the above mentioned service binary and plugin repository, you can specify a custom location for the `.zip` file include the name of of the repository.

For more details please have a look on the [Icinga Plugin Installation Guide](https://icinga.com/docs/windows/latest/plugins/doc/02-Installation/). This does also apply to every other Icinga Framework Component in the future.
