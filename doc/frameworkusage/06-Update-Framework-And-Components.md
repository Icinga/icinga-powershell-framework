# Update Framework and Components

Icinga for Windows ships with a bunch of Cmdlets, allowing users to manage the entire environment without much effort. This includes features to install entire components, but also allows to update them.

## Updating Icinga PowerShell Framework

To update the Framework it is not required to run the [installation process](../02-Installation.md) again. The Framework ships with a native command for this and is recommended to use, as this allows you to keep your current configuration and cache files. The command is `Install-IcingaFrameworkUpdate`.

### Interactive Update

To start the interactive update with a wizard, asking you on how to update, simply type the command inside your Icinga shell or call `Use-Icinga` before.

```powershell
Install-IcingaFrameworkUpdate;
```

Afterwards you will be asked a bunch of questions, which we explain in the following.

```text
Do you provide a custom repository for "Icinga Framework"? (y/N):
```

Like any other component, you can type in y or n for this answer. The custom repository is defined as a `.zip` file you might have downloaded directly from GitHub for the Framework at placed it either on your Icinga webserver somewhere, or locally. If you type no, you can choose if you want to install the latest stable or snapshot.

```text
Which version of the "Icinga Framework" do you want to install? (release/snapshot) (Defaults: "release"):
```

By default the command will connect to `https://github.com/Icinga/icinga-powershell-framework` and either fetch the latest stable release if you select `release` or the current master branch if you use `snapshot`.
Lets assume we update our production environment and therefor using `release`.

```powershell
icinga> Install-IcingaFrameworkUpdate
Do you provide a custom repository for "Icinga Framework"? (y/N):
Which version of the "Icinga Framework" do you want to install? (release/snapshot) (Defaults: "release"):
[Notice]: Downloading "Icinga Framework" into "C:\Users\Administrator\AppData\Local\Temp\tmp_icinga1262975608.d"
[Notice]: Installing module into "C:\Users\Administrator\AppData\Local\Temp\tmp_icinga1262975608.d"
[Notice]: Using content of folder "C:\Users\Administrator\AppData\Local\Temp\tmp_icinga1262975608.d\icinga-powershell-framework-1.4.1" for updates
[Notice]: Stopping Icinga Agent service
[Notice]: Stopping service "icinga2"
[Notice]: Removing files from framework
[Notice]: Copying new files to framework
[Notice]: Unblocking Icinga PowerShell Files
[Notice]: Cleaning temporary content
[Notice]: Updating Framework cache file
[Notice]: Framework update has been completed. Please start a new PowerShell instance now to complete the update
[Passed]: Icinga Agent service is installed
[Passed]: The specified user "NT Authority\NetworkService" is allowed to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writable by the Icinga Service User "NT Authority\NetworkService"
[Passed]: Directory "C:\ProgramData\icinga2\var" is accessible and writable by the Icinga Service User "NT Authority\NetworkService"
[Passed]: Directory "C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework\cache" is accessible and writable by the Icinga Service User "NT Authority\NetworkService"
[Passed]: Icinga Agent configuration is valid
[Passed]: Icinga Agent debug log is disabled
[Notice]: Starting Icinga Agent service
[Notice]: Starting service "icinga2"
```

Thats it. Your Icinga Agent will now continue it's work behind without requiring additional actions. If you want to use the new Framework features, you should open a new PowerShell instance to apply the updates to your current session.

### Update With Defined Package

To avoid the above wizard and to properly automate the task, the Cmdlet `Install-IcingaFrameworkUpdate` ships with one additional argument: `-FrameworkUrl`

As `-FrameworkUrl` you can define the target to the Icinga PowerShell Frameworks `.zip` file and directly install this version with the same result as above, but fully automated without questions.

#### Examples For URL

Local File:

```powershell
Install-IcingaFrameworkUpdate -FrameworkUrl 'C:\Icinga2\icinga-powershell-framework-1.5.0.zip';
```

NetworkShare File:

```powershell
Install-IcingaFrameworkUpdate -FrameworkUrl '\\icinga.example.com\IcingaForWindows\Icinga2\icinga-powershell-framework-1.5.0.zip';
```

Custom Web Path:

```powershell
Install-IcingaFrameworkUpdate -FrameworkUrl 'https://example.com/Icinga/icinga-powershell-framework-1.5.0.zip';
```

GitHub Release:

```powershell
Install-IcingaFrameworkUpdate -FrameworkUrl 'https://github.com/Icinga/icinga-powershell-framework/archive/refs/tags/v1.5.0.zip';
```

GitHub Master Branch:

```powershell
Install-IcingaFrameworkUpdate -FrameworkUrl 'https://github.com/Icinga/icinga-powershell-framework/archive/refs/heads/master.zip';
```

GitHub Branch

```powershell
Install-IcingaFrameworkUpdate -FrameworkUrl 'https://github.com/Icinga/icinga-powershell-framework/archive/refs/heads/fix/framework_root_folder_lookup.zip';
```

Once you enter the command, the update process will continue as shown above earlier

## Updating Icinga PowerShell Components

Updating components like [plugins](https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/01-Introduction/) is as easy as installing them. If you used the [Framework Component Installer](https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/02-Installation/#icinga-framework-component-installer) as described in every plugin repository, you can use the same command to update the plugins as well.

The command `Install-IcingaFrameworkComponent` is designed to both, install components on a fresh environment and also keeps them updated if you run the same command again.
