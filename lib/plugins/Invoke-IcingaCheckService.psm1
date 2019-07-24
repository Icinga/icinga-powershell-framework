Import-IcingaLib provider\services;
Import-IcingaLib provider\enums;
Import-IcingaLib icinga\plugin;

function Invoke-IcingaCheckService()
{
    param(
        [string]$Status,
        [string]$Service
    );

    $FoundService = Get-IcingaServices -Service $Service;
    $ServiceName  = Get-IcingaServiceCheckName -ServiceInput $Service -Service $FoundService;
    $Status       = ConvertTo-ServiceStatusCode -Status $Status;
    $StatusRaw    = $FoundService.Values.configuration.Status.raw;

    $IcingaCheck = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $FoundService -Translation $ProviderEnums.ServiceStatusName;
    $IcingaCheck.CritIfNotMatch($Status) | Out-Null;

    exit (New-IcingaCheckResult -Check $IcingaCheck -NoPerfData $TRUE -Compile);
}
