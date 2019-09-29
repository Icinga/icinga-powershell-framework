function Get-IcingaAgentMSIPackage()
{
    param(
        [string]$Source,
        [string]$Version,
        [switch]$SkipDownload
    );

    if ([string]::IsNullOrEmpty($Version)) {
        throw 'Please specify a valid version: "snapshot", "latest" or a specific version like "2.11.0"';
    }

    if ([string]::IsNullOrEmpty($Source)) {
        throw 'Please specify a valid download URL, like "https://packages.icinga.com/windows/"';
    }

    # Disable the progress bar for the WebRequest
    $ProgressPreference = "SilentlyContinue";
    $Architecture = Get-IcingaAgentArchitecture;
    $LastUpdate   = $null;

    if ($Version -eq 'snapshot' -Or $Version -eq 'latest') {
        $Content      = (Invoke-WebRequest -Uri $Source -UseBasicParsing).RawContent.Split("`r`n");
        $UsePackage   = $null;

        foreach ($line in $Content) {
            if ($line -like '*.msi*' -And $line -like "*$Architecture*") {
                #Write-Host '#####' $line
                $MSIPackage = $line.SubString(
                    $line.IndexOf('Icinga2-'),
                    $line.IndexOf('.msi') - $line.IndexOf('Icinga2-')
                );
                $LastUpdate = $line.SubString(
                    $line.IndexOf('indexcollastmod">') + 17,
                    $line.Length - $line.IndexOf('indexcollastmod">') - 17
                );
                $LastUpdate = $LastUpdate.SubString(0, $LastUpdate.IndexOf(' '));
                $LastUpdate = $LastUpdate.Replace('-', '');
                $MSIPackage = [string]::Format('{0}.msi', $MSIPackage);
                if ($Version -eq 'snapshot') {
                    if ($line -like '*snapshot*') {
                        $UsePackage = $MSIPackage;
                        break;
                    }
                } elseif ($Version -eq 'latest') {
                    if ($line -like '*snapshot*') {
                        continue;
                    }
                    $UsePackage = $MSIPackage;
                    break;
                }
            }
        }
    } else {
        $UsePackage = [string]::Format('Icinga2-v{0}-{1}.msi', $Version, $Architecture);
    }

    if ($null -eq $UsePackage) {
        throw 'No Icinga installation MSI package for your architecture could be found for the provided version and source';
    }

    if ($SkipDownload -eq $FALSE) {
        $DownloadPath = Join-Path $Env:TEMP -ChildPath $UsePackage;
        Write-Host ([string]::Format('Download Icinga 2 Agent installer "{0}" into temp directory "{1}"', $UsePackage, $DownloadPath));
        Invoke-WebRequest -Uri ([string]::Format('{0}/{1}', $Source, $UsePackage)) -OutFile $DownloadPath;
    }

    return @{
        'InstallerPath' = $DownloadPath;
        'Version'       = ($UsePackage).Replace('Icinga2-v', '').Replace($Architecture, '').Replace('.msi', '').Replace('-', '');
        'LastUpdate'    = $LastUpdate;
    }
}
