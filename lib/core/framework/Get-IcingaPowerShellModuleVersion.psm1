<#
.SYNOPSIS
   Get the version of an installed PowerShell Module
.DESCRIPTION
   Get the version of an installed PowerShell Module
.FUNCTIONALITY
   Get the version of an installed PowerShell Module
.EXAMPLE
   PS>Get-IcingaPowerShellModuleVersion -ModuleName 'icinga-powershell-framework';
.EXAMPLE
   PS>Get-IcingaPowerShellModuleVersion -ModuleName 'icinga-powershell-plugins';
.PARAMETER ModuleName
   The PowerShell module to fetch the installed version from
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaPowerShellModuleVersion()
{
    param(
        $ModuleName
    );

    $ModuleDetails = Get-Module -Name $ModuleName;

    if ($null -eq $ModuleDetails) {
        return $null;
    }

    return $ModuleDetails.PrivateData.Version;
}
