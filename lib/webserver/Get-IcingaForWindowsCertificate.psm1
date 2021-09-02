function Get-IcingaForWindowsCertificate()
{
    [string]$CertificateFolder = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'certificate';
    [string]$CertificateFile   = Join-Path -Path $CertificateFolder -ChildPath 'icingaforwindows.pfx';

    if (-Not (Test-Path $CertificateFile)) {
        return $null;
    }

    return ([Security.Cryptography.X509Certificates.X509Certificate2]::CreateFromCertFile($CertificateFile));
}
