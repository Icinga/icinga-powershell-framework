param (
    [string]$ServiceName = '',
    [string]$TmpFilePath = ''
);

Use-Icinga -Minimal;

[string]$ErrMsg         = "";
[hashtable]$ServiceData = @{
    'Status'      = '';
    'Present'     = $FALSE;
    'Name'        = 'Unknown';
    'DisplayName' = 'Unknown';
};

try {
    $SvcData                 = Get-Service "$ServiceName" -ErrorAction Stop;
    $ServiceData.Status      = [string]$SvcData.Status;
    $ServiceData.Name        = $SvcData.Name;
    $ServiceData.DisplayName = $SvcData.DisplayName;
    $ServiceData.Present     = $TRUE;
} catch {
    $ErrMsg  = [string]::Format('Failed to get data for service "{0}": {1}', $ServiceName, $_.Exception.Message);
}

Write-IcingaFileSecure -File "$TmpFilePath" -Value (
    @{
        'Service' = $ServiceData;
        'Message' = [string]::Format('Successfully fetched data for service "{0}"', $ServiceName);
        'ErrMsg'  = $ErrMsg;
    } | ConvertTo-Json -Depth 100
);
