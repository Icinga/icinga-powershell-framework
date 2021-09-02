function Get-IcingaUsernameFromSID()
{
    param (
        [string]$SID
    );

    if ([string]::IsNullOrEmpty($SID)) {
        Write-IcingaConsoleError 'You have to specify a SID';
        return $null;
    }

    $UserData   = New-Object System.Security.Principal.SecurityIdentifier $SID;
    $UserObject = $UserData.Translate([System.Security.Principal.NTAccount]);

    return $UserObject.Value;
}
