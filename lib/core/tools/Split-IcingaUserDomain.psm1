<#
.SYNOPSIS
    Splits a username containing a domain into a hashtable to easily use both values independently.
    If no domain is specified the hostname will used as "local domain"
.DESCRIPTION
    Splits a username containing a domain into a hashtable to easily use both values independently.
    If no domain is specified the hostname will used as "local domain"
.PARAMETER User
    A user object either containing only the user or domain information
.EXAMPLE
    PS>Split-IcingaUserDomain -User 'icinga';

    Name                           Value
    ----                           -----
    User                           icinga
    Domain                         icinga-win
.EXAMPLE
    PS>Split-IcingaUserDomain -User 'ICINGADOMAIN\icinga';

    Name                           Value
    ----                           -----
    User                           icinga
    Domain                         ICINGADOMAIN
.EXAMPLE
    PS>Split-IcingaUserDomain -User 'icinga@ICINGADOMAIN';

    Name                           Value
    ----                           -----
    User                           icinga
    Domain                         ICINGADOMAIN
.EXAMPLE
    PS>Split-IcingaUserDomain -User '.\icinga';

    Name                           Value
    ----                           -----
    User                           icinga
    Domain                         icinga-win
.INPUTS
    System.String
.OUTPUTS
    System.Hashtable
#>

function Split-IcingaUserDomain()
{
    param (
        $User
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError 'Please enter a valid username';
        return '';
    }

    [array]$UserData  = @();

    if ($User.Contains('\')) {
        $UserData = $User.Split('\');
    } elseif ($User.Contains('@')) {
        [array]$Split = $User.Split('@');
        $UserData = @(
            $Split[1],
            $Split[0]
        );
    } else {
        $UserData = @(
            (Get-IcingaNetbiosName),
            $User
        );
    }

    if ([string]::IsNullOrEmpty($UserData[0]) -Or $UserData[0] -eq '.' -Or $UserData[0] -eq 'BUILTIN') {
        $UserData[0] = (Get-IcingaNetbiosName);
    }

    return @{
        'Domain' = $UserData[0];
        'User'   = $UserData[1];
    };
}
