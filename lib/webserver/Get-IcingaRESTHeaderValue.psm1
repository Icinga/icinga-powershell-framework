function Get-IcingaRESTHeaderValue()
{
    param(
        [hashtable]$Request = @{ },
        [string]$Header     = $null
    );

    if ($null -eq $Request -or [string]::IsNullOrEmpty($Header) -Or $Request.Count -eq 0) {
        return $null;
    }

    if ($Request.Header.ContainsKey($Header) -eq $FALSE) {
        return $null
    }

    return $Request.Header[$Header];
}
