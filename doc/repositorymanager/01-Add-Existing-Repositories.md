# Add Existing Repositories

The easiest way to extend the functionality of Icinga for Windows, is by installing new components. Components are delivered by repositories you can add to your environment. This includes external repositories but also internal ones.

Each repository inherits a file called `ifw.repo.json` on the root level, which contains all informations for available packages, versions and where they can be downloaded from.

**Note:** Each repository requires to use a unique name on the system. You can add multiple repositories, with different resources and components provided. The name has be unique and has no impact on the installation. It should be a short summary on where the repository is located.

## Adding Default Repositories

The best way to demonstrate on how to add new repositories, you can use the default Icinga for Windows repositories. To add an already existing repository, you can use `Add-IcingaRepository`

### Available Arguments

| Argument   | Type   | Description                                                                     |
| ---        |---     | ---                                                                             |
| Name       | String | The unique name of the repository. This name can only exist once on your system |
| RemotePath | String | The path pointing to the location on where the repository is located at. It can either point to the root directory of the folder containing the `ifw.repo.json` or directly to this file. Accepts web, local or network share path. |
| Force      | Switch | Will remove an existing repository with the same name and override it with the new configuration |

### Icinga for Windows Stable

The URL pointing to the stable releases is `http://packages.icinga.com/IcingaForWindows/stable`.

```powershell
Add-IcingaRepository `
    -Name 'Icinga Stable' `
    -RemotePath 'http://packages.icinga.com/IcingaForWindows/stable';
```

### Icinga for Windows Snapshot

The URL pointing to the snapshot releases is `http://packages.icinga.com/IcingaForWindows/snapshot`.

```powershell
Add-IcingaRepository `
    -Name 'Icinga Snapshot' `
    -RemotePath 'http://packages.icinga.com/IcingaForWindows/snapshot';
```

## Using Repositories

Once you added one or more repositories, they will be connected to once you want to install or update your components. The available components and versions will be accessed on runtime, during installation/updates and files downloaded directly when required.

In case you can only access the internet or some internal repositories on certain times only, you can also [sync existing repositories](02-Sync-Repositories.md).
