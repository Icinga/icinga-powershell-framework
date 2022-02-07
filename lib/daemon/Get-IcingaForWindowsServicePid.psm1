function Get-IcingaForWindowsServicePid()
{
    [string]$PidFile = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'service.pid');
    [string]$IfWPid  = Read-IcingaFileSecure -File $PidFile;

    if ([string]::IsNullOrEmpty($IfWPid) -eq $FALSE) {
        $IfWPid = $IfWPid.Replace("`r`n", '').Replace("`n", '').Replace(' ', '');
    }

    return $IfWPid;
}
