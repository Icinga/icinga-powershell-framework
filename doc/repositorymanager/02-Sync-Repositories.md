# Sync Repositories

In case you require local copies of repositories to frequently access them or to make a public repository available for systems unable to access public spaces, you can use `Sync-IcingaRepository`.

Like with [adding existing repositories](01-Add-Existing-Repositories.md), each synced repositories require a unique name you can set with `-Name`. The name will not interfere on how the sync works.

## Available Arguments

| Argument     | Type   | Description                                                                     |
| ---          |---     | ---                                                                             |
| Name         | String | The unique name of the repository. This name can only exist once on your system |
| Path         | String | The location on where the files from the remote repository will be synced to. This can either be a local path, a network share or a Linux path, including user and hostname like `icinga@example.com:/vaw/www/icingarepo/`
| RemotePath   | String | The path pointing to the location Icinga for Windows tries to lookup all your files. You can either replicate the `Path` variable for network shares for example, or use a web url which is made available based on `Path` to fetch and download files from. If left empty, it will default to the `Path` variable content |
| Source       | String | The source from where the repository will be synced from. This can either be pointing directly to the `ifw.repo.json` or the root directory, as long as the file is fetch able from this point. A source can be a web, local or network share |
| UseSCP       | Switch | If you set `Path` to a Linux path as mentioned in the first example, you will have to enable this switch to use SCP to copy files from the source to the Linux system. Requires `scp` and `ssh` being installed on the system |
| SkipSCPMkdir | Switch | Allows you to skip the `mkdir` operation while using `-UseSCP` and relies on the folder already existing |
| Force        | Switch | This will force the creation of the repository, even if the name of the repository is already assigned. Should be used with caution |
| ForceTrust   | Switch | By default repositories are validated with a hash, based on all files present inside the repository. If a repository is not providing a hash, it will be disabled after the sync for security reasons. In case the hash does not match with all files synced afterwards, the repository files will be deleted and the sync aborted. You can use this flag to ignore both states and always add the repository, regardless if the hash matches or the hash is not given |

## Sync Public Repository

You can use the sync command to clone an existing public repository for example and fetch all files to a local space.

### Local Disk Example

```powershell
Sync-IcingaRepository `
    -Name 'Icinga Stable Local' `
    -Path 'C:\icinga\icinga_stable' `
    -Source 'https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json';
```

This will sync all files from the public Icinga repository into `C:\icinga\icinga_stable`. As `RemotePath` is not set, it will default to `C:\icinga\icinga_stable` and all files will be fetched from this location.

### Shared Folder Example

```powershell
Sync-IcingaRepository `
    -Name 'Icinga Stable Local' `
    -Path 'C:\icinga\icinga_stable' `
    -RemotePath '\\myhost.example.com\icingastable' `
    -Source 'https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json';
```

We can for example use file sharing, to make certain folders available in our network. This example will download all files into `C:\icinga\icinga_stable`, but tell Icinga for Windows to use your shared network drive `\\myhost.example.com\icingastable` to fetch them from.

You can now add the repository on different machines with

```powershell
Add-IcingaRepository `
    -Name 'Icinga Stable Local' `
    -RemotePath '\\myhost.example.com\icingastable';
```

Every file will then be fetched over this network share to the local machines.

### Linux Webserver Example

```powershell
Sync-IcingaRepository `
    -Name 'Icinga Stable Internal Web' `
    -Path 'icinga@icingarepo.example.com:/var/www/icingastable/' `
    -RemotePath 'https://icingarepo.example.com/icingastable' `
    -Source 'https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json' `
    -UseSCP;
```

In this example we will sync all files to a Linux machine at `/var/www/icingastable/`. If we are running a local Apache or Nginx, we can create a web resource for this path and make it available in our network. We have to use `-UseSCP`, to tell Icinga for Windows to copy them to the Linux machine over `scp`. Please note that both, `scp` and `ssh` have to be installed  on the system.

On different machines, you can then use

```powershell
Add-IcingaRepository `
    -Name 'Icinga Stable Internal Web' `
    -RemotePath 'https://icingarepo.example.com/icingastable';
```

to make the repository available.

### Sync from a Sync Example

Last but not least we have the method to sync repositories from a sync source, allowing us to distribute all Icinga for Windows files around or network on different zones as example.

Clone the repository to a local path:

```powershell
Sync-IcingaRepository `
    -Name 'Icinga Stable Local' `
    -Path 'C:\icinga\icinga_stable' `
    -Source 'https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json';
```

Clone this repository to our internal web space:

```powershell
Sync-IcingaRepository `
    -Name 'Icinga Stable Internal Web' `
    -Path 'icinga@icingarepo.example.com:/var/www/icingastable/' `
    -RemotePath 'https://icingarepo.example.com/icingastable' `
    -Source 'C:\icinga\icinga_stable' `
    -UseSCP;
```

## Update Sync Repositories

To update synced repositories, you can use `Update-IcingaRepository`. You can either update a specific repository by using the `-Name` argument or update all by leaving it empty.

### Available Arguments

| Argument   | Type   | Description                                                                     |
| ---        |---     | ---                                                                             |
| Name       | String | The name of the repository to update. Leave empty to update all configured repositories |
| ForceTrust | Switch | By default repositories are validated with a hash, based on all files present inside the repository. If a repository is not providing a hash, it will be disabled after the sync for security reasons. In case the hash does not match with all files synced afterwards, the repository files will be deleted and the sync aborted. You can use this flag to ignore both states and always add the repository, regardless if the hash matches or the hash is not given |

### Update All Repositories

Updating all synced repositories is very easy, with a simple command call:

```powershell
Update-IcingaRepository;
```

Once run, all files will be downloaded from the source and validated. In case validation fails or the source is not containing a repository hash, you can use `-ForceTrust` to ignore this and enable it regardless.

```powershell
Update-IcingaRepository -ForceTrust;
```

### Update Specific Repository

You can update a specific repository, by simply providing it's name:

```powershell
Update-IcingaRepository -Name 'Icinga Stable Internal Web';
```

Like other methods, `-ForceTrust` will work here as well.

## Updating Linux Repositories

There is no special mechanic required, as the entire configuration for the repository is stored inside the Icinga for Windows configuration.

For easier usage, it is however advised to use SSH keys, as otherwise each sync and update task will require you to enter your SSH password multiple times.
