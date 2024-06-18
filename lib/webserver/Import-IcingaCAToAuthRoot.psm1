function Import-IcingaCAToAuthRoot()
{
    $IcingaCAFile = Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\certs\ca.crt';

    if ((Test-Path $IcingaCAFile) -eq $FALSE) {
        return $FALSE;
    }

    if (Test-IcingaCAInstalledToAuthRoot) {
        return $TRUE;
    }

    Import-Certificate -FilePath $IcingaCAFile -CertStoreLocation 'Cert:\LocalMachine\AuthRoot\' | Out-Null;

    return (
        Test-IcingaCAInstalledToAuthRoot
    );
}
