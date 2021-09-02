function Install-IcingaForWindowsCertificate()
{
    param (
        [string]$CertFile       = '',
        [string]$CertThumbprint = ''
    );

    [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null;
    [string]$CertificateFolder                                            = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'certificate';
    [string]$CertificateFile                                              = Join-Path -Path $CertificateFolder -ChildPath 'icingaforwindows.pfx';
    [bool]$FoundCertificate                                               = $FALSE;

    if (-Not (Test-Path $CertificateFolder)) {
        New-Item -ItemType Directory -Path $CertificateFolder -Force | Out-Null;
    }

    if (-Not (Test-IcingaAcl -Directory $CertificateFolder)) {
        Set-IcingaAcl -Directory $CertificateFolder;
    }

    if (Test-Path $CertificateFile) {
        Remove-ItemSecure -Path $CertificateFile -Force | Out-Null;
    }

    if ([string]::IsNullOrEmpty($CertFile) -eq $FALSE) {
        if ([IO.Path]::GetExtension($CertFile) -ne '.pfx') {
            ConvertTo-IcingaX509Certificate -CertFile $CertFile -OutFile $CertificateFile -Force | Out-Null;
        } else {
            Copy-ItemSecure -Path $CertFile -Destination $CertificateFile -Force | Out-Null;
        }
    }

    if ([string]::IsNullOrEmpty($CertThumbprint) -eq $FALSE) {
        $Certificate = Get-ChildItem -Path 'cert:\*' -Include $CertThumbprint -Recurse

        if ($null -ne $Certificate) {
            Export-Certificate -Cert $Certificate -FilePath $CertificateFile | Out-Null;
        }
    }

    if ([string]::IsNullOrEmpty($CertFile) -And [string]::IsNullOrEmpty($CertThumbprint)) {
        $IcingaHostCertificate = Get-IcingaAgentHostCertificate;

        if ([string]::IsNullOrEmpty($IcingaHostCertificate.CertFile) -eq $FALSE) {
            $LocalCert = ConvertTo-IcingaX509Certificate -CertFile $IcingaHostCertificate.CertFile -OutFile $CertificateFile -Force;

            Import-PfxCertificate -FilePath $CertificateFile -CertStoreLocation 'Cert:\LocalMachine\My\' -Exportable | Out-Null;
            Remove-ItemSecure -Path $CertificateFile -Force | Out-Null;
            $Certificate = Get-ChildItem -Path 'cert:\*' -Include $LocalCert.Thumbprint -Recurse
            Export-Certificate -Cert $Certificate -FilePath $CertificateFile | Out-Null;
        }
    }

    if (Test-Path $CertificateFile) {
        Write-IcingaConsoleNotice -Message 'Successfully installed Icinga for Windows certificate at "{0}"' -Objects $CertificateFile;
    } else {
        Write-IcingaConsoleError -Message 'Unable to install Icinga for Windows certificate, as with specified arguments and auto-lookup for Icinga Agent certificate, no certificate could be created' -Objects $CertificateFile;
    }
}
