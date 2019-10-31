function Test-IcingaZipBinaryChecksum()
{
    param(
        $Path
    );

    $MD5Path = [string]::Format('{0}.md5', $Path);

    if ((Test-Path $MD5Path) -eq $FALSE) {
        return $TRUE;
    }

    [string]$MD5Checksum = Get-Content $MD5Path;
    $MD5Checksum         = ($MD5Checksum.Split(' ')[0]).ToLower();

    $FileHash = ((Get-FileHash $Path -Algorithm MD5).Hash).ToLower();
    
    if ($MD5Checksum -ne $FileHash) {
        return $FALSE;
    }

    return $TRUE;
}
