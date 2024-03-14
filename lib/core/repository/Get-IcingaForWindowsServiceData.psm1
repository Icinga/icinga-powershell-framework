function Get-IcingaForWindowsServiceData()
{
    $IcingaForWindowsService = $Global:Icinga.Protected.Environment.'PowerShell Service';

    [hashtable]$ServiceData = @{
        'Binary'    = '';
        'Directory' = '';
        'FullPath'  = '';
        'User'      = '';
    }

    if ($null -ne $IcingaForWindowsService -And ([string]::IsNullOrEmpty($IcingaForWindowsService.ServicePath)) -eq $FALSE) {
        $ServicePath           = $IcingaForWindowsService.ServicePath;
        $ServicePath           = $ServicePath.SubString(0, $ServicePath.IndexOf('.exe') + 4);
        $ServicePath           = $ServicePath.Replace('"', '');
        $ServiceData.Binary    = $ServicePath.SubString($ServicePath.LastIndexOf('\') + 1, $ServicePath.Length - $ServicePath.LastIndexOf('\') - 1);
        $ServiceData.FullPath  = $ServicePath;
        $ServiceData.Directory = $ServicePath.Substring(0, $ServicePath.LastIndexOf('\') + 1);
        $ServiceData.User      = $IcingaForWindowsService.User;

        return $ServiceData;
    }

    $ServiceData.Directory = (Join-Path -Path $env:ProgramFiles -ChildPath 'icinga-framework-service');
    $ServiceData.User      = 'NT Authority\NetworkService';

    return $ServiceData;
}
