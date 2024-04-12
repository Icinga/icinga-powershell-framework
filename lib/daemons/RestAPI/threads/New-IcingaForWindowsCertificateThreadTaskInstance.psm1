function New-IcingaForWindowsCertificateThreadTaskInstance()
{
    $IcingaHostname = Get-IcingaHostname -ReadConstants;

    while ($TRUE) {
        # Check every 10 minutes if our certificate is present and update it in case it is
        # missing or updates have happened

        $NewIcingaForWindowsCertificate = Get-IcingaForWindowsCertificate;

        if ($null -ne $NewIcingaForWindowsCertificate) {
            if ($NewIcingaForWindowsCertificate.Issuer.ToLower() -eq ([string]::Format('cn={0}', $IcingaHostname).ToLower())) {
                Write-IcingaEventMessage -EventId 1506 -Namespace 'Framework';
            } else {
                if ($Global:Icinga.Public.SSL.Certificate.GetCertHashString() -ne $NewIcingaForWindowsCertificate.GetCertHashString()) {
                    $Global:Icinga.Public.SSL.Certificate = $NewIcingaForWindowsCertificate;
                    Write-IcingaEventMessage -EventId 2004 -Namespace 'RESTApi';
                }
            }
        }

        Start-Sleep -Seconds (60 * 10);
    }
}
