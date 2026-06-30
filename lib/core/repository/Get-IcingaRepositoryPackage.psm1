function Get-IcingaRepositoryPackage()
{
    param (
        [string]$Name,
        [string]$Version  = $null,
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a component name';

        return @{
            'HasPackage' = $FALSE;
            'Package'    = $null;
            'Source'     = $null;
            'Repository' = $null;
        };
    }

    if ($Name.ToLower() -eq 'kickstart') {
        return @{
            'HasPackage' = $FALSE;
            'Package'    = $null;
            'Source'     = $null;
            'Repository' = $null;
        };
    }

    $Repositories           = Get-IcingaRepositories -ExcludeDisabled;
    [Version]$LatestVersion = $null;
    $InstallPackage         = $null;
    $SourceRepo             = $null;
    $RepoName               = $null;
    [bool]$HasRepo          = $FALSE;
    [bool]$Isx86            = [bool](-not (Test-Path 'Env:ProgramFiles(x86)'));

    foreach ($entry in $Repositories) {
        $RepoContent        = Read-IcingaRepositoryFile -Name $entry.Name;
        [bool]$FoundPackage = $FALSE;

        if ($null -eq $RepoContent) {
            continue;
        }

        if ((Test-IcingaPowerShellConfigItem -ConfigObject $RepoContent -ConfigKey 'Packages') -eq $FALSE) {
            continue;
        }

        if ((Test-IcingaPowerShellConfigItem -ConfigObject $RepoContent.Packages -ConfigKey $Name) -eq $FALSE) {
            continue;
        }

        foreach ($package in $RepoContent.Packages.$Name) {

            if ($Snapshot -And $package.Snapshot -eq $FALSE) {
                continue;
            }

            if ($Release -And $package.Snapshot -eq $TRUE) {
                continue;
            }

            if ($package.Architecture -ne 'Multi' -And $package.Architecture -eq 'x86' -And $Isx86 -eq $FALSE) {
                continue;
            }

            if ($Snapshot -And [string]::IsNullOrEmpty($Version) -eq $FALSE -And (Test-Numeric $package.Version.Replace('.', '')) -eq $FALSE -And (Test-Numeric $Version) -eq $FALSE -And $package.Version -eq $Version) {
                $InstallPackage = $package;
                $HasRepo        = $TRUE;
                $SourceRepo     = $RepoContent;
                $RepoName       = $entry.Name;
                break;
            }

            if ((Test-Numeric $package.Version.Replace('.', '')) -eq $FALSE -Or ((Test-Numeric $Version.Replace('.', '')) -eq $FALSE -And [string]::IsNullOrEmpty($Version) -eq $FALSE) ) {
                continue;
            }

            if (([string]::IsNullOrEmpty($Version) -And ($null -eq $LatestVersion -Or $LatestVersion -lt $package.Version))) {
                [Version]$LatestVersion = [Version]$package.Version;
                $InstallPackage         = $package;
                $HasRepo                = $TRUE;
                $SourceRepo             = $RepoContent;
                $RepoName               = $entry.Name;
                continue;
            }

            if ([string]::IsNullOrEmpty($Version) -eq $FALSE -And [version]$package.Version -eq [version]$Version) {
                $InstallPackage = $package;
                $FoundPackage   = $TRUE;
                $HasRepo        = $TRUE;
                $SourceRepo     = $RepoContent;
                $RepoName       = $entry.Name;
                break;
            }
        }

        if ($FoundPackage) {
            break;
        }
    }

    return @{
        'HasPackage' = $HasRepo;
        'Package'    = $InstallPackage;
        'Source'     = $SourceRepo;
        'Repository' = $RepoName;
    };
}
