function Get-IcingaAgentMSIPackage()
{
    param(
        [string]$Source,
        [string]$Version,
        [switch]$SkipDownload
    );

    if ([string]::IsNullOrEmpty($Version)) {
        throw 'Please specify a valid version: "release", "snapshot" or a specific version like "2.11.0"';
    }

    if ([string]::IsNullOrEmpty($Source)) {
        throw 'Please specify a valid download URL, like "https://packages.icinga.com/windows/"';
    }

    Set-IcingaTLSVersion;
    # Disable the progress bar for the WebRequest
    $ProgressPreference = "SilentlyContinue";
    $Architecture = Get-IcingaAgentArchitecture;
    $LastUpdate   = $null;
    $Version      = $Version.ToLower();

    if ($Version -eq 'snapshot' -Or $Version -eq 'release') {
        if (Test-Path $Source) {
            $Content = Get-ChildItem -Path $Source;

            foreach ($entry in $Content) {
                # Only check for MSI packages
                if ($entry.Extension.ToLower() -ne '.msi') {
                    continue;
                }

                $PackageVersion = '';

                if ($entry.Name.ToLower().Contains('-')) {
                    $PackageVersion = ($entry.Name.Split('-')[1]).Replace('v', '');
                }

                if ($Version -eq 'snapshot') {
                    if ($PackageVersion -eq 'snapshot')  {
                        $UseVersion = 'snapshot';
                        break;
                    }
                    continue;
                }

                if ($PackageVersion -eq 'snapshot') {
                    continue;
                }

                try {
                    if ($null -eq $UseVersion -Or [version]$PackageVersion -ge [version]$UseVersion) {
                        $UseVersion = $PackageVersion;
                    }
                } catch {
                    # Nothing to catch specifically   
                }
            }
        } else {
            $Content    = (Invoke-IcingaWebRequest -Uri $Source -UseBasicParsing).RawContent.Split("`r`n");
            $UsePackage = $null;
            $UseVersion = $null;

            foreach ($line in $Content) {
                if ($line -like '*.msi*' -And $line -like "*$Architecture.msi*") {
                    $MSIPackage = $line.SubString(
                        $line.IndexOf('Icinga2-'),
                        $line.IndexOf('.msi') - $line.IndexOf('Icinga2-')
                    );
                    $LastUpdate = $line.SubString(
                        $line.IndexOf('indexcollastmod">') + 17,
                        $line.Length - $line.IndexOf('indexcollastmod">') - 17
                    );
                    $LastUpdate     = $LastUpdate.SubString(0, $LastUpdate.IndexOf(' '));
                    $LastUpdate     = $LastUpdate.Replace('-', '');
                    $MSIPackage     = [string]::Format('{0}.msi', $MSIPackage);
                    $PackageVersion = ($MSIPackage.Split('-')[1]).Replace('v', '');

                    if ($Version -eq 'snapshot') {
                        if ($PackageVersion -eq 'snapshot') {
                            $UseVersion = 'snapshot';
                            break;
                        }
                    } elseif ($Version -eq 'release') {
                        if ($line -like '*snapshot*' -Or $line -like '*-rc*') {
                            continue;
                        }

                        if ($null -eq $UseVersion -Or [version]$PackageVersion -ge [version]$UseVersion) {
                            $UseVersion = $PackageVersion;
                        }
                    }
                }
            }
        }
        if ($Version -eq 'snapshot') {
            $UsePackage = [string]::Format('Icinga2-{0}-{1}.msi', $UseVersion, $Architecture);
        } else {
            $UsePackage = [string]::Format('Icinga2-v{0}-{1}.msi', $UseVersion, $Architecture);
        }
    } else {
        $UsePackage = [string]::Format('Icinga2-v{0}-{1}.msi', $Version, $Architecture);
    }

    if ($null -eq $UsePackage) {
        throw 'No Icinga installation MSI package for your architecture could be found for the provided version and source';
    }

    if ($SkipDownload -eq $FALSE) {
        $DownloadPath = Join-Path $Env:TEMP -ChildPath $UsePackage;
        Write-IcingaConsoleNotice ([string]::Format('Downloading Icinga 2 Agent installer "{0}" into temp directory "{1}"', $UsePackage, $DownloadPath));
        Invoke-IcingaWebRequest -Uri (Join-WebPath -Path $Source -ChildPath $UsePackage) -OutFile $DownloadPath | Out-Null;
    }

    return @{
        'InstallerPath' = $DownloadPath;
        'Version'       = ($UsePackage).Replace('Icinga2-v', '').Replace('Icinga2-', '').Replace([string]::Format('-{0}.msi', $Architecture), '')
        'LastUpdate'    = $LastUpdate;
    }
}
