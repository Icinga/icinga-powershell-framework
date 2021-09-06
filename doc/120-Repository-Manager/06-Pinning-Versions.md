# Pinning Versions

Sometimes you might require to `lock` certain components to a specific version. This means regardless of any version available, this component will not be updated or touched, unless the version it is locked to is not yet installed.

A lock will override the version suggested by any repository or the user input and always force the version specified.

If for example you lock the [Icinga Plugins](https://icinga.com/docs/icinga-for-windows/latest/plugins/doc/01-Introduction/) to version 1.6.0, they will not get upgraded to any other version.

## Locking Commponents

You can lock any Icinga component with `Lock-IcingaComponent` by simply providing the name of the component and the target version.

For example we can look our plugins to version 1.6.0:

```powershell
Lock-IcingaComponent `
    -Name 'plugins' `
    -Version '1.6.0';
```

Now the only version being installed for the plugins is 1.6.0, while all other versions are skipped. You can directly replace the lock for a different version later on, like 1.6.1:

```powershell
Lock-IcingaComponent `
    -Name 'plugins' `
    -Version '1.6.1';
```

## Unlocking Components

You can release a lock for a component by using `Unlock-IcingaComponent`. Unlike the locking mechanism, you only require to specify the component name for unlocking it, as each component only accepts one version lock at the time.

```powershell
Unlock-IcingaComponent `
    -Name 'plugins';
```

Once the lock is removed, updates will be applied again for this component.
