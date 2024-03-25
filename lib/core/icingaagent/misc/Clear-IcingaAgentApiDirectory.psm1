<#
.SYNOPSIS
   Clears the entire content of the Icinga Agent API directory located
   at Program Data\icinga2\var\lib\icinga2\api\
.DESCRIPTION
   Clears the entire content of the Icinga Agent API directory located
   at Program Data\icinga2\var\lib\icinga2\api\
.FUNCTIONALITY
   Clears the entire content of the Icinga Agent API directory located
   at Program Data\icinga2\var\lib\icinga2\api\
.EXAMPLE
   PS>Clear-IcingaAgentApiDirectory;
.EXAMPLE
   PS>Clear-IcingaAgentApiDirectory -Force;
.PARAMETER Force
   In case the Icinga Agent service is running while executing the command,
   the force argument will ensure the service is stopped before the API
   directory is flushed and restarted afterwards
.INPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Clear-IcingaAgentApiDirectory()
{
    param (
        [switch]$Force = $FALSE
    );

    $IcingaService = $Global:Icinga.Protected.Environment.'Icinga Service';
    $ApiDirectory  = (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\api\');

    if ((Test-Path $ApiDirectory) -eq $FALSE) {
        Write-IcingaConsoleError 'The Icinga Agent API directory is not present on this system. Please check if the Icinga Agent is installed';
        return;
    }

    if ($IcingaService.Status -eq 'Running' -And $Force -eq $FALSE) {
        Write-IcingaConsoleError 'The API directory can not be deleted while the Icinga Agent is running. Use the "-Force" argument to stop the service, flush the directory and restart the service again.';
        return;
    }

    if ($IcingaService.Status -eq 'Running') {
        Stop-IcingaService icinga2;
        Start-Sleep -Seconds 1;
    }

    Write-IcingaConsoleNotice 'Flushing Icinga Agent API directory';
    Remove-ItemSecure -Path (Join-Path -Path $ApiDirectory -ChildPath '*') -Recurse -Force | Out-Null;
    Start-Sleep -Seconds 1;

    if ($IcingaService.Status -eq 'Running') {
        Start-IcingaService icinga2;
    }
}
