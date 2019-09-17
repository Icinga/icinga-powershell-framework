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
