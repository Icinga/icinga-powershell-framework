# Framework Code Caching

By default, Icinga for Windows will compile all module files into a single cache file for quicker and easier loading. This ensures, that during startup all functions are available and can be used in combination with JEA profiles.

The location of the cache file is at

```
.\cache\framework_cache.psm1
```

## Pre-Cautions

In case you are running custom modifications to the Framework or apply manual patches, you will **always** have to re-write the Icinga for Windows cache file! During upgrades by using the Icinga for Windows Cmdlets, the cache file is updated automatically.

## Updating Cache File

To re-write the cache file and update it to the latest version manually, you can use the following command:

```powershell
Write-IcingaFrameworkCodeCache
```
