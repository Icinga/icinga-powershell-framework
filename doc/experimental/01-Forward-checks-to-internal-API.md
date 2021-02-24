# Experimental: Forward Checks to internal API

With Icinga for Windows v1.4.0 we introduced a new experimental feature, allowing to forward executed checks to an internal REST-Api. This will move the check execution from the current PowerShell scope to an internal REST-Api daemon and endpoint and run the command with all provided arguments there.

This will reduce the performance impact on the CPU as well as lower the loading time of the Icinga PowerShell Framework, as only very basic core functionality is required for this.

## Requirements

To use this feature, you wil require the following

* Icinga Agent is certificates installed
* Icinga for Windows v1.4.0 installed
* [Icinga for Windows Service installed](https://icinga.com/docs/icinga-for-windows/latest/doc/service/01-Install-Service/)
* Icinga for Windows v1.4.0 CheckCommand configuration applied (**Important:** Update your entire Windows environment to v1.4.0 before updating the Icinga configuration!)
* [Icinga for Windows REST-Api](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/01-Introduction/)
* [Icinga for Windows Api-Checks](https://github.com/Icinga/icinga-powershell-apichecks/blob/master/doc/01-Introduction.md)

## Install Dependencies

### Additional Modules

At first you will require to install both required modules, the [REST-Api](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/01-Introduction/) and [Api-Checks](https://github.com/Icinga/icinga-powershell-apichecks/blob/master/doc/01-Introduction.md) component.

Like any other Icinga for Windows component, you can use the Framework tools to install them:

```powershell
Install-IcingaFrameworkComponent -Name restapi -Release;
```

```powershell
Install-IcingaFrameworkComponent -Name apichecks -Release;
```

If this does not work for you, please have a look on the [REST-Api installation guide](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/02-Installation/) and [Api-Checks installation guide](https://github.com/Icinga/icinga-powershell-apichecks/blob/master/doc/02-Installation.md).

### Icinga for Windows Service

To make this entire construct work, we will require to install the Icinga for Windows service. You can follow [this guide to install it manually](https://icinga.com/docs/icinga-for-windows/latest/doc/service/01-Install-Service/) if it is not already installed on your machine.

## Register Background Daemon

To access our REST-Api we have to register it as background daemon as mentioned inside the [REST-Api installation guide](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/02-Installation/#daemon-registration).

We can do this by running the command

```powershell
Register-IcingaBackgroundDaemon -Command 'Start-IcingaWindowsRESTApi';
```

By default, it will start listening on Port `5668` and use the Icinga Agents certificates for TLS encrypted communication. As long as the Windows firewall is not allowing access to this port, external communication is not possible.

To modify any REST-Api arguments, please follow the [REST-Api installation guide](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/02-Installation/#daemon-registration).

Last but not least restart the Icinga for Windows service:

```powershell
Restart-Service icingapowershell;
```

## Whitelist Check Commands

By default the Api-Checks module is rejecting every single request to execute commands, as long as they are not whitelisted.

You can whitelist all check commands with an wildcard by using `Invoke-IcingaCheck*` for the `apichecks` module.

```powershell
Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'apichecks';
```

Of course, you can also whitelist every single command without wildcard for more security.

## Blacklist Check Commands

If you do not want to execute certain checks, but keep the previous wildcard whitelist, you can blacklist a single command (or use wildcard to match multiple):

```powershell
Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheckCertificate' -Endpoint 'apichecks' -Blacklist;
```

Blacklists are checked prior to whitelist. If you are running wildcard filters for both, whitelist and blacklist, blacklist entries will win first and block the execution if they match the filter.

## Enable Api Check Feature

Now as we configured our host with all required components, we simply require to enable the api checks feature:

```powershell
Enable-IcingaFrameworkApiChecks;
```

As long as the feature is enabled, the Icinga for Windows service is running, the REST-Api daemon is registered and both modules, [icinga-powershell-restapi](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/01-Introduction/) and [icinga-powershell-apichecks](https://github.com/Icinga/icinga-powershell-apichecks/blob/master/doc/01-Introduction.md) are installed, checks will be forwarded to the REST-Api and executed, if whitelisted.

## Disable Api Check Feature

You can disable the Api check feature anytime by running

```powershell
Disable-IcingaFrameworkApiChecks;
```

Once disabled checks will be executed within the local, current shell and not being forwarded to the API.

## EventLog Errors

In case a check could not be executed by using this experimental feature, either because of timeouts or other issues, they are added with `EventId 1553` inside the EventLog for `Icinga for Windows`. A description on why the check could not be executed is added within the event output.

## Summary

For quick installation, here the list of commands to get everything running:

```powershell
Install-IcingaFrameworkComponent -Name restapi -Release;
Install-IcingaFrameworkComponent -Name apichecks -Release;

Register-IcingaBackgroundDaemon -Command 'Start-IcingaWindowsRESTApi';
Restart-Service icingapowershell;

Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'apichecks';

Enable-IcingaFrameworkApiChecks;
```
