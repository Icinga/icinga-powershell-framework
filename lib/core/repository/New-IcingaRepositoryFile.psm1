function New-IcingaRepositoryFile()
{
    param (
        [string]$Path       = $null,
        [string]$RemotePath = $null
    );

    $RepoFile = 'ifw.repo.json';
    $RepoPath = Join-Path -Path $Path -ChildPath $RepoFile;

    $IcingaRepository = New-Object -TypeName PSObject;
    $IcingaRepository | Add-Member -MemberType NoteProperty -Name 'Info' -Value (New-Object -TypeName PSObject);

    # Info
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'LocalSource'  -Value $Path;
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'RemoteSource' -Value $RemotePath;
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'Created'      -Value ((Get-Date).ToUniversalTime().ToString('yyyy\/MM\/dd HH:mm:ss'));
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'Updated'      -Value $IcingaRepository.Info.Created;
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'RepoHash'     -Value $null;

    # Packages
    $IcingaRepository | Add-Member -MemberType NoteProperty -Name 'Packages' -Value (New-Object -TypeName PSObject);

    $RepositoryFolder = Get-ChildItem -Path $Path -Recurse -Include '*.msi', '*.zip';

    foreach ($entry in $RepositoryFolder) {
        $RepoFilePath            = $entry.FullName.Replace($Path, '');
        $FileHash                = Get-FileHash -Path $entry.FullName -Algorithm SHA256;
        $ComponentName           = '';

        $IcingaForWindowsPackage = New-Object -TypeName PSObject;
        $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Hash'         -Value $FileHash.Hash;
        $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Location'     -Value $RepoFilePath;
        $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'RelativePath' -Value $TRUE;

        if ([IO.Path]::GetExtension($entry.Name) -eq '.zip') {
            $IcingaPackage = Read-IcingaPackageManifest -File $entry.FullName;
            $IcingaService = $null;
            $Version       = $null;

            if ($null -ne $IcingaPackage) {
                $PackageVersion = $IcingaPackage.ModuleVersion;
                $ComponentName  = $IcingaPackage.ComponentName;
            } else {
                $IcingaService = Read-IcingaServicePackage -File $entry.FullName;
            }
            if ($null -ne $IcingaService) {
                $PackageVersion = $IcingaService.ProductVersion;
                $ComponentName  = $IcingaService.ComponentName;
            }

            [bool]$IsSnapshot = $FALSE;

            if ($entry.FullName.ToLower() -like '*\master.zip') {
                $IsSnapshot = $TRUE;
            }

            if ([string]::IsNullOrEmpty($ComponentName) -eq $FALSE) {
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Version'      -Value $PackageVersion;
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Snapshot'     -Value $IsSnapshot;
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Architecture' -Value 'Multi';
            }
        } elseif ([IO.Path]::GetExtension($entry.Name) -eq '.msi') {
            $IcingaPackage = Read-IcingaMSIMetadata -File $entry.FullName;

            if ([string]::IsNullOrEmpty($IcingaPackage.ProductName) -eq $FALSE -And $IcingaPackage.ProductName -eq 'Icinga 2') {
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Version'      -Value $IcingaPackage.ProductVersion;
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Snapshot'     -Value $IcingaPackage.Snapshot;
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Architecture' -Value $IcingaPackage.Architecture;
                $ComponentName = 'agent';
            }
        }

        if ([string]::IsNullOrEmpty($ComponentName)) {
            continue;
        }

        if (Test-IcingaPowerShellConfigItem -ConfigObject $IcingaRepository.Packages -ConfigKey $ComponentName) {
            $IcingaRepository.Packages.$ComponentName += $IcingaForWindowsPackage;
        } else {
            $IcingaRepository.Packages | Add-Member -MemberType NoteProperty -Name $ComponentName -Value @();
            $IcingaRepository.Packages.$ComponentName += $IcingaForWindowsPackage;
        }

        $IcingaRepository.Info.RepoHash = Get-IcingaRepositoryHash -Path $Path;
    }

    Write-IcingaFileSecure -File $RepoPath -Value (ConvertTo-Json -InputObject $IcingaRepository -Depth 100);

    return $IcingaRepository;
}
