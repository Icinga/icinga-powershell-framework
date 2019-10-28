function Test-IcingaFunction()
{
    param(
        [string]$Name
    );

    if ([string]::IsNullOrEmpty($Name)) {
        return $FALSE;
    }

    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        return $TRUE;
    }

    return $FALSE;
}
