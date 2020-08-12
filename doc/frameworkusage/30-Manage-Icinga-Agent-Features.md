# Manage Icinga Agent Features

The Icinga PowerShell Framework is shipping wish a bunch of Cmdlets to manage the Icinga Agent in a very easy way. This includes the managing for features enabled or disabled for the Icinga Agent.

**Note:** Before using any of the commands below you will have to initialize the Icinga PowerShell Framework inside a new PowerShell instance with `Use-Icinga`. Starting with version `1.2.0` of the Framework you can also simply type `icinga` into the command line.

## List Icinga Agent Features

To view a list of currently enabled and disabled features, you can use the command `Get-IcingaAgentFeatures`:

```powershell
Get-IcingaAgentFeatures;
```

```text
Name                           Value
----                           -----
Disabled                       {api, checker, debuglog, elasticsearch...}
Enabled                        {mainlog}
```

For a full list you can directly access each object:

```powershell
(Get-IcingaAgentFeatures).Disabled;
```

```text
api
checker
debuglog
elasticsearch
gelf
graphite
influxdb
notification
opentsdb
perfdata
```

```powershell
(Get-IcingaAgentFeatures).Enabled;
```

```text
mainlog
```

## Enable Icinga Agent Features

To simply enable an Icinga Agent feature you can use `Enable-IcingaAgentFeature` followed by the name of the feature. In case the feature is already enabled, you will receive a notification and no change will be made:

```powershell
Enable-IcingaAgentFeature -Feature api;
```

```text
[Notice]: Feature "api" was successfully enabled
```

In case the feature is already enabled:

```text
[Notice]: This feature is already enabled [api]
```

Now restart your Icinga Agent to take the changes into effect:

```powershell
Restart-IcingaService icinga2
```

```text
[Notice]: Restarting service "icinga2"
```

## Disable Icinga Agent Features

To simply disable an Icinga Agent feature you can use `Disable-IcingaAgentFeature` followed by the name of the feature. In case the feature is already disabled, you will receive a notification and no change will be made:

```powershell
Disable-IcingaAgentFeature -Feature api;
```

```text
[Notice]: Feature "api" was successfully disabled
```

In case the feature is already enabled:

```text
[Notice]: This feature is already disabled [api]
```

Now restart your Icinga Agent to take the changes into effect:

```powershell
Restart-IcingaService icinga2
```

```text
[Notice]: Restarting service "icinga2"
```
