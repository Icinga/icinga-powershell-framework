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
        New-Item -Path $CacheFile -Force | Out-Null;
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
