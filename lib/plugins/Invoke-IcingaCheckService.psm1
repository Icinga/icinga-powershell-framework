Import-IcingaLib provider\services;
Import-IcingaLib provider\enums;
Import-IcingaLib icinga\plugin;

function Invoke-IcingaCheckService()
{
    param(
        [array]$Service,
        [string]$Status,
        [int]$Verbose
    );

    $ServicesPackage  = New-IcingaCheckPackage -Name 'Services' -OperatorAnd -Verbose $Verbose;

    if ($Service.Count -ne 1) {
        foreach ($services in $Service) {
            $IcingaCheck = $null;

            $FoundService    = Get-IcingaServices -Service $services;
            $ServiceName     = Get-IcingaServiceCheckName -ServiceInput $services -Service $FoundService;
            $ConvertedStatus = ConvertTo-ServiceStatusCode -Status $Status;
            $StatusRaw       = $FoundService.Values.configuration.Status.raw;
        
            $IcingaCheck = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $FoundService -Translation $ProviderEnums.ServiceStatusName;
            $IcingaCheck.CritIfNotMatch($ConvertedStatus) | Out-Null;
            $ServicesPackage.AddCheck($IcingaCheck)
        }
    } else {

    $FoundService = Get-IcingaServices -Service $Service;
    $ServiceName  = Get-IcingaServiceCheckName -ServiceInput $Service -Service $FoundService;
    $Status       = ConvertTo-ServiceStatusCode -Status $Status;
    $StatusRaw    = $FoundService.Values.configuration.Status.raw;

    $IcingaCheck = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $FoundService -Translation $ProviderEnums.ServiceStatusName;
    $IcingaCheck.CritIfNotMatch($Status) | Out-Null;
    $ServicesPackage.AddCheck($IcingaCheck);

    }
    exit (New-IcingaCheckResult -Name 'Services' -Check $ServicesPackage -NoPerfData $TRUE -Compile);
}
