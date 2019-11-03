function Unblock-IcingaPowerShellFiles()
{
    param(
        $Path
    );

    if ([string]::IsNullOrEmpty($Path)) {
        Write-Host 'The specified directory was not found';
        return;
    }

    Write-Host 'Unblocking Icinga PowerShell Files';
    Get-ChildItem -Path $Path -Recurse | Unblock-File; 
}
