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

    $UserMetadata = Get-IcingaWindowsUserMetadata;
    $UserConfig   = Get-IcingaWindowsInformation -Class 'Win32_UserAccount' | Where-Object { $_.Name -eq $IcingaUser };

    if ($null -ne $UserConfig) {

        # User already exist -> override password - but only if the user is entirely managed by Icinga
        if ($UserConfig.FullName -eq $UserMetadata.FullName -And $UserConfig.Description -eq $UserMetadata.Description) {
            $Result = Start-IcingaProcess -Executable 'net' -Arguments ([string]::Format('user "{0}" "{1}"', $IcingaUser, (ConvertFrom-IcingaSecureString -SecureString (New-IcingaWindowsUserPassword))));

            if ($Result.ExitCode -ne 0) {
                Write-IcingaConsoleError 'Failed to update password for user "{0}": {1}' -Objects $IcingaUser, $Result.Error;

                return @{
                    'User' = $UserConfig.Caption;
                    'SID'  = $UserConfig.SID;
                };
            }

            Write-IcingaConsoleNotice 'User updated successfully.';
        }

        return @{
            'User' = $UserConfig.Caption;
            'SID'  = $UserConfig.SID;
        };
    }

    # Access our local Account Database
    $AccountDB        = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer";
    $IcingaUserObject = $AccountDB.Create("User", $IcingaUser);
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

    $UserConfig = Get-IcingaWindowsInformation -Class 'Win32_UserAccount' | Where-Object { $_.Name -eq $IcingaUser };

    Write-IcingaConsoleNotice 'User was successfully created.';

    return @{
        'User' = $UserConfig.Caption;
        'SID'  = $UserConfig.SID;
    };
}
