function Get-IcingaAgentInstallation()
{
    [string]$architecture = '';
    if (Test-Path 'Env:ProgramFiles(x86)') {
        $architecture = "x86_64";
        $regPath = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*');
    } else {
        $architecture = "x86";
        $regPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*';
    }

    $RegistryData = Get-ItemProperty $regPath -ErrorAction SilentlyContinue;
    $IcingaData   = $null;
    foreach ($entry in $RegistryData) {
        if ($null -eq $entry -or $null -eq $entry.DisplayName) {
            continue;
        }

        if ($entry.DisplayName -eq 'Icinga 2') {
            $IcingaData = $entry;
            break;
        }
    }

    $ServiceUser = Get-IcingaServiceUser;

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

    # Sometimes it can happen that the DisplayVersion in the registry is not correct
    # (e.g. after manual upgrades or installation failures), so we try to fetch the version from the binary itself
    $IcingaVersion = $IcingaData.DisplayVersion;

    try {
        [string]$IcingaBinary = Join-Path -Path $IcingaData.InstallLocation -ChildPath 'sbin\icinga2.exe';

        if (Test-Path -Path $IcingaBinary) {
            $IcingaVersion = (Get-Item -Path $IcingaBinary).VersionInfo.FileVersion;
        }

        if ($IcingaVersion -ne $IcingaData.DisplayVersion) {
            Write-IcingaConsoleError 'The Icinga version retrieved from the registry ({0}) differs from the version retrieved from the binary ({1}). Please make sure the installation went through and the Icinga Agent is properly updated.' -Objects $IcingaData.DisplayVersion, $IcingaVersion;
        }
    } catch {
        Write-IcingaConsoleError 'Failed to determine Icinga version from binary located at "{0}": {1}' -Objects $IcingaBinary, $_.Exception.Message;
    }

    return @{
        'Installed'    = $TRUE;
        'RootDir'      = $IcingaData.InstallLocation;
        'Version'      = (Split-IcingaVersion $IcingaVersion);
        'Architecture' = $architecture;
        'Uninstaller'  = $IcingaData.UninstallString.Replace("MsiExec.exe ", "");
        'InstallDate'  = $IcingaData.InstallDate;
        'User'         = $ServiceUser;
    };
}
