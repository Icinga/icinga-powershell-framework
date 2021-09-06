# Manage Repositories

Besides [adding](01-Add-Repositories.md) and [syncing](02-Sync-Repositories.md) of repositories, you can also `enable`, `disable` and `remove` repositories from your local machine.

Please note that **removing** a repository will only remove the Icinga for Windows configuration and **not** the files on the disk. You have to do this step manually.

## Enabling Repositories

In case a repository is disabled, you can enable it with `Enable-IcingaRepository`.

```powershell
Enable-IcingaRepository -Name 'Icinga Stable Internal Web';
```

## Disabling Repositories

You can also disable enabled repositories with `Disable-IcingaRepository`.

```powershell
Disable-IcingaRepository -Name 'Icinga Stable Internal Web';
```

Please note that disabled Icinga repositories will be fully ignored during installation/update tasks and no files from these will be fetched.

## Removing Repositories

If you no longer require a certain repository, you can remove it with `Remove-IcingaRepository`.

```powershell
Remove-IcingaRepository -Name 'Icinga Stable Internal Web';
```

**Note:** This will only remove the repository from the configuration. All possible available files for sync runs or anything related will remain on the disk until you remove them manually.
