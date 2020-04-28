<#
.SYNOPSIS
   Sets a config entry for a given path to a certain value
.DESCRIPTION
   Sets a config entry for a given path to a certain value
.FUNCTIONALITY
   Sets a config entry for a given path to a certain value
.EXAMPLE
   PS>Set-IcingaPowerShellConfig -Path 'framework.daemons.servicecheck' -Value $DaemonConfig;
.PARAMETER Path
   The path to the config item to be set
.PARAMETER Value
   The value to be set for a specific config path
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Set-IcingaPowerShellConfig()
{
    param(
        $Path  = '',
        $Value = $null
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Index   = $PathArray.Count;
    $InputValue   = $null;
    foreach ($entry in $PathArray) {
        if ($index -eq  1) {
            $InputValue = $Value;
        }
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            New-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry -ConfigValue $InputValue;
        }

        if ($index -eq  1) {
            $ConfigObject.$entry = $Value;
            break;
        }

        $ConfigObject = $ConfigObject.$entry;
        $index -= 1;
    }

    Write-IcingaPowerShellConfig $Config;
}
