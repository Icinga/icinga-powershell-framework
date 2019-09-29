function Compare-IcingaVersions()
{
    param(
        $CurrentVersion,
        $RequiredVersion
    );

    if ([string]::IsNullOrEmpty($RequiredVersion)) {
        return $FALSE;
    }
    
    $RequiredVersion = Split-IcingaVersion -Version $RequiredVersion;
    
    if ([string]::IsNullOrEmpty($CurrentVersion) -eq $FALSE) {
        $CurrentVersion = Split-IcingaVersion -Version $CurrentVersion;
    } else {
        $CurrentVersion = Get-IcingaAgentVersion;
    }

    if ($requiredVersion.Mayor -gt $currentVersion.Mayor) {
        return $FALSE;
    }

    if ($requiredVersion.Minor -gt $currentVersion.Minor) {
        return $FALSE;
    }

    if ($requiredVersion.Minor -ge $currentVersion.Minor -And $requiredVersion.Fixes -gt $currentVersion.Fixes) {
        return $FALSE;
    }

    return $TRUE;
}
