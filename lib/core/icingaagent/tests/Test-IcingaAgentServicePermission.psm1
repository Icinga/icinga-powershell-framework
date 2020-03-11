function Test-IcingaAgentServicePermission()
{
    param(
        [switch]$Silent = $FALSE
    );

    $ServiceUser       = Get-IcingaServiceUser;
    $ServiceUserSID    = Get-IcingaUserSID $ServiceUser;
    $SystemContent     = Get-IcingaAgentServicePermission;
    [bool]$FoundSID    = $FALSE;

    if ($ServiceUser -eq 'NT Authority\SYSTEM') {
        return $TRUE;
    }

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        if (-Not $Silent) {
            Write-IcingaTestOutput -Severity 'FAILED' -Message 'There is no user assigned to the Icinga 2 service or the service is not yet installed';
        }
        return $FALSE;
    }

    foreach ($line in $SystemContent) {
        if ($line -like '*SeServiceLogonRight*') {
            $Index           = $line.IndexOf('= ') + 2;
            [string]$SIDs    = $line.Substring($Index, $line.Length - $Index);
            [array]$SIDArray = $SIDs.Split(',');

            foreach ($sid in $SIDArray) {
                if ($sid -like "*$ServiceUserSID" -Or $sid -eq $ServiceUser) {
                    $FoundSID = $TRUE;
                    break;
                }
            }
        }
        if ($FoundSID) {
            break;
        }
    }

    if (-Not $Silent) {
        if ($FoundSID) {
            Write-IcingaTestOutput -Severity 'PASSED' -Message ([string]::Format('The specified user "{0}" is allowed to run as service.', $ServiceUser));
        } else {
            Write-IcingaTestOutput -Severity 'FAILED' -Message ([string]::Format('The specified user "{0}" is not allowed to run as service.', $ServiceUser));
        }
    }

    return $FoundSID;
}
