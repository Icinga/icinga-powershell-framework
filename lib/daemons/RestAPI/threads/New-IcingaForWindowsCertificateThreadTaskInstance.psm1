function New-IcingaForWindowsCertificateThreadTaskInstance()
{
    $IcingaHostname = Get-IcingaHostname -ReadConstants;

    while ($TRUE) {
        # Check every 10 minutes if our certificate is present and update it in case it is
        # missing or updates have happened

        # In case we are not inside a JEA context, use the SSLCertForSocket function to create the certificate file on the fly
        # while maintaining the new wait feature. This fix is required, as the NetworkService user has no permssion
        # to read the icingaforwindows.pfx file with the private key
        if ([string]::IsNullOrEmpty((Get-IcingaJEAContext))) {
            $NewIcingaForWindowsCertificate = Get-IcingaSSLCertForSocket `
                -CertFile $Global:Icinga.Public.SSL.CertFile `
                -CertThumbprint $Global:Icinga.Public.SSL.CertThumbprint;
        } else {
            $NewIcingaForWindowsCertificate = Get-IcingaForWindowsCertificate;
        }

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
