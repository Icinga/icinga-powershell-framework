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
        $ServiceConfig           = $SvcData."$ServiceName".configuration;
        $ServiceMeta             = $SvcData."$ServiceName".metadata;
        $ServiceInfo.Status      = [string]$ServiceConfig.Status.value;
        $ServiceInfo.User        = [string]$ServiceConfig.ServiceUser;
        $ServiceInfo.ServicePath = [string]$ServiceConfig.ServicePath;
        $ServiceInfo.Name        = $ServiceMeta.ServiceName;
        $ServiceInfo.DisplayName = $ServiceMeta.DisplayName;
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
