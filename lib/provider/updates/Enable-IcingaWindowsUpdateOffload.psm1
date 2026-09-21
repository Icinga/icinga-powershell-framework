<#
.SYNOPSIS
    Enables the Windows Update Offload feature.
.DESCRIPTION
    Enables the Windows Update Offload feature. When enabled, a Windows Scheduled Task
    ('Fetch Windows Updates') running as SYSTEM will fetch pending Windows updates in
    the background every 10 minutes and save them securely to the cache directory.

    Check plugins will read the update state from the cache file instead of querying
    the Windows Update COM-Object live. This allows running the Icinga Agent service
    as a non-SYSTEM user without requiring JEA.

    This command requires administrative privileges.
.FUNCTIONALITY
    Enables Windows Update Offload and registers the background task.
.PARAMETER Silent
    Suppresses console error and notice messages.
.EXAMPLE
    PS>Enable-IcingaWindowsUpdateOffload;
.EXAMPLE
    PS>Enable-IcingaWindowsUpdateOffload -Silent;
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaWindowsUpdateOffload()
{
    param (
        [switch]$Silent = $false
    );

    # Only run this if we use an administrative shell
    if (-not (Test-AdministrativeShell)) {
        if (-not $Silent) {
            Write-IcingaConsoleError 'You require administrative privileges to run this command';
        }

        return;
    }

    # Register the scheduled task and set internal config values
    $Global:Icinga.Protected.WindowsUpdateOffload = $TRUE;
    Set-IcingaPowerShellConfig -Path 'Framework.WindowsUpdateOffload' -Value $TRUE;

    Register-IcingaWindowsScheduledTaskWindowsUpdates -Silent:$Silent;
}
