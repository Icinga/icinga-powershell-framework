function Disable-IcingaUntrustedCertificateValidation()
{
    try {
        [System.Net.ServicePointManager]::CertificatePolicy = $null;

        Write-Host 'Successfully disabled untrusted certificate validation for this shell instance';
    } catch {
        Write-Host (
            [string]::Format(
                'Failed to disable untrusted certificate policy: {0}', $_.Exception.Message
            )
        );
    }
}
