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

    if ($null -ne $SvcData -And $SvcData.Count -ne 0) {
        $ServiceConfig           = $SvcData."$ServiceName".configuration;
        $ServiceMeta             = $SvcData."$ServiceName".metadata;
        $ServiceData.Status      = [string]$ServiceConfig.Status.value;
        $ServiceData.User        = [string]$ServiceConfig.ServiceUser;
        $ServiceData.ServicePath = [string]$ServiceConfig.ServicePath;
        $ServiceData.Name        = $ServiceMeta.metadata.ServiceName;
        $ServiceData.DisplayName = $ServiceMeta.metadata.DisplayName;
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
