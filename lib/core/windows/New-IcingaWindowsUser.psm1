function New-IcingaWindowsUser()
{
    param (
        $IcingaUser = 'icinga'
    );

    if ((Test-AdministrativeShell) -eq $FALSE) {
        Write-IcingaConsoleError 'For this command you require to run an Admin shell';

        return @{
            'User' = $null;
            'SID'  = $null;
        };
    }

    $IcingaUserInfo = Split-IcingaUserDomain -User $IcingaUser;

    # Max length for the user name
    if ($IcingaUserInfo.User.Length -gt 20) {
        Write-IcingaConsoleError 'The specified user name "{0}" is too long. The maximum character limit is 20 digits.' -Objects $IcingaUserInfo.User;

        return @{
            'User' = $null;
            'SID'  = $null;
        };
    }

    $UserMetadata = Get-IcingaWindowsUserMetadata;
    $UserConfig   = Get-IcingaWindowsUserConfig -UserName $IcingaUser;

    # In case the user exist, we can check if it is a managed user for modifying the login password
    if ($UserConfig.UserExist) {

        # User already exist -> override password - but only if the user is entirely managed by Icinga
        if ($UserConfig.IcingaManagedUser) {
            # In case the password set fails, we need to try again
            [int]$Attempts = 0;
            [bool]$Success = $FALSE;

            while ($Attempts -lt 10) {
                $Result = Start-IcingaProcess -Executable 'net' -Arguments ([string]::Format('user "{0}" "{1}"', $IcingaUserInfo.User, (ConvertFrom-IcingaSecureString -SecureString (New-IcingaWindowsUserPassword))));

                if ($Result.ExitCode -eq 0) {
                    $Success = $TRUE;
                    break;
                }

                $Attempts += 1;
            }

            if ($Success -eq $FALSE) {
                Write-IcingaConsoleError 'Failed to update password for user "{0}": {1}' -Objects $IcingaUserInfo.User, $Result.Error;

                return @{
                    'User' = $UserConfig.Caption;
                    'SID'  = $UserConfig.SID;
                };
            }
            Write-IcingaConsoleNotice 'User updated successfully.';
        } else {
            Write-IcingaConsoleWarning 'User "{0}" is not managed by Icinga for Windows. No changes were made.' -Objects $IcingaUserInfo.User;
        }

        return @{
            'User' = $UserConfig.Caption;
            'SID'  = $UserConfig.SID;
        };
    }

    # Access our local Account Database
    $AccountDB        = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer";
    $IcingaUserObject = $AccountDB.Create("User", $IcingaUserInfo.User);
    $IcingaUserObject.SetPassword((ConvertFrom-IcingaSecureString -SecureString (New-IcingaWindowsUserPassword)));
    $IcingaUserObject.SetInfo();
    $IcingaUserObject.FullName    = $UserMetadata.FullName;
    $IcingaUserObject.SetInfo();
    $IcingaUserObject.Description = $UserMetadata.Description;
    $IcingaUserObject.SetInfo();
    $IcingaUserObject.UserFlags   = 65600;
    $IcingaUserObject.SetInfo();

    # Add to local user group
    <# This is not required, but let's leave it here for possible later lookup on how this works
    $SIDLocalGroup = New-Object System.Security.Principal.SecurityIdentifier ("S-1-5-32-545");
    $LocalGroup    = ($SIDLocalGroup.Translate([System.Security.Principal.NTAccount])).Value.Split('\')[1];

    $LocalUserGroup = [ADSI]"WinNT://$Env:COMPUTERNAME/$LocalGroup,group";
    $LocalUserGroup.Add("WinNT://$Env:COMPUTERNAME/$IcingaUser,user")
    #>

    $UserConfig = Get-IcingaWindowsUserConfig -UserName $IcingaUser;

    Write-IcingaConsoleNotice 'User was successfully created.';

    return @{
        'User' = $UserConfig.Caption;
        'SID'  = $UserConfig.SID;
    };
}
