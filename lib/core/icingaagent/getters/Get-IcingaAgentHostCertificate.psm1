function Get-IcingaAgentHostCertificate()
{
    # Default for Icinga 2.8.0 and above
    [string]$CertDirectory = (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\certs\*');
    $FolderContent         = Get-ChildItem -Path $CertDirectory -Filter '*.crt' -Exclude 'ca.crt';
    $Hostname              = Get-IcingaHostname -LowerCase $TRUE;
    $CertPath              = $null;

    foreach ($certFile in $FolderContent) {
        if ($certFile.Name.Contains($Hostname)) {
            $CertPath = $certFile.FullName;
            break;
        }
    }

    if ([string]::IsNullOrEmpty($CertPath)) {
        return $null;
    }

    $Certificate = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $CertPath;

    return @{
        'CertFile'   = $CertPath;
        'Subject'    = $Certificate.Subject;
        'Thumbprint' = $Certificate.Thumbprint;
    };
}
