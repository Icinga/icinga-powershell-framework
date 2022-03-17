function Get-IcingaSSLCertForSocket()
{
    param(
        [string]$CertFile       = $null,
        [string]$CertThumbprint = $null
    );

    # At first check if we assigned a cert file to use directly and check
    # if it is there and either import a PFX or use our convert function
    # to get a proper certificate
    if ([string]::IsNullOrEmpty($CertFile) -eq $FALSE) {
        if ((Test-Path $CertFile)) {
            if ([IO.Path]::GetExtension($CertFile) -eq '.pfx') {
                return (New-Object Security.Cryptography.X509Certificates.X509Certificate2 $CertFile);
            } else {
                return ConvertTo-IcingaX509Certificate -CertFile $CertFile;
            }
        }
    }

    # We could also have assigned a Thumbprint to use from the
    # Windows cert store. Try to look it up an return it if
    # it is found
    if ([string]::IsNullOrEmpty($CertThumbprint) -eq $FALSE) {
        $Certificates = Get-ChildItem `
            -Path 'cert:\*' `
            -Recurse `
            -Include $CertThumbprint `
            -ErrorAction SilentlyContinue `
            -WarningAction SilentlyContinue;

        if ($Certificates.Count -ne 0) {
            return $Certificates[0];
        }
    }

    # If no cert file or thumbprint was specified or simply as fallback,
    # we should use the Icinga 2 Agent certificates
    $AgentCertificate = Get-IcingaAgentHostCertificate;

    # If Agent is not installed or certificates were not found,
    # simply return null
    if ($null -eq $AgentCertificate) {
        return $null;
    }

    return (ConvertTo-IcingaX509Certificate -CertFile $AgentCertificate.CertFile);
}
