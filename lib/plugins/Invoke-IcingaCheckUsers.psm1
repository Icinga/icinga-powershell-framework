Import-IcingaLib icinga\plugin;
Import-IcingaLib provider\users;

<#
.SYNOPSIS
   Checks how many files are in a directory.

.DESCRIPTION
   Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g 'C:\Users\Icinga\Backup' contains 200 files, WARNING is set to 150, CRITICAL is set to 300. In this case the check will return CRITICAL

   More Information on https://github.com/LordHepipud/icinga-module-windows

.FUNCTIONALITY
   This module is intended to be used to check how many files and directories are within are specified path. 
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
   
.EXAMPLE
   PS>

.EXAMPLE
   PS>

.PARAMETER IcingaCheckUsers_Int_Warning
   Used to specify a Warning threshold. In this case an integer value.

.PARAMETER IcingaCheckUsers_Int_Critical
   Used to specify a Critical threshold. In this case an integer value.

.PARAMETER Username
   Used to specify an array of usernames to match against.
   
   e.g 'Administrator', 'Icinga'

.INPUTS
   System.String

.OUTPUTS
   System.String

.LINK
   https://github.com/LordHepipud/icinga-module-windows

.NOTES
#>

function Invoke-IcingaCheckUsers()
{
    param (
        [array]$Username,
        [int]$IcingaCheckUsers_Int_Warning,
        [int]$IcingaCheckUsers_Int_Critical,
        [switch]$NoPerfData,
        [int]$Verbose
    );
    
    $UsersPackage  = New-IcingaCheckPackage -Name 'Users' -OperatorAnd -Verbose $Verbose;
    $LoggedOnUsers = Get-IcingaLoggedOnUsers -UserFilter $Username;

    if ($Username.Count -ne 0) {
        foreach ($User in $Username) {
            $IcingaCheck = $null;
            [int]$LoginCount = 0;

            if ($LoggedOnUsers.users.ContainsKey($User)) {
                $LoginCount = $LoggedOnUsers.users.$User.count;
            }

            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Logged On User "{0}"', $User)) -Value $LoginCount;
            $IcingaCheck.WarnOutOfRange($IcingaCheckUsers_Int_Warning).CritOutOfRange($IcingaCheckUsers_Int_Critical) | Out-Null;
            $UsersPackage.AddCheck($IcingaCheck);
        }
    } else {
        foreach ($User in $LoggedOnUsers.users.Keys) {
            $UsersPackage.AddCheck(
                (New-IcingaCheck -Name ([string]::Format('Logged On User "{0}"', $User)) -Value $LoggedOnUsers.users.$User.count)
            );
        }
        $IcingaCheck = New-IcingaCheck -Name 'Logged On Users' -Value $LoggedOnUsers.count;
        $IcingaCheck.WarnOutOfRange($IcingaCheckUsers_Int_Warning).CritOutOfRange($IcingaCheckUsers_Int_Critical) | Out-Null;
        $UsersPackage.AddCheck($IcingaCheck)
    }
    
    exit (New-IcingaCheckResult -Name 'Users' -Check $UsersPackage -NoPerfData $NoPerfData -Compile);
}
