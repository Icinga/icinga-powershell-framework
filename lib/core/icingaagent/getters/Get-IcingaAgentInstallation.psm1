function Get-IcingaAgentInstallation()
{
    [string]$architecture = '';
    if ([IntPtr]::Size -eq 4) {
        $architecture = "x86";
        $regPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*';
    } else {
        $architecture = "x86_64";
        $regPath = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*');
    }

    $RegistryData = Get-ItemProperty $regPath;
    $IcingaData   = $null;
    foreach ($entry in $RegistryData) {
        if ($entry.DisplayName -eq 'Icinga 2') {
            $IcingaData = $entry;
            break;
        }
    }

    $IcingaService = Get-IcingaServices -Service 'icinga2';
    $ServiceUser   = 'NT AUTHORITY\NetworkService';

    if ($null -ne $IcingaService) {
        $ServiceUser = $IcingaService.icinga2.configuration.ServiceUser;
    }

    if ($null -eq $IcingaData) {
        return @{
            'Installed'    = $FALSE;
            'RootDir'      = '';
            'Version'      = (Split-IcingaVersion);
            'Architecture' = $architecture;
            'Uninstaller'  = '';
            'InstallDate'  = '';
            'User'         = $ServiceUser;
        };
    }

    return @{
        'Installed'    = $TRUE;
        'RootDir'      = $IcingaData.InstallLocation;
        'Version'      = (Split-IcingaVersion $IcingaData.DisplayVersion);
        'Architecture' = $architecture;
        'Uninstaller'  = $IcingaData.UninstallString.Replace("MsiExec.exe ", "");
        'InstallDate'  = $IcingaData.InstallDate;
        'User'         = $ServiceUser;
    };
}
