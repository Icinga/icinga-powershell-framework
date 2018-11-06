Integrating Icinga Web 2
=====================================

The PowerShell Module provides the possibility to directly (or indirectly over Proxies) connect to an Icinga Web 2 Api to send informations there.

Requirements
--------------

In order to make this work, you will require the Icinga Web 2 Module from the [GitHub Repository](https://github.com/LordHepipud/icingaweb2-module-windows).

Configure the Module
--------------

Once you installed the [Icinga Web 2 Windows Module](https://github.com/LordHepipud/icingaweb2-module-windows), you will have to tell the PowerShell Module where it should send it's data to.

The Icinga Web 2 Endpoint for this is

```
    windows/checkresult
```

A full Url example could look like this (which we will use in this documentation):

```
    https://example.com/icingaweb2/windows/checkresult
```

To change configuration elements of the PowerShell Module, there is a Cmdlet available. In order to set the Icinga Web 2 endpoint, you can do it like this:

```powershell
    Set-Icinga-Config -Key 'checker.server.host' -Value 'https://example.com/icingaweb2/windows/checkresult'
```

Once sucessfully changed, you will have to restart either the Service or the running PowerShell instance.

To validate if the configuration change really worked, you can review it with

```powershell
    Get-Icinga-Config -ListConfig
```