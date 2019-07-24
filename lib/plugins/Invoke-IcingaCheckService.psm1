Import-IcingaLib provider\services;
Import-IcingaLib icinga\plugin;

function Invoke-IcingaCheckService()
{
    param(
        [string]$Status,
        [string]$Service,
        [switch]$NoPerfData,
        $Verbose
    );

    $FoundService = Get-IcingaServices -Service $Service;
    $ServiceName  = $FoundService.Values.metadata.ServiceName;
    $DisplayName  = $FoundService.Values.metadata.DisplayName;
   # $Status       = Get-IcingaServicesStatusTranslation -Status $Status;
    $StatusRaw    = $FoundService.Values.configuration.Status.raw;

    $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Service "{0} ({1})"', $DisplayName, $ServiceName)) -Value $StatusRaw -ObjectExists $FoundService -ValueTranslation $ProviderEnums.ServiceStatus;
    $IcingaCheck.CritIfNotMatch($Status) | Out-Null;

    exit (New-IcingaCheckResult -Name "Service $Service" -Check $IcingaCheck -NoPerfData $TRUE -Compile);
}
