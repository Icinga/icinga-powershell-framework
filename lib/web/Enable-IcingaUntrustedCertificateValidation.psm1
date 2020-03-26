function Enable-IcingaUntrustedCertificateValidation()
{
    try {
        # There is no other way as to use C# for this specific
        # case to configure the certificate validation check
        add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;

        public class IcingaUntrustedCertificateValidation : ICertificatePolicy {
            public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@

        [System.Net.ServicePointManager]::CertificatePolicy = New-Object IcingaUntrustedCertificateValidation;

        Write-Host 'Successfully enabled untrusted certificate validation for this shell instance';
    } catch {
        Write-Host (
            [string]::Format(
                'Failed to enable untrusted certificate policy: {0}', $_.Exception.Message
            )
        );
    }
}
