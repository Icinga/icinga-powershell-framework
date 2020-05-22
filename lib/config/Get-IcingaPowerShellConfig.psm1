<#
.SYNOPSIS
   Returns the configuration for a provided config path
.DESCRIPTION
   Returns the configuration for a provided config path
.FUNCTIONALITY
   Returns the configuration for a provided config path
.EXAMPLE
   PS>Get-IcingaPowerShellConfig -Path 'framework.daemons';
.PARAMETER Path
   The path to the config item to check for
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaPowerShellConfig()
{
    param(
        $Path = ''
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;

    foreach ($entry in $PathArray) {
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            return $null;
        }

        $ConfigObject = $ConfigObject.$entry;
    }

    return $ConfigObject;
}
