function Disable-IcingaUntrustedCertificateValidation()
{
    param (
        [switch]$SuppressMessages = $FALSE
    );

    try {
        [System.Net.ServicePointManager]::CertificatePolicy = $null;

        if ($SuppressMessages -eq $FALSE) {
            Write-IcingaConsoleNotice 'Successfully disabled untrusted certificate validation for this shell instance';
        }
    } catch {
        if ($SuppressMessages -eq $FALSE) {
            Write-IcingaConsoleError (
                [string]::Format(
                    'Failed to disable untrusted certificate policy: {0}', $_.Exception.Message
                )
            );
        }
    }
}
