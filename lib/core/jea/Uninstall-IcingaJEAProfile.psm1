function Uninstall-IcingaJEAProfile()
{
    $JeaProfile           = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'IcingaForWindows.pssc';
    $JeaProfileRessource  = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'RoleCapabilities\IcingaForWindows.psrc';

    if (Test-Path $JeaProfile) {
        Write-IcingaConsoleNotice 'Removing JEA profile';
        Remove-Item $JeaProfile -Force;
    }

    if (Test-Path $JeaProfileRessource) {
        Write-IcingaConsoleNotice 'Removing JEA profile ressource';
        Remove-Item $JeaProfileRessource -Force;
    }

    Write-IcingaConsoleNotice 'Removing JEA profile registration';
    Unregister-PSSessionConfiguration -Name 'IcingaForWindows' -Force -ErrorAction SilentlyContinue;

    Set-IcingaPowerShellConfig -Path 'Framework.JEAProfile' -Value '';
}
