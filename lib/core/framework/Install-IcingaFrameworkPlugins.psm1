function Install-IcingaFrameworkPlugins()
{
    param(
        [string]$PluginsUrl
    );

    $ProgressPreference = "SilentlyContinue";
    $Tag                = 'Unknown';

    if ([string]::IsNullOrEmpty($PluginsUrl)) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you provide a custom repository for the Icinga Plugins?' -Default 'n').result -eq 1) {
            $branch = (Get-IcingaAgentInstallerAnswerInput 'Which version to you want to install? (snapshot/stable)' -Default 'v' -DefaultInput 'stable').answer
            if ($branch.ToLower() -eq 'snapshot') {
                $PluginsUrl  = 'https://github.com/Icinga/icinga-powershell-plugins/archive/master.zip';
            } else {
                $LatestRelease = (Invoke-WebRequest -Uri 'https://github.com/Icinga/icinga-powershell-plugins/releases/latest' -UseBasicParsing).BaseResponse.ResponseUri.AbsoluteUri;
                $PluginsUrl    = $LatestRelease.Replace('/releases/tag/', '/archive/');
                $Tag           = $PluginsUrl.Split('/')[-1];
                $PluginsUrl    = [string]::Format('{0}/{1}.zip', $PluginsUrl, $Tag);

                $CurrentVersion = Get-IcingaPowerShellModuleVersion 'icinga-powershell-plugins';

                if ($null -ne $CurrentVersion -And $CurrentVersion -eq $Tag) {
                    Write-Host 'Your Icinga Plugins are already up-to-date';
                    return @{
                        'PluginUrl' = $PluginsUrl
                    };
                }
            }
        } else {
            $PluginsUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the full path to your Icinga Plugin repository' -Default 'v').answer;
        }
    }

    $ModuleDirectory = Get-IcingaFrameworkRootPath;
    $DownloadPath    = (Join-Path -Path $ENv:TEMP -ChildPath 'icinga-powershell-plugins.zip');
    Write-Host ([string]::Format('Downloading Icinga Plugins into "{0}"', $DownloadPath));

    Invoke-WebRequest -UseBasicParsing -Uri $PluginsUrl -OutFile $DownloadPath;

    Write-Host ([string]::Format('Installing plugins into "{0}"', ($ModuleDirectory)));
    Expand-IcingaZipArchive -Path $DownloadPath -Destination $ModuleDirectory | Out-Null;

    $FolderContent = Get-ChildItem -Path $ModuleDirectory;
    $Extracted     = '';

    foreach ($entry in $FolderContent) {
        if ($entry -eq 'icinga-powershell-plugins') {
            # Skip the plugins directory directly
            continue;
        }
        if ($entry -like 'icinga-powershell-plugins-*') {
            $Extracted = $entry;
        }
    }

    if ([string]::IsNullOrEmpty($Extracted)) {
        Write-Host 'No update package could be found.'
        return @{
            'PluginUrl' = $PluginsUrl
        };
    }

    $NewDirectory = (Join-Path -Path $ModuleDirectory -ChildPath 'icinga-powershell-plugins');
    $ExtractDir   = (Join-Path -Path $ModuleDirectory -ChildPath $Extracted);
    $BackupDir    = (Join-Path -Path $ExtractDir      -ChildPath 'previous');
    $OldBackupDir = (Join-Path -Path $NewDirectory    -ChildPath 'previous');

    if ((Test-Path $NewDirectory)) {
        Write-Host 'Creating backup directory';
        if ((Test-Path $OldBackupDir)) {
            Write-Host 'Importing old backups into new module version...';
            Move-Item -Path $OldBackupDir -Destination $ExtractDir;
        } else {
            Write-Host 'No previous backups found. Creating new backup space';
            if ((Test-Path $BackupDir) -eq $FALSE) {
                New-Item -Path $BackupDir -ItemType Container | Out-Null;
            }
        }
        Write-Host 'Moving old module into backup directory';
        Move-Item -Path $NewDirectory -Destination (Join-Path -Path $BackupDir -ChildPath (Get-Date -Format "MM-dd-yyyy-HH-mm-ffff"));
    }

    Write-Host ([string]::Format('Installing new module version "{0}"', $Tag));
    Start-Sleep -Seconds 2;
    Move-Item -Path (Join-Path -Path $ModuleDirectory -ChildPath $Extracted) -Destination $NewDirectory;

    Unblock-IcingaPowerShellFiles -Path $NewDirectory;
    # In case the plugins are not installed before, load the framework again to
    # include the plugins
    Use-Icinga;

    Write-Host 'Icinga Plugin update has been completed';

    return @{
        'PluginUrl' = $PluginsUrl
    };
}
