function Test-IcingaForWindowsCertificate()
{
    $IfWCertificate = Get-IcingaForWindowsCertificate;
    $Hostname       = Get-IcingaHostname -ReadConstants;

    if ([string]::IsNullOrEmpty($Hostname)) {
        Write-IcingaEventMessage -EventId 1700 -Namespace 'Framework';
        return $FALSE;
    }

    if ($null -eq $IfWCertificate) {
        return $FALSE;
    }

    if ($IfWCertificate.Issuer.ToLower() -eq ([string]::Format('cn={0}', $Hostname).ToLower())) {
        return $FALSE;
    }

    return $TRUE;
}
