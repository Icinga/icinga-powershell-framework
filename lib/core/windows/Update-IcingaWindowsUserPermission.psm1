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

    if ((Test-IcingaManagedUser -SID $SID) -eq $FALSE) {
        Write-IcingaConsoleWarning 'This user is not managed by Icinga directly. Skipping permission update';
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
            if ($HasDenyNetworkLogon -eq $FALSE) {
                Write-IcingaConsoleWarning 'Adding missing "SeDenyNetworkLogonRight" privilege to security profile';
                $NewSecurityProfile += [string]::Format('SeDenyNetworkLogonRight = *{0}', $SID);
            }
            if ($HasDenyInteractiveLogon -eq $FALSE) {
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

            [string[]]$entryList     = @();
            [string[]]$nonSidEntries = @();

            if ([string]::IsNullOrEmpty($rhsValue) -eq $FALSE) {
                [string[]]$tokenArray = $rhsValue -split ',';

                foreach ($token in $tokenArray) {
                    $token = $token.Trim();

                    if ([string]::IsNullOrEmpty($token) -eq $FALSE) {
                        # Detect any entries that are not SIDs (SIDs start with '*' and S-1-...)
                        if (-not ($token -match '^\*S-1-\d+(-\d+)*$')) {
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
