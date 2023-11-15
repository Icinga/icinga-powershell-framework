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
.PARAMETER TempFile
    To safely write data, by default Icinga for Windows will write all content into a .tmp file at the same location with the same name
    before applying it to the proper file. Set this argument to read the content of a temp file instead
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
        [string]$KeyName,
        [switch]$TempFile   = $FALSE,
        [switch]$AsObject   = $FALSE
    );

    $CacheFile       = Join-Path -Path (Join-Path -Path (Join-Path -Path (Get-IcingaCacheDir) -ChildPath $Space) -ChildPath $CacheStore) -ChildPath ([string]::Format('{0}.json', $KeyName));
    [string]$Content = '';
    $cacheData       = @{ };

    # Read a tmp file if present
    if ($TempFile) {
        $CacheFile = [string]::Format('{0}.tmp', $CacheFile);
    }

    if ((Test-Path $CacheFile) -eq $FALSE) {
        return $null;
    }

    $Content = Read-IcingaFileSecure -File $CacheFile;

    if ([string]::IsNullOrEmpty($Content)) {
        return $null;
    }

    try {
        $cacheData = ConvertFrom-Json -InputObject ([string]$Content);
    } catch {
        Write-IcingaEventMessage -EventId 1104 -Namespace 'Framework' -ExceptionObject $_ -Objects $CacheFile;
        return $null;
    }

    if ($AsObject -Or [string]::IsNullOrEmpty($KeyName)) {
        return $cacheData;
    } else {
        return $cacheData.$KeyName;
    }
}
