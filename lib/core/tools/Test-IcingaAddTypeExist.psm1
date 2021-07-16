function Test-IcingaAddTypeExist()
{
    param (
        [string]$Type = $null
    );

    if ([string]::IsNullOrEmpty($Type)) {
        return $FALSE;
    }

    foreach ($entry in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
        if ($entry.GetTypes() -Match $Type) {
            return $TRUE;
        }
    }

    return $FALSE;
}
