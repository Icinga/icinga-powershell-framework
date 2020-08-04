<#
.SYNOPSIS
    Unblocks a folder with PowerShell module/script files to make them usable
    on certain environments
.DESCRIPTION
    Wrapper command to unblock recursively a certain folder for PowerShell script
    and module files
.FUNCTIONALITY
    Unblocks a folder with PowerShell module/script files to make them usable
    on certain environments
.EXAMPLE
    PS>Unblock-IcingaPowerShellFiles -Path 'C:\Program Files\WindowsPowerShell\Modules\my-module';
.PARAMETER Path
    The path to a PowerShell module folder or script file to unblock it
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Unblock-IcingaPowerShellFiles()
{
    param(
        $Path
    );

    if ([string]::IsNullOrEmpty($Path)) {
        Write-IcingaConsoleError 'The specified directory was not found';
        return;
    }

    Write-IcingaConsoleNotice 'Unblocking Icinga PowerShell Files';
    Get-ChildItem -Path $Path -Recurse | Unblock-File;
}
