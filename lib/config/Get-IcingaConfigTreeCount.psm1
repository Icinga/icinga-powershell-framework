<#
.SYNOPSIS
   Returns the amount of items for a config item
.DESCRIPTION
   Returns the amount of items for a config item
.FUNCTIONALITY
   Returns the amount of items for a config item
.EXAMPLE
   PS>Get-IcingaConfigTreeCount -Path 'framework.daemons';
.PARAMETER Path
   The path to the config item to check for
.INPUTS
   System.String
.OUTPUTS
   System.Integer
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaConfigTreeCount()
{
    param(
        $Path = ''
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Count   = 0;

    foreach ($entry in $PathArray) {
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            continue;
        }

        $ConfigObject = $ConfigObject.$entry;
    }

    foreach ($config in $ConfigObject.PSObject.Properties) {
        $Count += 1;
    }

    return $Count;
}
