function Test-IcingaAgentFeatureEnabled()
{
    param(
        [string]$Feature
    );

    $Features = Get-IcingaAgentFeatures;

    if ($Features.Enabled -Contains $Feature) {
        return $TRUE;
    }

    return $FALSE;
}
