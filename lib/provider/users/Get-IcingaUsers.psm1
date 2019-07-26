function Get-IcingaUsers ()
{
    param (
        [array]$Username
    );


    if ($null -eq $Username) {
        return Get-LocalUser;
    } else {
        [array]$UserInformation
        foreach ($UniqueUser in $Username) {
            [array]$UserInformation += Get-LocalUser -Name $UniqueUser;
        }
    }

    return $UserInformation;
}