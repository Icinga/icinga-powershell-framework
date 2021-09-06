# Uninstall Icinga for Windows Components

If you no longer require certain components on your system, you can uninstall them directly with the build-in command `Uninstall-IcingaComponent`. It includes the following arguments:

| Argument           | Type   | Description |
| ---                | ---    | ---         |
| Name               | String | The name of the component to uninstall |
| RemovePackageFiles | Switch | This argument will ensure that remaining files which are not PowerShell related will be removed as well. This includes for example the `ProgramData` folder of the Icinga Agent and the `service binary` for the Icinga for Windows service |

## Uninstall component

To uninstall a component, you simply specify the name and run the uninstall command:

```powershell
Uninstall-IcingaComponent -Name 'plugins';
```

The component will then be removed from the system. For the Icinga Agent for example, you can use the `-RemovePackageFiles` argument, to also remove the `ProgramData` folder which includes the certificates as example:

```powershell
Uninstall-IcingaComponent -Name 'agent' -RemovePackageFiles;
```

## Uninstall Icinga for Windows

To remove Icinga for Windows entirely from your system, you can run the command

```powershell
Uninstall-IcingaForWindows;
```

If you are using [JEA](../130-JEA/01-JEA-Profiles.md) and used a different user as managed user then `icinga`, you can specify this user with the `-IcingaUser` argument:

```powershell
Uninstall-IcingaForWindows -IcingaUser 'MyCustomUser';
```

Otherwise it will lookup the default user `icinga` and remove it, in case it is managed by Icinga for Windows.

To get rid of the confirmation message, simply add the `-Force` argument:

```powershell
Uninstall-IcingaForWindows -Force;
```

**Note:** This command will uninstall every single Icinga for Windows component, including the service, the Icinga Agent and the Icinga PowerShell Framework itself.
