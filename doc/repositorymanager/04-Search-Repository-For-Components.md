# Search Repository For Components

Once you [added](01-Add-Existing-Repositories.md) and/or [synced])(02-Sync-Repositories.md) your repositories, you can search them for available components.

We can do this with the command `Search-IcingaRepository` and filter for a component `Name`, it's `Version` and if we want to include `Release` or `Snapshot` packages.

## List Everything available

At the beginning we can have a full search over all repositories and lookup all components made available by our repositories.

```powershell
Search-IcingaRepository -Name '*' -Release -Snapshot;
```

This will print all components including the version, the repository, the source of the repository and the component name.

**Note:** Disabled repositories are not included inside the search and results.

## List Certain Release Component

You can only include certain components for a release branch by using the `Name` and `Release` argument:

```powershell
Search-IcingaRepository -Name 'agent' -Release;
```

## Search For Specific Version

If you want to check if a certain `Release` version for a component is available inside your repositories, you can specify it with `Version`:

```powershell
Search-IcingaRepository -Name 'agent' -Version '2.12.5' -Release;
```
