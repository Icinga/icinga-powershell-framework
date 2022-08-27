function Test-IcingaCacheDataTempFile()
{
    param (
        [string]$Space,
        [string]$CacheStore,
        [string]$KeyName
    );

    # Once the file is written successully, validate it is fine
    $tmpContent = Get-IcingaCacheData -Space $Space -CacheStore $CacheStore -KeyName $KeyName -TempFile;

    if ($null -eq $tmpContent) {
        # File is corrupt or empty
        return $FALSE;
    }

    return $TRUE;
}
