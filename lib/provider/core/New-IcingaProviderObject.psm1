function New-IcingaProviderObject()
{
    param (
        [string]$Name = 'Undefined'
    );

    $ProviderObject = New-Object PSCustomObject;
    $ProviderObject                 | Add-Member -MemberType NoteProperty -Name 'Name'             -Value $Name;
    $ProviderObject                 | Add-Member -MemberType NoteProperty -Name 'FeatureInstalled' -Value $TRUE;
    $ProviderObject                 | Add-Member -MemberType NoteProperty -Name 'Metadata'         -Value (New-Object PSCustomObject);
    $ProviderObject                 | Add-Member -MemberType NoteProperty -Name 'Metrics'          -Value (New-Object PSCustomObject);
    $ProviderObject                 | Add-Member -MemberType NoteProperty -Name 'MetricsOverTime'  -Value (New-Object PSCustomObject);
    $ProviderObject.MetricsOverTime | Add-Member -MemberType NoteProperty -Name 'MetricContainer'  -Value (New-Object PSCustomObject);
    $ProviderObject.MetricsOverTime | Add-Member -MemberType NoteProperty -Name 'Cache'            -Value (New-Object PSCustomObject);
    $ProviderObject.MetricsOverTime | Add-Member -MemberType NoteProperty -Name 'Compiled'         -Value (New-Object PSCustomObject);

    return $ProviderObject;
}
