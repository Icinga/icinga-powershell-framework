function Test-IcingaAcl()
{
    param(
        [string]$Directory,
        [switch]$WriteOutput
    );

    if (-Not (Test-Path $Directory)) {
        throw 'The specified directory was not found';
    }

    $FolderACL   = Get-Acl $Directory;
    $ServiceUser = Get-IcingaServiceUser;
    $UserFound   = $FALSE;
    $HasAccess   = $FALSE;
    foreach ($user in $FolderACL.Access) {
        # Not only check here for the exact name but also for included strings like NT AU or NT-AU or even further later on
        # As the Get-Acl Cmdlet will translate usernames into the own language, resultng in 'NT AUTHORITY\NetworkService' being translated
        # to 'NT-AUTORITÄT\Netzwerkdienst' for example
        if ($user.IdentityReference -like "*$ServiceUser" -Or ($ServiceUser -Like '*NT AU*' -And ($user.IdentityReference -Like '*NT AU*' -Or $user.IdentityReference -Like '*NT-AU*'))) {
            $UserFound = $TRUE;
            if ($user.FileSystemRights -Like '*Modify*' -And $user.FileSystemRights -Like '*Synchronize*') {
                $HasAccess = $TRUE;
            }
        }
    }

    if ($WriteOutput) {
        [string]$messageFormat = 'Directory "{0}" {1} by the Icinga Service User "{2}"';
        if ($UserFound) {
            if ($HasAccess) {
                Write-IcingaTestOutput -Severity 'PASSED' -Message ([string]::Format($messageFormat, $Directory, 'is accessible and writeable', $ServiceUser));
            } else {
                Write-IcingaTestOutput -Severity 'FAILED' -Message ([string]::Format($messageFormat, $Directory, 'is accessible but NOT writeable', $ServiceUser));
                Write-Host "\_ Please run the following command to fix this issue: Set-IcingaAcl -Directory '$Directory'";
            }
        } else {
            Write-IcingaTestOutput -Severity 'FAILED' -Message ([string]::Format($messageFormat, $Directory, 'is not accessible', $ServiceUser));
            Write-Host "\_ Please run the following command to fix this issue: Set-IcingaAcl -Directory '$Directory'";
        }
    }

    return $UserFound;
}
