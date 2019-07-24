function ConvertTo-ServiceStatusCode()
{
    param (
        $Status
    )

    if ($Status -match "^\d+$") {
        return $Status
    } else {
        $Status = $ProviderEnums.ServiceStatus.($Status); 
    }

    return $Status;
}