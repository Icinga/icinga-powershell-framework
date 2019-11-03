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
