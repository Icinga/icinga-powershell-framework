<#
.SYNOPSIS
    Writes data to a cache file for the Framework
.DESCRIPTION
    Allows a developer to write data to certain cache files to either speed up
    loading procedures, to store content to not lose data on restarts of a daemon
    or to build data tables over time
.FUNCTIONALITY
    Writes  data for specific value to a cache file
.EXAMPLE
    PS>Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName 'Invoke-IcingaCheckCPU' -Value @{ 'CachedData' = 'MyValue' };
.PARAMETER Space
    The individual space to write to. This is targeted to a folder the cache data is written to under icinga-powershell-framework/cache/
.PARAMETER CacheStore
    This is targeted to a sub-folder under icinga-powershell-framework/cache/<space>/
.PARAMETER KeyName
    This is the actual cache file located under icinga-powershell-framework/cache/<space>/<CacheStore>/<KeyName>.json
    Please note to only provide the name without the '.json' apendix. This is done by the module itself
.PARAMETER Value
    The actual value to store within the cache file. This can be any kind of value, as long as it is convertable to JSON
.INPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Set-IcingaCacheData()
{
    param(
        [string]$Space,
        [string]$CacheStore,
        [string]$KeyName,
        $Value
    );

    $CacheFile = Join-Path -Path (Join-Path -Path (Join-Path -Path (Get-IcingaCacheDir) -ChildPath $Space) -ChildPath $CacheStore) -ChildPath ([string]::Format('{0}.json', $KeyName));
    $cacheData = @{};

    if ((Test-Path $CacheFile)) {
        $cacheData = Get-IcingaCacheData -Space $Space -CacheStore $CacheStore;
    } else {
        try {
            New-Item -Path $CacheFile -Force | Out-Null;
        } catch {
            Exit-IcingaThrowException -InputString $_.Exception -CustomMessage (Get-IcingaCacheDir) -StringPattern 'NewItemUnauthorizedAccessError' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.CacheFolder;
            Exit-IcingaThrowException -CustomMessage $_.Exception -ExceptionType 'Unhandled' -Force;
        }
    }

    if ($null -eq $cacheData -or $cacheData.Count -eq 0) {
        $cacheData = @{
            $KeyName = $Value
        };
    } else {
        if ($cacheData.PSobject.Properties.Name -ne $KeyName) {
            $cacheData | Add-Member -MemberType NoteProperty -Name $KeyName -Value $Value -Force;
        } else {
            $cacheData.$KeyName = $Value;
        }
    }

    try {
        Set-Content -Path $CacheFile -Value (ConvertTo-Json -InputObject $cacheData -Depth 100) | Out-Null;
    } catch {
        Exit-IcingaThrowException -InputString $_.Exception -CustomMessage (Get-IcingaCacheDir) -StringPattern 'System.UnauthorizedAccessException' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.CacheFolder;
        Exit-IcingaThrowException -CustomMessage $_.Exception -ExceptionType 'Unhandled' -Force;
    }
}
