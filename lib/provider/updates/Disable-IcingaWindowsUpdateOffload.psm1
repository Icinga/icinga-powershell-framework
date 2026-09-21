<#
.SYNOPSIS
    Disables the Windows Update Offload feature.
.DESCRIPTION
    Disables the Windows Update Offload feature. The background scheduled task
    ('Fetch Windows Updates') is stopped and unregistered, the internal configuration
    is set to FALSE, and the cached XML file is safely removed.

    Subsequent check executions will query the Windows Update COM object directly,
    which requires appropriate permissions.

    This command requires administrative privileges.
.FUNCTIONALITY
    Disables Windows Update Offload and cleans up tasks and cache files.
.EXAMPLE
    PS>Disable-IcingaWindowsUpdateOffload;
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaWindowsUpdateOffload()
{
    # Only run this if we use an administrative shell
    if (-not (Test-AdministrativeShell)) {
        Write-IcingaConsoleError 'You require administrative privileges to run this command';
        return;
    }

    # Disable scheduled tasks and clear internal config values
    $Global:Icinga.Protected.WindowsUpdateOffload = $FALSE;
    Set-IcingaPowerShellConfig -Path 'Framework.WindowsUpdateOffload' -Value $FALSE;

    Unregister-IcingaWindowsScheduledTaskWindowsUpdates;

    # Remove the XML file containing the update information to not store old data
    $UpdateFile = Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'provider\windows_updates\pending.xml';
    Remove-ItemSecure -Path $UpdateFile -Retries 5 -Force | Out-Null;
}
