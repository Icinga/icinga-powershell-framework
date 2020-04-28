<#
.SYNOPSIS
   Test if a config entry on an object is already present
.DESCRIPTION
   Test if a config entry on an object is already present
.FUNCTIONALITY
   Test if a config entry on an object is already present
.EXAMPLE
   PS>Test-IcingaPowerShellConfigItem -ConfigObject $PSObject -ConfigKey 'keyname';
.PARAMETER ConfigObject
   The custom config object to check for
.PARAMETER ConfigKey
   The key which is checked 
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaPowerShellConfigItem()
{
    param(
        $ConfigObject,
        $ConfigKey
    );

    return ([bool]($ConfigObject.PSobject.Properties.Name -eq $ConfigKey) -eq $TRUE);
}
