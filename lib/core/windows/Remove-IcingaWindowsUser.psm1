function Remove-IcingaWindowsUser()
{
    param (
        $IcingaUser = 'icinga'
    );

    $UserConfig = Get-IcingaWindowsUserConfig -UserName $IcingaUser;

    if ($UserConfig.UserExist -eq $FALSE -Or $UserConfig.IcingaManagedUser -eq $FALSE) {
        if ($UserConfig.UserExist -eq $FALSE) {
            Write-IcingaConsoleNotice 'The user "{0}" is not present on this system' -Objects $IcingaUser;
        } elseif ($UserConfig.IcingaManagedUser -eq $FALSE) {
            Write-IcingaConsoleNotice 'The user "{0}" was not created by Icinga for Windows. Unable to remove user' -Objects $IcingaUser;
        }

        return @{
            'User' = $IcingaUser;
            'SID'  = $SID;
        };
    }

    $Result = Start-IcingaProcess -Executable 'net' -Arguments ([string]::Format('user "{0}" /DELETE', $UserConfig.Name));

    if ($Result.ExitCode -ne 0) {
        Write-IcingaConsoleError 'Failed to delete user "{0}": {1}' -Objects $IcingaUser, $Result.Error;
    } else {
        # Delete Home Directory
        $HomePath = Join-Path -Path ($ENV:HOMEDRIVE) -ChildPath (Join-Path -Path '\Users\' -ChildPath $IcingaUser);
        Remove-ItemSecure -Path $HomePath -Recurse -Force | Out-Null;
    }

    return @{
        'User' = $UserConfig.Caption;
        'SID'  = $UserConfig.SID;
    };
}
