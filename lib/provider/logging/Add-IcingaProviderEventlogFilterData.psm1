function Add-IcingaProviderEventlogFilterData()
{
    param(
        [string]$EventFilter = '',
        $StringBuilderObject = $null
    );

    if ($null -eq $StringBuilderObject -Or $StringBuilderObject.Length -eq 0) {
        return $EventFilter;
    }

    [string]$NewStringEntry = $StringBuilderObject.ToString();

    $StringBuilderObject.Clear();
    $StringBuilderObject = $null;

    if ([string]::IsNullOrEmpty($NewStringEntry)) {
        return $EventFilter;
    }

    if ([string]::IsNullOrEmpty($EventFilter)) {
        return $NewStringEntry;
    }

    [string]$EventFilter = [string]::Format('{0} and {1}', $EventFilter, $NewStringEntry);

    return $EventFilter;
}
