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
        Write-IcingaTestOutput -Severity 'Passed' -Message ([string]::Format('The specified user "{0}" is allowed to run as service', $ServiceUser));
        return $TRUE;
    }

    # Never update system SIDs
    if ($ServiceUserSID.Length -le 16) {
        Write-IcingaTestOutput -Severity 'Passed' -Message ([string]::Format('It seems the provided SID "{0}" is a system SID. Skipping permission check', $ServiceUserSID));
        return $TRUE;
    }

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        if (-Not $Silent) {
            Write-IcingaTestOutput -Severity 'Failed' -Message 'There is no user assigned to the Icinga 2 service or the service is not yet installed';
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
            Write-IcingaTestOutput -Severity 'Passed' -Message ([string]::Format('The specified user "{0}" is allowed to run as service', $ServiceUser));
        } else {
            Write-IcingaTestOutput -Severity 'Failed' -Message ([string]::Format('The specified user "{0}" is not allowed to run as service', $ServiceUser));
        }
    }

    return $FoundSID;
}
