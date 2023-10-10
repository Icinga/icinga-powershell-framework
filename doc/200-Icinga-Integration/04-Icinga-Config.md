# Icinga Config Generator

To make the integration as easy as possible, the Framework is shipping with an Icinga 2 configuration generator. Each Check-Plugin available within the Framework is able to auto-generate an Icinga config which can be copied to your Icinga 2 hosts.

## Generating Configuration

To automatically generate the Icinga configuration, open a PowerShell terminal and type in

```powershell
Use-Icinga
```

to load the framework Cmdlets.

Now use the same commands as for the [Icinga Director Basket](01-Director-Baskets.md) but make sure to specify an `-OutDirectory` together with the `-IcingaConfig` switch. The `-IcingaConfig` switch only changes the generated output file format, not the returned resp. printed string. Thus, using `-IcingaConfig` without an `-OutDirectory` does not have an impact.

Afterwards use the command

```powershell
Get-IcingaCheckCommandConfig -OutDirectory 'C:\Users\myuser\Documents\' -IcingaConfig
```

to automatically generate the configuration for all found Check-Commands in the given directory.

If you wish to specify specific commands only, you can filter them as well:

```powershell
Get-IcingaCheckCommandConfig -CheckName Invoke-IcingaCheckBiosSerial, Invoke-IcingaCheckCPU -OutDirectory 'C:\Users\myuser\Documents\' -IcingaConfig
```

Once the file is exported, you can copy the `.conf` files onto your Icinga 2 hosts to use them.

**Note:** Because of a possible configuration error cased by multiple `PowerShell Base` CheckCommands, it is generated separately. You only require this once on your system and is cross-compatible with every single CheckCommand.

## Custom File Names

You can modify the name of the output `.conf` file  by using the `-FileName` argument in combination with the other arguments:

```powershell
Get-IcingaCheckCommandConfig -CheckName Invoke-IcingaCheckBiosSerial, Invoke-IcingaCheckCPU -IcingaConfig -OutDirectory 'C:\Users\myuser\Documents\' -FileName 'IcingaForWindows';
```

This will generate the plugins configuration `C:\Users\myuser\Documents\IcingaForWindows.conf` and `C:\Users\myuser\Documents\PowerShell_Base.conf`

The `.conf` ending is not required, as the Cmdlet will take care of that for you.

## Developer Note

The generated Icinga configuration will benefit from a detailed documentation of the module and each single argument. Descriptions for arguments are parsed into the commands description field, informing users of what the argument actually does. Furthermore arguments are automatically mapped to certain object types. A `switch` argument for example will always be rendered with a `set_if` flag, ensuring you only require to set the corresponding custom variable to true to set this argument.
In addition `array` arguments use the Icinga DSL to properly build PowerShell arrays based on Icinga arrays.

This will increase the entire usability of the module and prevent you from having to document plugins multiple times.
