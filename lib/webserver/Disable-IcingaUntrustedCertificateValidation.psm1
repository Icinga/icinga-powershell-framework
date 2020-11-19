function Disable-IcingaUntrustedCertificateValidation()
{
    try {
        [System.Net.ServicePointManager]::CertificatePolicy = $null;

        Write-IcingaConsoleNotice 'Successfully disabled untrusted certificate validation for this shell instance';
    } catch {
        Write-IcingaConsoleError (
            [string]::Format(
                'Failed to disable untrusted certificate policy: {0}', $_.Exception.Message
            )
        );
    }
}
