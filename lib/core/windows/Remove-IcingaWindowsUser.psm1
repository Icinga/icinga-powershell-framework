function Remove-IcingaWindowsUser()
{
    param (
        $IcingaUser = 'icinga'
    );

    $UserConfig = Get-IcingaWindowsInformation -Class 'Win32_UserAccount' | Where-Object { $_.Name -eq $IcingaUser };

    if ((Test-IcingaManagedUser -IcingaUser $IcingaUser) -eq $FALSE) {
        Write-IcingaConsoleNotice 'The user "{0}" is not present or not created by Icinga for Windows. Unable to remove user' -Objects $IcingaUser;
        return;
    }

    $Result = Start-IcingaProcess -Executable 'net' -Arguments ([string]::Format('user "{0}" /DELETE', $IcingaUser));

    if ($Result.ExitCode -ne 0) {
        Write-IcingaConsoleError 'Failed to delete user "{0}": {1}' -Objects $IcingaUser, $Result.Error;
    } else {
        # Delete Home Directory
        $HomePath = Join-Path -Path ($ENV:HOMEDRIVE) -ChildPath (Join-Path -Path '\Users\' -ChildPath $IcingaUser);
        Remove-ItemSecure -Path $HomePath -Recurse -Force;
    }

    return @{
        'User' = $UserConfig.Caption;
        'SID'  = $UserConfig.SID;
    };
}
