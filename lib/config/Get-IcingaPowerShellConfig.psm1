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
    param (
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

    <#
    # Alternate config parser. Might come handy in the future, requires to redesign
    # Set-IcingaPowerShellConfig including all calls for full coverage
    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Index   = 0;
    $entry        = $PathArray[$Index];

    while ($Index -lt $PathArray.Count) {
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry) -And $Index -lt $PathArray.Count) {
            $Index += 1;
            $entry  = [string]::Format('{0}.{1}', $entry, $PathArray[$Index]);

            continue;
        } elseif (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry) -And $Index -ge $PathArray.Count) {
            return $null;
        }

        $ConfigObject = $ConfigObject.$entry;
        $Index       += 1;
        $entry        = $PathArray[$Index];
    }

    return $ConfigObject;
    #>
}
