<#
.SYNOPSIS
   Reads data from a cache file of the Framework and returns its content
.DESCRIPTION
   Allows a developer to read data from certain cache files to either speed up
   loading procedures, to store content to not lose data on restarts of a daemon
   or to build data tables over time
.FUNCTIONALITY
   Returns cached data for specific content
.EXAMPLE
   PS>Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName 'Invoke-IcingaCheckCPU';
.PARAMETER Space
   The individual space to read from. This is targeted to a folder the cache data is written to under icinga-powershell-framework/cache/
.PARAMETER CacheStore
   This is targeted to a sub-folder under icinga-powershell-framework/cache/<space>/
.PARAMETER KeyName
   This is the actual cache file located under icinga-powershell-framework/cache/<space>/<CacheStore>/<KeyName>.json
   Please note to only provide the name without the '.json' apendix. This is done by the module itself
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>
function Get-IcingaCacheData()
{
    param(
        [string]$Space,
        [string]$CacheStore,
        [string]$KeyName
    );

    $CacheFile       = Join-Path -Path (Join-Path -Path (Join-Path -Path (Get-IcingaCacheDir) -ChildPath $Space) -ChildPath $CacheStore) -ChildPath ([string]::Format('{0}.json', $KeyName));
    [string]$Content = '';
    $cacheData       = @{};

    if ((Test-Path $CacheFile) -eq $FALSE) {
        return $null;
    }
    
    $Content = Get-Content -Path $CacheFile;

    if ([string]::IsNullOrEmpty($Content)) {
        return $null;
    }

    $cacheData = ConvertFrom-Json -InputObject ([string]$Content);

    if ([string]::IsNullOrEmpty($KeyName)) {
        return $cacheData;
    } else {
        return $cacheData.$KeyName;
    }
}
