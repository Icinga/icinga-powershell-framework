param (
    [string]$ServiceName = '',
    [string]$TmpFilePath = ''
);

Use-Icinga -Minimal;

[bool]$Success  = $TRUE;
[string]$ErrMsg = "";
[string]$Status = '';

try {
    Restart-Service "$ServiceName" -ErrorAction Stop;
    $Status = [string](Get-Service "$ServiceName").Status;
} catch {
    $Success = $FALSE;
    $ErrMsg  = [string]::Format('Failed to restart service "{0}": {1}', $ServiceName, $_.Exception.Message);
}

Write-IcingaFileSecure -File "$TmpFilePath" -Value (
    @{
        'Success' = $Success;
        'Message' = [string]::Format('Service "{0}" successfully restarted', $ServiceName);
        'ErrMsg'  = $ErrMsg;
        'Status'  = $Status;
    } | ConvertTo-Json -Depth 100
);
