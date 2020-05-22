<#
.SYNOPSIS
   Installs the Icinga Plugins PowerShell module from a remote or local source
.DESCRIPTION
   Installs the Icinga PowerShell Plugins from a remote or local source into the
   PowerShell module folder and makes them available for usage with Icinga 2 or
   other components.
.FUNCTIONALITY
   Installs the Icinga Plugins PowerShell module from a remote or local source
.EXAMPLE
   PS>Install-IcingaFrameworkPlugins;
.EXAMPLE
   PS>Install-IcingaFrameworkPlugins -PluginsUrl 'C:/icinga/icinga-plugins.zip';
.EXAMPLE
   PS>Install-IcingaFrameworkPlugins -PluginsUrl 'https://github.com/Icinga/icinga-powershell-plugins/archive/v1.0.0.zip';
.PARAMETER PluginsUrl
   The URL pointing either to a local or remote ressource to download the plugins from. This requires to be the
   full path to the .zip file to download.
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

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

    $PluginDirectory = (Join-Path -Path $Archive.ModuleRoot -ChildPath $RepositoryName);

    if ((Test-Path $PluginDirectory) -eq $FALSE) {
        Write-IcingaConsoleNotice ([string]::Format('Plugin Module Directory "{0}" is not present. Creating Directory', $PluginDirectory));
        New-Item -Path $PluginDirectory -ItemType Directory | Out-Null;
    }

    Write-IcingaConsoleNotice 'Copying files to plugins';
    Copy-ItemSecure -Path (Join-Path -Path $ModuleContent -ChildPath '/*') -Destination $PluginDirectory -Recurse -Force | Out-Null;

    Write-IcingaConsoleNotice 'Cleaning temporary content';
    Start-Sleep -Seconds 1;
    Remove-ItemSecure -Path $Archive.Directory -Recurse -Force | Out-Null;

    Unblock-IcingaPowerShellFiles -Path $PluginDirectory;
    # In case the plugins are not installed before, load the framework again to
    # include the plugins
    Use-Icinga;

    Write-IcingaConsoleNotice 'Icinga Plugin update has been completed';

    return @{
        'PluginUrl' = $Archive.DownloadUrl
    };
}
