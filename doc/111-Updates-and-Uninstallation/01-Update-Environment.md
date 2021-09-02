# Update Icinga for Windows

Before you update your environment, please have a look on the [upgrading docs](../100-General/01-Upgrading.md).

## Preparations

In general updating the entire Icinga for Windows environment is straight forward. If you are using official repositories, you can apply updates once a new package is available. For [own repositories](../120-Repository-Manager/07-Create-Own-Repositories.md) you will either have to [synchronize](../120-Repository-Manager/02-Sync-Repositories.md) them again or copy files manually there.

The command for updating is `Update-Icinga` and provides the following arguments:

| Argument | Type   | Description |
| ---      | ---    | ---         |
| Name     | String | Allows to define a specific component of being updated, instead of all of them |
| Release  | Switch | Default. Will update all components by using the release repositories |
| Snapshot | Switch | This will allow to update all components by using snapshot repositories |
| Confirm  | Switch | Each component being updated will ask for a prompt if the package should be updated. Use this switch to confirm the installation and continue |
| Force    | Switch | Allows to re-install components in case the no new version was found with the name version |

## Updating all components

To update all components at once, you can simply run the following command:

```powershell
Update-Icinga;
```

This will lookup every single component, check if a new version is available and update it. In case you have [JEA](../130-JEA/01-JEA-Profiles.md) enabled, the profile is updated during the process as well.

## Updating specific component

To update specific components only, you can use the `-Name` argument:

```powershell
Update-Icinga -Name 'plugins;
```

You have to proceed this step then for all components you want to update.

## Pinned components

If you never want to update a certain component in the near future, you can also [pin components](../120-Repository-Manager/06-Pinning-Versions.md) a certain version. Once you run an update, the component will be ignored in case the pinned version is already installed.
