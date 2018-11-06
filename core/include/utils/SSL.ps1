
$SSL = New-Object -TypeName PSObject;
$SSL | Add-Member -membertype ScriptMethod -name 'LoadServerCertificate' -value {

    if ((Get-Icinga-Setup) -eq $FALSE) {
        $Icinga2.Log.WriteConsole(
            $Icinga2.Enums.LogState.Warning,
            'The module has not been configured yet. Skipping certificate loading'
        );
        return;
    }

    try {
        $CertStore = New-Object System.Security.Cryptography.X509Certificates.X509Store(
            $Icinga2.Config.'certstore.name',
            $Icinga2.Config.'certstore.location'
        );
        $CertStore.Open("ReadOnly");

        $ServerCertificate = $null;

        [string]$CertName       = $Icinga2.Config.'certstore.certificate.name';
        [string]$CertThumbprint = $Icinga2.Config.'certstore.certificate.thumbprint';

        # Try to discover the certificate based on our FQDN
        if ([string]::IsNullOrEmpty($CertName) -eq $TRUE -And [string]::IsNullOrEmpty($CertThumbprint) -eq $TRUE) {
            $CertName = [string]::Format(
                '{0}.{1}',
                (Get-WmiObject Win32_ComputerSystem).DNSHostName,
                (Get-WmiObject win32_computersystem).Domain
            );

            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Info,
                [string]::Format(
                    'Trying to discover certificate for this host with FQDN "{0}"',
                    $CertName
                )
            );
        }

        foreach ($cert in $CertStore.Certificates) {
            if ([string]::IsNullOrEmpty($CertThumbprint) -eq $FALSE) {
                if ($CertThumbprint.ToLower() -eq $cert.Thumbprint.ToLower()) {
                    $ServerCertificate = $cert;
                    break;
                }
            }

            if ([string]::IsNullOrEmpty($CertName) -eq $FALSE) {
                [string]$CNCertName = [string]::Format('CN={0}', $CertName.ToLower());
                if ($CNCertName.ToLower() -eq $cert.Subject.ToLower()) {
                    $ServerCertificate = $cert;

                    try {
                        $result = Test-Certificate -Cert $cert -ErrorAction SilentlyContinue -WarningAction SilentlyContinue;
                        if ($result -eq $FALSE) {
                            continue;
                        }
                    } catch {
                        continue;
                    }

                    break;
                }
            }
        }

        $certificate = $null;

        if ($ServerCertificate -ne $null) {
            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Debug,
                [string]::Format(
                    'Using certificate "{0}" with thumbprint "{1}"',
                    $ServerCertificate.Subject,
                    $ServerCertificate.Thumbprint
                )
            );
            $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2;
            $certificate.Import($ServerCertificate.RawData)
        }

        $CertStore.Close();

        return $certificate;
    } catch [System.ComponentModel.Win32Exception] {
        # This error occures in case we provide a cert store and location which is not accessable
        # from our current user. We have to simply drop everything and close every possible
        # connection
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            'SSL-Error: Unable to access provided certificate from the user space this module is started with.'
        );
    } catch [System.NotSupportedException] {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            'The used SSL certificate is not providing a linked private key and cannot be used as Server certificate'
        );
    } catch {
        # Handle every other error here
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            $_.Exception.Message
        );
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            $_.Exception
        );
    }

    return $null;
}

return $SSL;