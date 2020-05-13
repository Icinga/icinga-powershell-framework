function Install-IcingaFrameworkUpdate()
{
    param(
        [string]$FrameworkUrl
    );

    $RepositoryName = 'icinga-powershell-framework';
    $Archive        = Get-IcingaPowerShellModuleArchive -DownloadUrl $FrameworkUrl -ModuleName 'Icinga Framework' -Repository $RepositoryName;

    if ($Archive.Installed -eq $FALSE) {
        return @{
            'PluginUrl' = $Archive.DownloadUrl
        };
    }

    Write-IcingaConsoleNotice ([string]::Format('Installing module into "{0}"', ($Archive.Directory)));
    Expand-IcingaZipArchive -Path $Archive.Archive -Destination $Archive.Directory | Out-Null;

    $FolderContent = Get-ChildItem -Path $Archive.Directory;
    $ModuleContent = $Archive.Directory;

    foreach ($entry in $FolderContent) {
        if ($entry -like ([string]::Format('{0}*', $RepositoryName))) {
            $ModuleContent = Join-Path -Path $ModuleContent -ChildPath $entry;
            break;
        }
    }

    Write-IcingaConsoleNotice ([string]::Format('Using content of folder "{0}" for updates', $ModuleContent));

    $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;

    if ($ServiceStatus -eq 'Running') {
        Write-IcingaConsoleNotice 'Stopping Icinga PowerShell service';
        Stop-IcingaService 'icingapowershell';
        Start-Sleep -Seconds 1;
    }

    $ModuleDirectory = (Join-Path -Path $Archive.ModuleRoot -ChildPath $RepositoryName);

    if ((Test-Path $ModuleDirectory) -eq $FALSE) {
        Write-IcingaConsoleError 'Failed to update the component. Module Root-Directory was not found';
        return;
    }

    $Files = Get-ChildItem $ModuleDirectory -File '*';

    Write-IcingaConsoleNotice 'Removing files from framework';

    foreach ($ModuleFile in $Files) {
        Remove-ItemSecure -Path $ModuleFile -Force | Out-Null;
    }

    Remove-ItemSecure -Path (Join-Path $ModuleDirectory -ChildPath 'doc') -Recurse -Force | Out-Null;
    Remove-ItemSecure -Path (Join-Path $ModuleDirectory -ChildPath 'lib') -Recurse -Force | Out-Null;
    Remove-ItemSecure -Path (Join-Path $ModuleDirectory -ChildPath 'manifests') -Recurse -Force | Out-Null;

    Write-IcingaConsoleNotice 'Copying new files to framework';
    Copy-ItemSecure -Path (Join-Path $ModuleContent -ChildPath 'doc') -Destination $ModuleDirectory -Recurse -Force | Out-Null;
    Copy-ItemSecure -Path (Join-Path $ModuleContent -ChildPath 'lib') -Destination $ModuleDirectory -Recurse -Force | Out-Null;
    Copy-ItemSecure -Path (Join-Path $ModuleContent -ChildPath 'manifests') -Destination $ModuleDirectory -Recurse -Force | Out-Null;
    Copy-ItemSecure -Path (Join-Path -Path $ModuleContent -ChildPath '/*') -Destination $ModuleDirectory -Recurse -Force | Out-Null;

    Unblock-IcingaPowerShellFiles -Path $ModuleDirectory;

    Write-IcingaConsoleNotice 'Cleaning temporary content';
    Start-Sleep -Seconds 1;
    Remove-ItemSecure -Path $Archive.Directory -Recurse -Force | Out-Null;

    Write-IcingaConsoleNotice 'Framework update has been completed. Please start a new PowerShell instance now to complete the update';

    Test-IcingaAgent;

    if ($ServiceStatus -eq 'Running') {
        Write-IcingaConsoleNotice 'Starting Icinga PowerShell service';
        Start-IcingaService 'icingapowershell';
    }
}
