# Create Own Repositories

Besides [adding](01-Add-Repositories.md) and/or [syncing](02-Sync-Repositories.md) already existing repositories, you can create entire new ones from scratch with `New-IcingaRepository`.

## Preparing Repositories

To prepare your new repository, you will simply require an `empty` folder somewhere on your local Windows machine or accessible network share. For example we can create a new folder directly under `C:`, like `C:\icinga_repositories\custom`.

Now after having an `empty` folder, copy all files you want to add to this repository there. This includes the `.zip` files for Icinga for Windows components, the Icinga Agents `.msi` files and the Icinga for Windows `Service` `.zip` files which include the `.exe` and the `.md5` hash file.

## Initialize The Repository

Now as the folder is prepared and all files are placed inside, we can run `New-IcingaRepository` with our configuration.

### Available Arguments

| Argument   | Type   | Description                                                                     |
| ---        |---     | ---                                                                             |
| Name       | String | The name of the repository to add. Only for local references required. |
| Path       | String | The location of the path you prepared in the first step in which all files are inside, for creating your repository |
| RemotePath | String | Will add the remote path for later adding of this repository to another system. Only suitable for network shares and is optional |
| Force      | Switch | In case a repository with the given name is already present, it will be overwritten |

### Create Our Repository

As we now understand on which arguments are available, we can now use `New-IcingaRepository` to create your repository:

```powershell
New-IcingaRepository `
    -Name 'My Local Repo' `
    -Path 'C:\icinga_repositories\custom';
```

Depending on the amount of files inside, every single one will be analyzed for their component name and version and a new repo file `ifw.repo.json` is created. From the local Windows machine, you can also use this repository to install components from, as it will be added automatically.

### Sync Own Repositories

Now as we created our own repository with own files we checked, we can use the `Sync-IcingaRepository` Cmdlet to either sync from this machine to another location or ir vice-versa, depending on your configuration.
You can read more about this on the [sync repositories](02-Sync-Repositories.md) section.

#### Example

```powershell
Sync-IcingaRepository `
    -Name 'My Local Repo Sync' `
    -Path 'icinga@icingarepo.example.com:/var/www/icingacustom/' `
    -RemotePath 'https://icingarepo.example.com/icingacustom' `
    -Source 'C:\icinga_repositories\custom' `
    -UseSCP;
```
