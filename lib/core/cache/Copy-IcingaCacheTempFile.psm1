function Copy-IcingaCacheTempFile()
{
    param (
        [string]$CacheFile    = '',
        [string]$CacheTmpFile = ''
    );

    # Copy the new file over the old one
    Copy-ItemSecure -Path $CacheTmpFile -Destination $CacheFile -Force | Out-Null;
    # Remove the old file
    Remove-ItemSecure -Path $CacheTmpFile -Retries 5 -Force | Out-Null;
}
