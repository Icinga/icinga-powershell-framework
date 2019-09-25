Import-IcingaLib icinga\plugin;
Import-IcingaLib provider\users;

function Invoke-IcingaCheckUsers()
{
    param (
        [array]$Username,
        $Warning,
        $Critical,
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
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $UsersPackage.AddCheck($IcingaCheck);
        }
    } else {
        foreach ($User in $LoggedOnUsers.users.Keys) {
            $UsersPackage.AddCheck(
                (New-IcingaCheck -Name ([string]::Format('Logged On User "{0}"', $User)) -Value $LoggedOnUsers.users.$User.count)
            );
        }
        $IcingaCheck = New-IcingaCheck -Name 'Logged On Users' -Value $LoggedOnUsers.count;
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $UsersPackage.AddCheck($IcingaCheck)
    }
    
    return (New-IcingaCheckResult -Name 'Users' -Check $UsersPackage -NoPerfData $NoPerfData -Compile);
}
