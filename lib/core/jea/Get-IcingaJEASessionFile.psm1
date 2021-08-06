function Get-IcingaJEASessionFile()
{
    [string]$Path = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'RoleCapabilities\IcingaForWindows.psrc';

    if (Test-Path -Path $Path) {
        return $Path;
    }

    return '';
}
