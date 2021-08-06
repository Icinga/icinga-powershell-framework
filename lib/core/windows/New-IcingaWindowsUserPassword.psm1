function New-IcingaWindowsUserPassword()
{
    if ($null -eq $Global:Icinga) {
        $Global:Icinga = @{
            'ServiceUserPassword' = $null
        };
    }

    if ($Global:Icinga.ContainsKey('ServiceUserPassword') -eq $FALSE) {
        $Global:Icinga.Add('ServiceUserPassword', $null);
    }

    [SecureString]$Password            = ConvertTo-IcingaSecureString -String (Get-IcingaRandomChars -Count 60);
    $Global:Icinga.ServiceUserPassword = $Password;

    return $Password;
}
