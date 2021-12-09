function Invoke-IcingaRESTAPIv1Calls()
{
    param (
        [Hashtable]$Request    = @{ },
        [Hashtable]$Connection = @{ }
    );

    [string]$ModuleToLoad = Get-IcingaRESTPathElement -Request $Request -Index 1;

    if ([string]::IsNullOrEmpty($ModuleToLoad)) {
        Send-IcingaTCPClientMessage -Message (
            New-IcingaTCPClientRESTMessage `
                -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.Ok) `
                -ContentBody @{
                    'Endpoints' = @(
                        $Global:Icinga.Public.Daemons.RESTApi.RegisteredEndpoints.Keys
                    )
                }
        ) -Stream $Connection.Stream;
        return;
    }

    if ($Global:Icinga.Public.Daemons.RESTApi.RegisteredEndpoints.ContainsKey($ModuleToLoad) -eq $FALSE) {
        Send-IcingaTCPClientMessage -Message (
            New-IcingaTCPClientRESTMessage `
                -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Not Found') `
                -ContentBody 'There was no module found which is registered for this endpoint name.'
        ) -Stream $Connection.Stream;
        return;
    }

    [string]$Command = $Global:Icinga.Public.Daemons.RESTApi.RegisteredEndpoints[$ModuleToLoad];

    Write-IcingaDebugMessage -Message 'Executing REST-Module' -Objects $Command;

    if ($null -eq (Get-Command $Command -ErrorAction SilentlyContinue)) {
        Send-IcingaTCPClientMessage -Message (
            New-IcingaTCPClientRESTMessage `
                -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Internal Server Error') `
                -ContentBody 'This API endpoint is registered, but the PowerShell Cmdlet this module is referencing too does not exist. Please check if the module was installed correctly and contact the developer if you require assistance to resolve this issue.'
        ) -Stream $Connection.Stream;
        return;
    }

    [hashtable]$CommandArguments = @{
        '-Request'       = $Request;
        '-Connection'    = $Connection;
        '-ApiVersion'    = 'v1';
    };

    & $Command @CommandArguments | Out-Null;
}
