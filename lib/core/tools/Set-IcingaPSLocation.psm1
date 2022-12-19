function Set-IcingaPSLocation()
{
    param (
        [string]$Path = (Get-Location)
    );

    if ([string]::IsNullOrEmpty($Path)) {
        return;
    }

    if ((Test-Path $Path) -eq $FALSE) {
        return;
    }

    [string]$IfWRootPath = Get-IcingaForWindowsRootPath;
    [string]$CurrentPath = Get-Location;

    if ($CurrentPath -Like ([string]::Format('{0}*', $Path))) {
        Set-Location -Path $IfWRootPath;
    }
}
