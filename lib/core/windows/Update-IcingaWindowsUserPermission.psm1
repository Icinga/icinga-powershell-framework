function Update-IcingaWindowsUserPermission()
{
    param (
        [string]$SID    = '',
        [switch]$Remove = $FALSE
    );

    if ([string]::IsNullOrEmpty($SID)) {
        Write-IcingaConsoleError 'You have to specify the SID of the user to set the security profile to';
        return;
    }

    if ($SID.Length -le 16) {
        Write-IcingaConsoleWarning 'It seems the provided SID "{0}" is a system SID. Skipping permission update' -Objects $SID;
        return;
    }

    [bool]$IsManagedUser = Test-IcingaManagedUser -SID $SID;

    # If we are removing permissions, but the user is not a managed user, we should skip the removal, as we don't want to remove permissions for system accounts or other non-managed users
    # which might have been added manually or by other software
    if ($Remove -and -not $IsManagedUser) {
        Write-IcingaConsoleWarning 'The specified SID "{0}" is not a managed user. Skipping permission removal' -Objects $SID;
        return;
    }

    $UpdatedProfile     = New-IcingaTemporaryFile;
    $SystemOutput       = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/export /cfg "{0}.inf"', $UpdatedProfile));
    $NewSecurityProfile = @();

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to fetch security profile: {0}', $SystemOutput.Message));
        return;
    }

    $SecurityProfile = '';
    # These SID's are required to be present, as they ship with Windows by default
    # On non-english Windows installations these SID's might be missing and requires us
    # to ensure they are present
    [string[]]$RequiredLoginSIDs = @(
        '*S-1-5-80-0', # NT SERVICE\ALL SERVICES
        '*S-1-5-99-0'  # RESTRICTED SERVICES\ALL RESTRICTED SERVICES
    );

    # Read the current security profile file
    $SecurityProfile               = Get-Content "$UpdatedProfile.inf";
    [bool]$IsPrivilegedSection     = $FALSE;
    [bool]$HasDenyNetworkLogon     = $FALSE;
    [bool]$HasDenyInteractiveLogon = $FALSE;

    foreach ($line in $SecurityProfile) {
        if ($line -match '^\s*\[Privilege Rights\]\s*$') {
            $IsPrivilegedSection = $TRUE;
            $NewSecurityProfile += $line;
            continue;
        }

        # Check for next section, which is [Version]
        if ($IsPrivilegedSection -and $line -match '^\s*\[.*\]\s*$') {
            $IsPrivilegedSection = $FALSE;

            # If we are adding permissions, ensure the deny logon rights are present
            # Only applies for managed users, as we don't want to add deny logon rights for system accounts or other non-managed users
            if ($HasDenyNetworkLogon -eq $FALSE -and $IsManagedUser) {
                Write-IcingaConsoleWarning 'Adding missing "SeDenyNetworkLogonRight" privilege to security profile';
                $NewSecurityProfile += [string]::Format('SeDenyNetworkLogonRight = *{0}', $SID);
            }
            if ($HasDenyInteractiveLogon -eq $FALSE -and $IsManagedUser) {
                Write-IcingaConsoleWarning 'Adding missing "SeDenyInteractiveLogonRight" privilege to security profile';
                $NewSecurityProfile += [string]::Format('SeDenyInteractiveLogonRight = *{0}', $SID);
            }
        }

        if ($line -match '^\s*(SeServiceLogonRight|SeDenyNetworkLogonRight|SeDenyInteractiveLogonRight)\s*=\s*(.*)$') {
            [string]$privilegeName = $matches[1];
            [string]$rhsValue      = $matches[2];

            if ($privilegeName -eq 'SeDenyNetworkLogonRight') {
                $HasDenyNetworkLogon = $TRUE;
            }
            if ($privilegeName -eq 'SeDenyInteractiveLogonRight') {
                $HasDenyInteractiveLogon = $TRUE;
            }

            # Skip deny logon rights for non-managed users, as we don't want to add deny logon rights for system accounts or other non-managed users
            if (-not $IsManagedUser -and ($privilegeName -eq 'SeDenyNetworkLogonRight' -or $privilegeName -eq 'SeDenyInteractiveLogonRight')) {
                $NewSecurityProfile += $line;
                continue;
            }

            [string[]]$entryList     = @();
            [string[]]$nonSidEntries = @();

            if ([string]::IsNullOrEmpty($rhsValue) -eq $FALSE) {
                [string[]]$tokenArray = $rhsValue -split ',';

                foreach ($token in $tokenArray) {
                    $token = $token.Trim();

                    if ([string]::IsNullOrEmpty($token) -eq $FALSE) {
                        # Detect any entries that are not SIDs (SIDs start with '*' and S-1-...)
                        if (-not ($token -match '^\*S-1-\d+(-\d+)*$')) {
                            # Try to fetch the SID for the user entry and add it if a SID
                            # is found to ensure we don't accidentally remove entries which are still valid
                            $SIDFromToken = Get-IcingaUserSID -User $token;

                            if ([string]::IsNullOrEmpty($SIDFromToken) -eq $FALSE) {
                                $entryList += $token;
                                continue;
                            }

                            # Add the non-SID entry to a list to print a warning later, but don't add it to the entry list,
                            # as we don't want to remove it if we are removing permissions for the managed user
                            $nonSidEntries += $token;
                            continue;
                        }

                        if ($Remove -and $token -like "*$SID") {
                            Write-IcingaConsoleNotice 'Removing SID "{0}" from privilege "{1}"' -Objects $SID, $privilegeName;
                            continue;
                        }

                        $entryList += $token;
                    }
                }
            }

            if ($nonSidEntries.Count -gt 0) {
                Write-IcingaConsoleWarning 'Found non-SID entries for "{0}": {1}' -Objects $privilegeName, ($nonSidEntries -join ',');
            }

            # Ensure required login SIDs are present for SeServiceLogonRight
            if ($privilegeName -eq 'SeServiceLogonRight') {
                foreach ($requiredSID in $RequiredLoginSIDs) {
                    if ($entryList -notcontains $requiredSID) {
                        Write-IcingaConsoleWarning 'Adding missing default SID "{0}" for privilege "{1}"' -Objects $requiredSID, $privilegeName;
                        $entryList += $requiredSID;
                    }
                }
            }

            # Ensure the managed user SID is present if we are not removing it
            if ($Remove -eq $FALSE) {
                [string]$managedSidEntry = "*$SID";
                if ($entryList -notcontains $managedSidEntry) {
                    $entryList += $managedSidEntry;
                }
            } else {
                Write-IcingaConsoleNotice 'Removing SID "{0}" from privilege "{1}"' -Objects $SID, $privilegeName;
            }

            # If we add an pricilege and there are no entries left, we still have to add the line with an empty value
            # Windows will handle the empty value correctly and remove the line itself
            $line = [string]::Format('{0} = {1}', $privilegeName, ($entryList -join ','));
        }

        $NewSecurityProfile += $line;
    }

    Set-Content -Path "$UpdatedProfile.inf" -Value $NewSecurityProfile;

    $SystemOutput = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/import /cfg "{0}.inf" /db "{0}.sdb"', $UpdatedProfile));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to import security profile: {0}', $SystemOutput.Message));
        return;
    }

    $SystemOutput = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/configure /cfg "{0}.inf" /db "{0}.sdb"', $UpdatedProfile));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to configure security profile: {0}', $SystemOutput.Message));
        return;
    }

    Remove-Item $UpdatedProfile*;
}
