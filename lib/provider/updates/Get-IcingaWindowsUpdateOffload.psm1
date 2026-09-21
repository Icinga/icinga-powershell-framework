<#
.SYNOPSIS
    Returns the current configuration status of the Windows Update Offload feature.
.DESCRIPTION
    Checks if the Windows Update Offload feature is currently enabled in the
    Icinga PowerShell configuration under 'Framework.WindowsUpdateOffload'.
.FUNCTIONALITY
    Retrieves the Windows Update Offload feature state.
.OUTPUTS
    System.Boolean
.EXAMPLE
    PS>Get-IcingaWindowsUpdateOffload;
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaWindowsUpdateOffload()
{
    $UpdateOffload = Get-IcingaPowerShellConfig -Path 'Framework.WindowsUpdateOffload';

    if ($null -eq $UpdateOffload) {
        return $FALSE;
    }

    return $UpdateOffload;
}
