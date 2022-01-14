<#
.SYNOPSIS
   Creates a new config entry with given arguments
.DESCRIPTION
   Creates a new config entry with given arguments
.FUNCTIONALITY
   Creates a new config entry with given arguments
.EXAMPLE
   PS>New-IcingaPowerShellConfigItem -ConfigObject $PSObject -ConfigKey 'keyname' -ConfigValue 'keyvalue';
.PARAMETER ConfigObject
   The custom config object to modify
.PARAMETER ConfigKey
   The key which is added to the config object
.PARAMETER ConfigValue
   The value written for the ConfigKey
.INPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPowerShellConfigItem()
{
    param(
        $ConfigObject,
        [string]$ConfigKey,
        $ConfigValue       = $null
    );

    if ($null -eq $ConfigValue) {
        $ConfigValue = (New-Object -TypeName PSObject);
    }

    $ConfigObject | Add-Member -MemberType NoteProperty -Name $ConfigKey -Value $ConfigValue;
}
