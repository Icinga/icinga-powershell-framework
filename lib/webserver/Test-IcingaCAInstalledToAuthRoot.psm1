function Test-IcingaCAInstalledToAuthRoot()
{
    $IcingaCAFile = Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\certs\ca.crt';

    if ((Test-Path $IcingaCAFile) -eq $FALSE) {
        return $FALSE;
    }

    $IcingaCACert = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $IcingaCAFile;

    [bool]$IcingaCAInstalled = $FALSE;

    Get-ChildItem -Recurse -Path 'Cert:\LocalMachine\AuthRoot\' | Where-Object {
        if ($_.Thumbprint -eq $IcingaCACert.Thumbprint) {
            $IcingaCAInstalled = $TRUE;
        }
    };

    $IcingaCACert = $null;

    return $IcingaCAInstalled;
}
