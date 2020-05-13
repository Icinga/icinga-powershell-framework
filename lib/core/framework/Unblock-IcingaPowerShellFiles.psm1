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
