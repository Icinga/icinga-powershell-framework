function New-IcingaVersionObject()
{
    param (
        [array]$Version
    );

    if ($null -eq $Version -Or $Version.Count -gt 4) {
        return (New-Object System.Version);
    }

    return (New-Object System.Version $Version);
}
