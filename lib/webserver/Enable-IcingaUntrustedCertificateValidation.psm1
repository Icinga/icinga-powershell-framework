function Enable-IcingaUntrustedCertificateValidation()
{
    param (
        [switch]$SuppressMessages = $FALSE
    );

    try {
        # There is no other way as to use C# for this specific
        # case to configure the certificate validation check
        Add-Type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;

        public class IcingaUntrustedCertificateValidation : ICertificatePolicy {
            public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@

        [System.Net.ServicePointManager]::CertificatePolicy = New-Object IcingaUntrustedCertificateValidation;

        if ($SuppressMessages -eq $FALSE) {
            Write-IcingaConsoleNotice 'Successfully enabled untrusted certificate validation for this shell instance';
        }
    } catch {
        if ($SuppressMessages -eq $FALSE) {
            Write-IcingaConsoleError -Message 'Failed to enable untrusted certificate policy: {0}' -Objects $_.Exception.Message;
        }
    }
}
