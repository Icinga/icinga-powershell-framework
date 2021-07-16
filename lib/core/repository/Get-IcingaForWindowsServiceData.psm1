function Get-IcingaForWindowsServiceData()
{
    $IcingaForWindowsService = Get-IcingaServices -Service 'icingapowershell';

    [hashtable]$ServiceData = @{
        'Directory' = '';
        'FullPath'  = '';
        'User'      = '';
    }

    if ($null -ne $IcingaForWindowsService) {
        $ServicePath           = $IcingaForWindowsService.icingapowershell.configuration.ServicePath;
        $ServicePath           = $ServicePath.SubString(0, $ServicePath.IndexOf('.exe') + 4);
        $ServicePath           = $ServicePath.Replace('"', '');
        $ServiceData.FullPath  = $ServicePath;
        $ServiceData.Directory = $ServicePath.Substring(0, $ServicePath.LastIndexOf('\') + 1);
        $ServiceData.User      = $IcingaForWindowsService.icingapowershell.configuration.ServiceUser;

        return $ServiceData;
    }

    $ServiceData.Directory = (Join-Path -Path $env:ProgramFiles -ChildPath 'icinga-framework-service');
    $ServiceData.User      = 'NT Authority\NetworkService';

    return $ServiceData;
}
