function Test-IcingaCAInstalledToAuthRoot()
{
    $IcingaCAFile = Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\certs\ca.crt';

    if ((Test-Path $IcingaCAFile) -eq $FALSE) {
        return $FALSE;
    }

    $IcingaCACert = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $IcingaCAFile;

    # If the issuer of our CA is not the "Icinga CA", always return true as this is a custom CA then.
    # Generally speaking, custom CA's are handled properly anyway so this is the correct behavior.
    if ($IcingaCACert.Issuer -ne 'CN=Icinga CA') {
        $IcingaCACert = $null;

        return $TRUE;
    }

    [bool]$IcingaCAInstalled = $FALSE;

    Get-ChildItem -Recurse -Path 'Cert:\LocalMachine\AuthRoot\' | Where-Object {
        if ($_.Thumbprint -eq $IcingaCACert.Thumbprint) {
            $IcingaCAInstalled = $TRUE;
        }
    };

    $IcingaCACert = $null;

    return $IcingaCAInstalled;
}
