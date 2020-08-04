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

    [Hashtable]$Result = Install-IcingaFrameworkComponent `
        -Name 'plugins' `
        -GitHubUser 'Icinga' `
        -Url $PluginsUrl;

    return @{
        'PluginUrl' = $Result.RepoUrl;
    };
}
