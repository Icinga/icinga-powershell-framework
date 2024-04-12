function Get-IcingaForWindowsCertificate()
{
    [string]$CertThumbprint                                               = $null;
    [PSCustomObject]$CertFilter                                           = $null;
    [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null;

    if ($Global:Icinga.Public.ContainsKey('SSL')) {
        $CertThumbprint = $Global:Icinga.Public.SSL.CertThumbprint;
        $CertFilter     = $Global:Icinga.Public.SSL.CertFilter;
    }

    if ([string]::IsNullOrEmpty($CertThumbprint) -eq $FALSE -Or $null -ne $CertFilter) {
        [hashtable]$FilterArgs = @{
            '-Recurse' = $TRUE;
            '-Path'    = 'cert:\LocalMachine\*';
        }

        if ([string]::IsNullOrEmpty($CertThumbprint) -eq $FALSE) {
            $FilterArgs.Add('-Include', $CertThumbprint);
        }

        [array]$Certificates   = Get-ChildItem @FilterArgs;
        [DateTime]$CurrentTime = [DateTime]::Now;

        foreach ($cert in $Certificates) {
            if ((Test-PSCustomObjectMember -PSObject $CertFilter -Name 'Subject') -And [string]::IsNullOrEmpty($CertFilter.Subject) -eq $FALSE) {
                if ($cert.Subject.ToLower() -NotLike $CertFilter.Subject.ToLower()) {
                    continue;
                }
            }

            if ((Test-PSCustomObjectMember -PSObject $CertFilter -Name 'Issuer') -And [string]::IsNullOrEmpty($CertFilter.Issuer) -eq $FALSE) {
                if ($cert.Issuer.ToLower() -NotLike $CertFilter.Issuer.ToLower()) {
                    continue;
                }
            }

            # Certificate expiration date
            if ($cert.NotAfter -lt $CurrentTime) {
                continue;
            }

            # Certificate start date
            if ($cert.NotBefore -gt $CurrentTime) {
                continue;
            }

            $Certificate = $cert;
            break;
        }
    } else {
        [string]$CertificateFolder = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'certificate';
        [string]$CertificateFile   = Join-Path -Path $CertificateFolder -ChildPath 'icingaforwindows.pfx';

        if (-Not (Test-Path $CertificateFile)) {
            return $null;
        }

        $Certificate = (
            New-Object Security.Cryptography.X509Certificates.X509Certificate2 $CertificateFile, '', ([System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet)
        );
    }

    return $Certificate;
}
