# Uninstall Icinga Agent

While the main purpose of the Icinga for Windows solution is check your systems and provided all required tools, including the Icinga Agent, it might be required to entirely uninstall the Icinga Agent. This sometimes might even include to flush the entire `ProgramData` folder, where certificates and other configurations are stored.

**Note:** Before using any of the commands below you will have to initialize the Icinga PowerShell Framework inside a new PowerShell instance with `icinga -Shell`

## Uninstalling the Icinga Agent

### Keep ProgramData Content

If you only want to uninstall the Icinga Agent itself, but keep configuration files and certificates, you can use the `Uninstall-IcingaAgent` Cmdlet.

```powershell
Uninstall-IcingaAgent;
```

By default there are not special arguments required and once completed you will be prompted with a message that the Icinga Agent has been removed

### Remove ProgramData Content

In some cases it might be helpful for troubleshooting to uninstall the Icinga Agent entirely, including the `ProgramData` content. We can do this with the same command, but add another argument:

```powershell
Uninstall-IcingaAgent -RemoveDataFolder;
```

Now the Icinga Agent will be installed and afterwards the entire content at `C:\ProgramData\ICINGA2` will be deleted.

**Note**: If you missed to add `-RemoveDataFolder` on your first attempt, you can run the command with the argument set again. In case the Icinga Agent is not installed, this part will be skipped and the `ProgramData` folder content will be flushed.

## Icinga Agent Service is "Marked for Deletion"

This issue can happen during installation/uninstallation/upgrading processes. We have written the [Knowledge Base Article IWKB000003](../knowledgebase/IWKB000003.md) for this scenario.
