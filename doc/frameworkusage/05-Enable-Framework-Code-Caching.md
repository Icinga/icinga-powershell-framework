# Enable Framework Code Caching

On certain systems with fewer CPU cores, there might be an impact while running Icinga for Windows because of long loading times for the Icinga PowerShell Framework. To mitigate this issue, we added the possibility to create a code cache file for the entire Icinga PowerShell Framework.

What it does is to load every single module and content file into one single `cache.psm1` file which is loaded in case the caching is enabled.

## Pre-Cautions

By enabling this feature, you will have to generate a new cache file whenever you apply changes to any code for the Icinga PowerShell Framework. This can be done by running the Cmdlet

```powershell
Write-IcingaFrameworkCodeCache
```

Please note that the code cache feature must be enabled first.

In case you upgrade to a newer version of the Icinga PowerShell Framework, you will only require to manually proceed in case the code cache feature was disabled beforehand. In case the code cache feature is enabled during the upgrade, the cache file will be generated and updated automatically.

## Enable Icinga Framework Code Cache

To enable the Icinga PowerShell Framework code cache, simply run the following command within an Icinga Shell:

```powershell
Enable-IcingaFrameworkCodeCache
```

Once activated, you should make sure to generate a new cache file before using the Framework:

```powershell
Write-IcingaFrameworkCodeCache
```

If you leave the code caching feature enabled, future updates of the Framework will automatically generate a new cache file. If you disabled the feature in-between, please write the cache file manually.

In case no cache file is present while the feature is activated, a cache file is generated on the first use of `Use-Icinga` or `icinga`.

## Disable Icinga Framework Code Cache

To disable the code caching feature again, you can simply run

```powershell
Disable-IcingaFrameworkCodeCache
```

Please note that even though the cache file is no longer loaded it still remains. Therefor you will have to manually use `Write-IcingaFrameworkCodeCache` in case you activate the feature later again. This is especially required if you update the Icinga PowerShell Framework while the feature was disabled.
