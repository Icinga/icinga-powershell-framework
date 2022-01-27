function Show-IcingaRegisteredServiceChecks()
{
    [array]$ServiceSummary  = @(
        'List of configured background service checks on this system.',
        '=> https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/',
        ''
    );

    [hashtable]$ServiceList = Get-IcingaRegisteredServiceChecks;

    foreach ($serviceId in $ServiceList.Keys) {
        $serviceDetails     = $ServiceList[$serviceId];

        $ServiceSummary    += $serviceDetails.CheckCommand;
        $ServiceSummary    += '-----------';

        [int]$MaxLength     = (Get-IcingaMaxTextLength -TextArray $serviceDetails.Keys) - 1;
        [array]$ServiceData = @();

        foreach ($serviceArguments in $serviceDetails.Keys) {
            $serviceValue = $serviceDetails[$serviceArguments];
            $PrintName    = Add-IcingaWhiteSpaceToString -Text $serviceArguments -Length $MaxLength;
            if ($serviceValue -Is [array]) {
                $serviceValue = [string]::Join(', ', $serviceValue);
            } elseif ($serviceValue -Is [PSCustomObject]) {
                $serviceValue = ConvertTo-IcingaCommandArgumentString -Command $serviceDetails.CheckCommand -CommandArguments $serviceValue;
            }
            $ServiceData  += [string]::Format('{0} => {1}', $PrintName, $serviceValue);
        }

        $ServiceSummary += $ServiceData | Sort-Object;
        $ServiceSummary += '';
    }

    if ($ServiceList.Count -eq 0) {
        $ServiceSummary += 'No background service checks configured';
        $ServiceSummary += '';
    }

    Write-Output $ServiceSummary;
}
