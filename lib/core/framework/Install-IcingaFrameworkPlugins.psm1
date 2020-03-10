function Install-IcingaFrameworkPlugins()
{
    param(
        [string]$PluginsUrl
    );

    $RepositoryName = 'icinga-powershell-plugins';
    $Archive        = Get-IcingaPowerShellModuleArchive -DownloadUrl $PluginsUrl -ModuleName 'Icinga Plugins' -Repository $RepositoryName;

    if ($Archive.Installed -eq $FALSE) {
        return @{
            'PluginUrl' = $Archive.DownloadUrl
        };
    }

    Write-Host ([string]::Format('Installing module into "{0}"', ($Archive.Directory)));
    Expand-IcingaZipArchive -Path $Archive.Archive -Destination $Archive.Directory | Out-Null;

    $FolderContent = Get-ChildItem -Path $Archive.Directory;
    $ModuleContent = $Archive.Directory;

    foreach ($entry in $FolderContent) {
        if ($entry -like ([string]::Format('{0}*', $RepositoryName))) {
            $ModuleContent = Join-Path -Path $ModuleContent -ChildPath $entry;
            break;
        }
    }

    Write-Host ([string]::Format('Using content of folder "{0}" for updates', $ModuleContent));

    $PluginDirectory = (Join-Path -Path $Archive.ModuleRoot -ChildPath $RepositoryName);

    if ((Test-Path $PluginDirectory) -eq $FALSE) {
        Write-Host ([string]::Format('Plugin Module Directory "{0}" is not present. Creating Directory', $PluginDirectory));
        New-Item -Path $PluginDirectory -ItemType Directory | Out-Null;
    }

    Write-Host 'Copying files to plugins';
    Copy-ItemSecure -Path (Join-Path -Path $ModuleContent -ChildPath '/*') -Destination $PluginDirectory -Recurse -Force | Out-Null;

    Write-Host 'Cleaning temporary content';
    Start-Sleep -Seconds 1;
    Remove-ItemSecure -Path $Archive.Directory -Recurse -Force | Out-Null;

    Unblock-IcingaPowerShellFiles -Path $PluginDirectory;
    # In case the plugins are not installed before, load the framework again to
    # include the plugins
    Use-Icinga;

    Write-Host 'Icinga Plugin update has been completed';

    return @{
        'PluginUrl' = $Archive.DownloadUrl
    };
}
