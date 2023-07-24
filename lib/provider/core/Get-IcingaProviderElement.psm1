function Get-IcingaProviderElement()
{
    param (
        $Object = $null
    );

    if ($null -eq $Object) {
        return @();
    }

    try {
        return $Object.PSObject.Properties
    } catch {
        return @();
    }

    return @();
}
