function Get-IcingaJEAServicePid()
{
    [string]$JeaPidFile = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'jea.pid');
    [string]$JeaPid     = Read-IcingaFileSecure -File $JeaPidFile;

    if ([string]::IsNullOrEmpty($JeaPid) -eq $FALSE) {
        $JeaPid = $JeaPid.Replace("`r`n", '').Replace("`n", '').Replace(' ', '');
    }

    if ([string]::IsNullOrEmpty($JeaPid) -Or $JeaPid -eq '0' -Or $JeaPid -eq 0) {
        return $null;
    }

    return $JeaPid;
}
