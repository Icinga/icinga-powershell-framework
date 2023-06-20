function Test-IcingaForWindowsCmdletLoader()
{
    param (
        [string]$Path = ''
    );

    if ([string]::IsNullOrEmpty($Path)) {
        return $FALSE;
    }

    if ((Test-Path -Path $Path) -eq $FALSE) {
        return $FALSE;
    }

    $FrameworkRootDir = [string]::Format('{0}*', (Get-IcingaForWindowsRootPath));

    if ($Path -NotLike $FrameworkRootDir) {
        return $FALSE;
    }

    return $TRUE;
}
