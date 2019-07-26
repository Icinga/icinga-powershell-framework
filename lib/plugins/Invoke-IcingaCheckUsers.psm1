Import-IcingaLib icinga\plugin;
Import-IcingaLib provider\users;

function Invoke-IcingaCheckUsers()
{
    param (
        [array]$username,
        [switch]$NoPerfData,
        $Verbose

    );
    
    $UsersPackage  = New-IcingaCheckPackage -Name 'Users' -OperatorAnd -Verbos $Verbose;
    $UserInformation = Get-IcingaUsers -Username $username;

    foreach ($ExistingUser in $UserInformation) {
    Write-Host $ExistingUser;
    If ($null -eq $ExistingUser)
    {
        continue;
    }
    $Status = $ExistingUser.Enabled;

    $IcingaCheck = New-IcingaCheck -Name ([string]::Format('User {0} Status {1} ', $ExistingUser, $Status)) -Value $Status -NoPerfData;
    $IcingaCheck.CritIfNotMatch('True') | Out-Null;
    $UsersPackage.AddCheck($IcingaCheck);
    }
    
    exit (New-IcingaCheckResult -Name 'Users' -Check $UsersPackage -NoPerfData $NoPerfData -Compile);
}