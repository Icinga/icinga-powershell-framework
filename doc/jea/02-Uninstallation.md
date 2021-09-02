# Uninstall JEA

If you want to uninstall JEA profiles or even the managed user included, there are `Cmdlets` available for this.

## Uninstall JEA with managed user

To uninstall JEA profiles and the managed user, you can use `Uninstall-IcingaSecurity`. Like the installation counterpart, you can specify a custom user with `-IcingaUser`.

However, users will only be removed if their description matches the Icinga for Windows managed user description.

```powershell
Uninstall-IcingaSecurity -IcingaUser 'MyOwnIcingaUser';
```

By default, it will remove the `icinga` user including unregistering the JEA profile.

## Uninstall JEA Profile

To simply uninstall the JEA profile and leave a possible managed user on the system, you can run `Uninstall-IcingaJEAProfile`.

This will remove the created JEA profile and the JEA catalog for `IcingaForWindows` on the system.

## Uninstall JEA test profile

To simply remove the test environment of the JEA profile, you can use this command:

```powershell
Unregister-PSSessionConfiguration -Name 'IcingaForWindowsTest';
```

This will leave the catalog and the production system itself alone and only removes the test profile.
