# Install Components

Once you [added](01-Add-Repositories.md) and/or [synced](02-Sync-Repositories.md) your repositories and configured - if required - your [locks](06-Pinning-Versions.md), we can start installing components.

For this we will use `Install-IcingaComponent`.

**Note:** When the install component is looking up available versions, *all* defined repositories will be searched and the latest version available used by default. If a specific version is set, it will stop once this version is found in one of the repositories and go with this package.

## Available Arguments

| Argument   | Type   | Description                                                                     |
| ---        |---     | ---                                                                             |
| Name       | String | The name of the component you want to install |
| Version    | String | Specifies to install a specific version of the component, instead of the latest one found. Is ignored in case you added a [lock](06-Pinning-Versions.md) to this component |
| Release    | Switch | Includes release versions only if set. If neither Release nor Snapshot is defined, it will enforce release |
| Snapshot   | Switch | Includes snapshots versions only if set. If neither Release nor Snapshot is defined, it will enforce release |
| Confirm    | Switch | Skips the message asking you if you want to install this component |
| Force      | Switch | In case the same version is already installed, it will be skipped by default. Use this switch to install the same version again |

## Install Release Components

You can install release components either by adding the `-Release` switch or by not adding `-Release` and `-Snapshot` at all, to enforce release versions. If no version is specified, the latest version found will be used. Use `-Confirm` in addition to skip the dialog requiring an approval to install it.

```powershell
Install-IcingaComponent `
    -Name 'agent' `
    -Confirm;
```

## Install Specific Component Version

If your repository contains multiple versions, you can specify which version will be installed:

```powershell
Install-IcingaComponent `
    -Name 'agent' `
    -Version '2.11.2' `
    -Confirm;
```

## Reinstall Installed Component

If a component with a specific version is already installed, you can use `-Force` to re-install it.

```powershell
Install-IcingaComponent `
    -Name 'agent' `
    -Version '2.11.5' `
    -Confirm `
    -Force;
```

This also works for auto detected latest versions:

```powershell
Install-IcingaComponent `
    -Name 'agent' `
    -Confirm `
    -Force;
```
