param($Config = $null);

function ClassCertificates()
{
    param($Config = $null);

    [hashtable]$CertStore    = @{};
    [hashtable]$CertLocation = @{};
    [hashtable]$CertCounters = @{};

    Set-Location 'cert:' | Out-Null;
    $certs = Get-ChildItem -Recurse;

    foreach ($cert in $certs) {
        if ($cert.LocationName) {
            if ($CertStore.ContainsKey($cert.LocationName) -eq $FALSE) {
                $CertStore.Add($cert.LocationName, @{});
            }
        }

        if ($cert.IssuerName) {
            [hashtable]$Certificate = @{};
            $Certificate.Add('Archived', $cert.Archived);
            $Certificate.Add('HasPrivateKey', $cert.HasPrivateKey);
            $Certificate.Add('IssuerName.Name', $cert.IssuerName.Name);
            $Certificate.Add('IssuerName.Oid', $cert.IssuerName.Oid);
            $Certificate.Add('NotAfter', $cert.NotAfter);
            $Certificate.Add('NotBefore', $cert.NotBefore);
            $Certificate.Add('SerialNumber', $cert.SerialNumber);
            $Certificate.Add('SubjectName.Name', $cert.SubjectName.Name);
            $Certificate.Add('SubjectOid.Oid', $cert.SubjectName.Oid);
            $Certificate.Add('SignatureAlgorithm.Value', $cert.SignatureAlgorithm.Value);
            $Certificate.Add('SignatureAlgorithm.FriendlyName', $cert.SignatureAlgorithm.FriendlyName);
            $Certificate.Add('Thumbprint', $cert.Thumbprint);
            $Certificate.Add('Version', $cert.Version);
            $Certificate.Add('Issuer', $cert.Issuer);
            $Certificate.Add('Subject', $cert.Subject);
            $Certificate.Add('PSParentPath', $cert.PSParentPath);
            $Certificate.Add('PSChildName', $cert.PSChildName);
            $Certificate.Add('DnsNameList', $cert.DnsNameList);

            [string]$cert_store    = (GetCertStore -CertPath $cert.PSPath);
            [string]$cert_location = (GetCertLocation -CertPath $cert.PSPath);

            $Certificate.Add('CertStore', $cert_store);
            $Certificate.Add('CertLocation', $cert_location);

            if ($CertLocation.ContainsKey($cert_location)) {
                $CertLocation[$cert_location] += $Certificate;
            } else {
                $CertLocation.Add($cert_location, @( $Certificate ));
            }
        }
    }

    foreach ($cert_arr in $CertLocation.Keys) {
        foreach ($cert in $CertLocation[$cert_arr]) {
            [string]$CertFullPathCache = [string]::Format(
                '{0}\{1}\{2}',
                $cert.CertStore,
                $cert.CertLocation,
                $cert.Thumbprint
            );
            if ($CertCounters.ContainsKey($CertFullPathCache) -eq $FALSE) {
                $CertCounters.Add($CertFullPathCache, 1);
            } else {
                $CertCounters[$CertFullPathCache] += 1;
            }
            if ($CertStore[$cert.CertStore].ContainsKey($cert.CertLocation)) {
                [string]$CertThumbprintKey = $cert.Thumbprint;
                if ($CertCounters[$CertFullPathCache] -gt 1) {
                    $CertThumbprintKey = [string]::Format(
                        '{0} ({1})',
                        $CertThumbprintKey,
                        $CertCounters[$CertFullPathCache]
                    );
                }
                $CertStore[$cert.CertStore][$cert.CertLocation].Add($CertThumbprintKey, $cert);
            } else {
                $CertStore[$cert.CertStore].Add($cert.CertLocation, @{ $cert.Thumbprint = $cert });
            }
        }
    }

    return $CertStore
}

function GetCertStore()
{
    param([string]$CertPath);

    $CertPath = $CertPath.Replace('Microsoft.PowerShell.Security\', '');
    $CertPath = $CertPath.Replace('Certificate::', '');

    [array]$path = $CertPath.Split('\');

    return $path[0];
}

function GetCertLocation()
{
    param([string]$CertPath);

    $CertPath = $CertPath.Replace('Microsoft.PowerShell.Security\', '');
    $CertPath = $CertPath.Replace('Certificate::', '');

    [array]$path = $CertPath.Split('\');

    return $path[1];
}

return ClassCertificates -Config $Config;