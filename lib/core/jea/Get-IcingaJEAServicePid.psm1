function Get-IcingaJEAServicePid()
{
    [string]$JeaPidFile = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'jea.pid');
    [string]$JeaPid     = Read-IcingaFileSecure -File $JeaPidFile;

    if ([string]::IsNullOrEmpty($JeaPid) -eq $FALSE) {
        $JeaPid = $JeaPid.Replace("`r`n", '').Replace("`n", '').Replace(' ', '');
    }

    return $JeaPid;
}
