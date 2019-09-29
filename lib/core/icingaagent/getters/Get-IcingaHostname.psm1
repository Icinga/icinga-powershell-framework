function Get-IcingaHostname()
{
    param(
        [string]$Hostname,
        [bool]$AutoUseFQDN     = $FALSE,
        [bool]$AutoUseHostname = $FALSE,
        [bool]$UpperCase       = $FALSE,
        [bool]$LowerCase       = $FALSE
    );

    [string]$UseHostname = '';
    if ([string]::IsNullOrEmpty($Hostname) -eq $FALSE) {
        $UseHostname = $Hostname;
    } elseif ($AutoUseFQDN) {
        $UseHostname = [System.Net.Dns]::GetHostEntry("localhost").HostName;
    } else {
        $UseHostname = [System.Net.Dns]::GetHostName();
    }

    if ($UpperCase) {
        $UseHostname = $UseHostname.ToUpper();
    } elseif ($LowerCase) {
        $UseHostname = $UseHostname.ToLower();
    }

    return $UseHostname;
}
