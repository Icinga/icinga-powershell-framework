<#
.SYNOPSIS
   Reads the entire configuration and returns it as custom object
.DESCRIPTION
   Reads the entire configuration and returns it as custom object
.FUNCTIONALITY
   Reads the entire configuration and returns it as custom object
.EXAMPLE
   PS>Read-IcingaPowerShellConfig;
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Read-IcingaPowerShellConfig()
{
    $ConfigDir  = Get-IcingaPowerShellConfigDir;
    $ConfigFile = Join-Path -Path $ConfigDir -ChildPath 'config.json';

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon) {
        if ($global:IcingaDaemonData.ContainsKey('Config')) {
            return $global:IcingaDaemonData.Config;
        }
    }

    if (-Not (Test-Path $ConfigFile)) {
        return (New-Object -TypeName PSOBject);
    }

    [string]$Content = Get-Content -Path $ConfigFile;

    if ([string]::IsNullOrEmpty($Content)) {
        return (New-Object -TypeName PSOBject);
    }

    return (ConvertFrom-Json -InputObject $Content);
}
