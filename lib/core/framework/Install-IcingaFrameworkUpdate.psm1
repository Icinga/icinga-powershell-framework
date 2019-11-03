function Install-IcingaFrameworkUpdate()
{
    param(
        [string]$FrameworkUrl
    );

    $ProgressPreference = "SilentlyContinue";
    $Tag                = 'Unknown';

    if ([string]::IsNullOrEmpty($FrameworkUrl)) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you provide a custom repository of the framework?' -Default 'n').result -eq 1) {
            $branch = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Which version to you want to install? (snapshot/stable)' -Default 'v' -DefaultInput 'stable').answer
            if ($branch.ToLower() -eq 'snapshot') {
                $FrameworkUrl  = 'https://github.com/Icinga/icinga-powershell-framework/archive/master.zip';
            } else {
                $LatestRelease = (Invoke-WebRequest -Uri 'https://github.com/Icinga/icinga-powershell-framework/releases/latest' -UseBasicParsing).BaseResponse.ResponseUri.AbsoluteUri;
                $FrameworkUrl  = $LatestRelease.Replace('/releases/tag/', '/archive/');
                $Tag           = $FrameworkUrl.Split('/')[-1];
                $FrameworkUrl  = [string]::Format('{0}/{1}.zip', $FrameworkUrl, $Tag);

                $CurrentVersion = Get-IcingaPowerShellModuleVersion 'icinga-powershell-framework';

                if ($null -ne $CurrentVersion -And $CurrentVersion -eq $Tag) {
                    Write-Host 'Your Icinga Framework is already up-to-date';
                    return;
                }
            }
        } else {
            $FrameworkUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the full path to your icinga framework repository' -Default 'v').answer;
        }
    }

    $ModuleDirectory = Get-IcingaFrameworkRootPath;
    $DownloadPath    = (Join-Path -Path $ENv:TEMP -ChildPath 'icinga-powershell-framework.zip');
    Write-Host ([string]::Format('Downloading Icinga Framework into "{0}"', $DownloadPath));

    Invoke-WebRequest -UseBasicParsing -Uri $FrameworkUrl -OutFile $DownloadPath;

    Write-Host ([string]::Format('Installing module into "{0}"', ($ModuleDirectory)));
    Expand-IcingaZipArchive -Path $DownloadPath -Destination $ModuleDirectory | Out-Null;

    $FolderContent = Get-ChildItem -Path $ModuleDirectory;
    $Extracted     = '';

    foreach ($entry in $FolderContent) {
        if ($entry -eq 'icinga-powershell-framework') {
            # Skip the framework directory directly
            continue;
        }
        if ($entry -like 'icinga-powershell-framework-*') {
            $Extracted = $entry;
        }
    }

    if ([string]::IsNullOrEmpty($Extracted)) {
        Write-Host 'No update package could be found.'
        return;
    }

    $NewDirectory = (Join-Path -Path $ModuleDirectory -ChildPath 'icinga-powershell-framework');
    $ExtractDir   = (Join-Path -Path $ModuleDirectory -ChildPath $Extracted);
    $BackupDir    = (Join-Path -Path $ExtractDir      -ChildPath 'previous');
    $OldBackupDir = (Join-Path -Path $NewDirectory    -ChildPath 'previous');

    if ((Test-Path $NewDirectory)) {
        if ((Test-Path (Join-Path -Path $NewDirectory -ChildPath 'cache'))) {
            Write-Host 'Importing cache into new module version...';
            Copy-Item -Path (Join-Path -Path $NewDirectory -ChildPath 'cache') -Destination $ExtractDir -Force -Recurse;
        }
        if ((Test-Path (Join-Path -Path $NewDirectory -ChildPath 'custom'))) {
            Write-Host 'Importing custom modules into new module version...';
            Copy-Item -Path (Join-Path -Path $NewDirectory -ChildPath 'custom') -Destination $ExtractDir -Force -Recurse;
        }
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
    # Fix new permissions for cache folder
    Set-IcingaAcl -Directory (Get-IcingaCacheDir);

    Test-IcingaAgent;

    Write-Host 'Framework update has been completed';
}
