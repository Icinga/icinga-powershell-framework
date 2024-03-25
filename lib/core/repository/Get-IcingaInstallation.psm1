function Get-IcingaInstallation()
{
    param (
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE
    )

    Set-IcingaServiceEnvironment;

    [hashtable]$InstalledComponents = @{ };

    $PowerShellModules = Get-Module -ListAvailable;

    foreach ($entry in $PowerShellModules) {
        $RootPath = (Get-IcingaForWindowsRootPath);

        if ($entry.Path -NotLike "$RootPath*") {
            continue;
        }

        if ($entry.Name -Like 'icinga-powershell-*') {
            $ComponentName  = $entry.Name.Replace('icinga-powershell-', '');
            $InstallPackage = (Get-IcingaRepositoryPackage -Name $ComponentName -Release:$Release -Snapshot:$Snapshot);
            $LatestVersion  = '';
            $CurrentVersion = ([string]((Get-Module -ListAvailable -Name $entry.Name -ErrorAction SilentlyContinue) | Sort-Object Version -Descending | Select-Object Version -First 1).Version);

            if ($InstallPackage.HasPackage) {
                [string]$LatestVersion = $InstallPackage.Package.Version;
            }

            Add-IcingaHashtableItem `
                -Hashtable $InstalledComponents `
                -Key $ComponentName `
                -Value @{
                    'Path'           = (Join-Path -Path $RootPath -ChildPath $entry.Name);
                    'CurrentVersion' = $CurrentVersion;
                    'LatestVersion'  = $LatestVersion;
                    'LockedVersion'  = (Get-IcingaComponentLock -Name $ComponentName);
                } | Out-Null;
        }
    }

    $IcingaForWindowsService = $Global:Icinga.Protected.Environment.'PowerShell Service';

    if ($null -ne $IcingaForWindowsService -And $IcingaForWindowsService.Present) {
        $ServicePath = Get-IcingaForWindowsServiceData;

        if ($InstalledComponents.ContainsKey('service')) {
            $InstalledComponents.Remove('service');
        }

        $InstallPackage = (Get-IcingaRepositoryPackage -Name 'service' -Release:$Release -Snapshot:$Snapshot);
        $LatestVersion  = '';
        $CurrentVersion = ([string]((Read-IcingaServicePackage -File $ServicePath.FullPath).ProductVersion));

        if ($InstallPackage.HasPackage) {
            [string]$LatestVersion = $InstallPackage.Package.Version;
        }

        $InstalledComponents.Add(
            'service',
            @{
                'Path'           = $ServicePath.Directory;
                'CurrentVersion' = $CurrentVersion;
                'LatestVersion'  = $LatestVersion;
                'LockedVersion'  = (Get-IcingaComponentLock -Name 'service');
            }
        )
    }

    $IcingaAgent = Get-IcingaAgentInstallation;

    if ($InstalledComponents.ContainsKey('agent')) {
        $InstalledComponents.Remove('agent');
    }

    if ($IcingaAgent.Installed) {

        $InstallPackage = (Get-IcingaRepositoryPackage -Name 'agent' -Release:$Release -Snapshot:$Snapshot);
        $LatestVersion  = '';
        $CurrentVersion = ([string]$IcingaAgent.Version.Full);

        if ($InstallPackage.HasPackage) {
            $LatestVersion = $InstallPackage.Package.Version;
        }

        $InstalledComponents.Add(
            'agent',
            @{
                'Path'           = $IcingaAgent.RootDir;
                'CurrentVersion' = $CurrentVersion;
                'LatestVersion'  = $LatestVersion;
                'LockedVersion'  = (Get-IcingaComponentLock -Name 'agent');
            }
        )
    }

    return $InstalledComponents;
}
