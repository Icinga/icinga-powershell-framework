Icinga Agent integration as Framework Modules
=====================================

This PowerShell modules provides a wide range of Check-Plugins for Icinga 2 to fetch information from a Windows system. Once the module is installed, the Plugins are ready to use.

Requirements
--------------

To properly work we recommend using the Icinga 2 Agent.

Usage of the Check-Commands
--------------

Each call from the Icinga 2 Agent requires a short initialisation of the module. This can either be done by using the `Import-Module` Cmdlet in case the module is not autoloaded, or by calling

```powershell
Use-Icinga;
```

before each function call. An example on the PowerShell would be this:

```powershell
Use-Icinga; Invoke-IcingaCheckCPU;
```

This will initialise the module and execute the Check-Command afterwards.

Check-Command definition for Icinga
--------------

A example Check-Command for Icinga could look like this:

```icinga
object CheckCommand "Windows Check CPU" {
    import "plugin-check-command"
    command = [
        "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
    ]
    timeout = 3m
    arguments += {
        "-C" = {
            order = 0
            value = "Use-Icinga; exit Invoke-IcingaCheckCPU"
        }
        "-Critical" = {
            order = 2
            value = "$PowerShell_Critical$"
        }
        "-NoPerfData" = {
            order = 6
            set_if = "$PowerShell_NoPerfData$"
        }
        "-Verbose" = {
            order = 4
            value = "$PowerShell_Verbose$"
        }
        "-Warning" = {
            order = 1
            value = "$PowerShell_Warning$"
        }
    }
    vars.PowerShell_Critical = "$$null"
    vars.PowerShell_NoPerfData = "0"
    vars.PowerShell_Verbose = "0"
    vars.PowerShell_Warning = "$$null"
}
```

This will call the PowerShell, execute the provided initialisation function `Use-Icinga` and afterwards execute the Check-Plugin with the provided arguments.

Unlike other PowerShell integrations, it will automaticly exit with the proper exit code - no special handling is required here.
