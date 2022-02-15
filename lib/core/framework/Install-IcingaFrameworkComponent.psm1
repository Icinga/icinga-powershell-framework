<#
.SYNOPSIS
   Installs a PowerShell Module within the 'icinga-powershell-' namespace
   from GitHub or custom locations and installs it into the module directory
   the Framework itself is installed to
.DESCRIPTION
   Installs a PowerShell Module within the 'icinga-powershell-' namespace
   from GitHub or custom locations and installs it into the module directory
   the Framework itself is installed to
.FUNCTIONALITY
   Download and install a PowerShell module from the 'icinga-powershell-' namespace
.EXAMPLE
   PS>Install-IcingaFrameworkComponent -Name 'plugins' -Release;
.EXAMPLE
   PS>Install-IcingaFrameworkComponent -Name 'plugins' -Release -DryRun;
.PARAMETER Name
   The name of the module to install. The namespace 'icinga-powershell-' is added
   by the function automatically
.PARAMETER GitHubUser
   Overwrite the default GitHub user for a different one to download modules from
.PARAMETER Url
   Specify a direct Url to a ZIP-Archive for external or local web ressources or
   local network shares
.PARAMETER Release
   Download the latest Release version from a GitHub source
.PARAMETER Snapshot
   Download the latest master branch from a GitHub source
.PARAMETER DryRun
   Only fetch possible Urls and return the result. No download or installation
   will be done
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Install-IcingaFrameworkComponent()
{
    param(
        [string]$Name,
        [string]$GitHubUser = 'Icinga',
        [string]$Url,
        [switch]$Release    = $FALSE,
        [switch]$Snapshot   = $FALSE,
        [switch]$DryRun     = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        throw 'Please specify a component name to install from a GitHub/Local space';
    }

    Set-IcingaTLSVersion;

    $TextInfo       = (Get-Culture).TextInfo;
    $ComponentName  = $TextInfo.ToTitleCase($Name);
    $RepositoryName = [string]::Format('icinga-powershell-{0}', $Name);
    $Archive        = Get-IcingaPowerShellModuleArchive `
        -DownloadUrl $Url `
        -GitHubUser $GitHubUser `
        -ModuleName (
            [string]::Format(
                'Icinga {0}', $ComponentName
            )
        ) `
        -Repository $RepositoryName `
        -Release $Release `
        -Snapshot $Snapshot `
        -DryRun $DryRun;

    if ($Archive.Installed -eq $FALSE -Or $DryRun) {
        return @{
            'RepoUrl' = $Archive.DownloadUrl
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
        Write-IcingaConsoleNotice ([string]::Format('{0} Module Directory "{1}" is not present. Creating Directory', $ComponentName, $PluginDirectory));
        New-Item -Path $PluginDirectory -ItemType Directory | Out-Null;
    }

    Write-IcingaConsoleNotice ([string]::Format('Copying files to {0}', $ComponentName));
    Copy-ItemSecure -Path (Join-Path -Path $ModuleContent -ChildPath '/*') -Destination $PluginDirectory -Recurse -Force | Out-Null;

    Write-IcingaConsoleNotice 'Cleaning temporary content';
    Start-Sleep -Seconds 1;
    Remove-ItemSecure -Path $Archive.Directory -Recurse -Force | Out-Null;

    Unblock-IcingaPowerShellFiles -Path $PluginDirectory;

    # In case the plugins are not installed before, load the framework again to
    # include the plugins
    Use-Icinga;

    if ([string]::IsNullOrEmpty((Get-IcingaJEAContext)) -eq $FALSE) {
        Write-IcingaConsoleNotice 'Updating Icinga JEA profile';
        Invoke-IcingaCommand -ScriptBlock { Install-IcingaJEAProfile; } | Out-Null;
    }

    # Unload the module if it was loaded before
    Remove-Module $PluginDirectory -Force -ErrorAction SilentlyContinue;
    # Now import the module
    Import-Module $PluginDirectory;

    Write-IcingaConsoleNotice ([string]::Format('Icinga {0} update has been completed. Please start a new PowerShell to apply it', $ComponentName));

    return @{
        'RepoUrl' = $Archive.DownloadUrl
    };
}
