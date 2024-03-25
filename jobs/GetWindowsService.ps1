param (
    [string]$ServiceName = '',
    [string]$TmpFilePath = ''
);

Use-Icinga -Minimal;

[string]$ErrMsg         = "";
[hashtable]$ServiceData = @{
    'Status'      = '';
    'Present'     = $FALSE;
    'Name'        = $ServiceName;
    'DisplayName' = $ServiceName;
    'User'        = 'Unknown';
    'ServicePath' = '';
};

try {
    $SvcData = Get-IcingaServices "$ServiceName" -ErrorAction Stop;

    if ($null -ne $SvcData) {
        $ServiceData.Status      = [string]$SvcData."$ServiceName".configuration.Status.value;
        $ServiceData.User        = [string]$SvcData."$ServiceName".configuration.ServiceUser;
        $ServiceData.ServicePath = [string]$SvcData."$ServiceName".configuration.ServicePath;
        $ServiceData.Name        = $SvcData."$ServiceName".metadata.ServiceName;
        $ServiceData.DisplayName = $SvcData."$ServiceName".metadata.DisplayName;
        $ServiceData.Present     = $TRUE;
    }
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
