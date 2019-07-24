Import-IcingaLib core\tools;
Import-IcingaLib provider\enums;

function ConvertTo-ServiceStatusCode()
{
    param (
        $Status
    )

    if (Test-Numeric $Status) {
        return [int]$Status
    }

    return [int]($ProviderEnums.ServiceStatus.$Status);
}
