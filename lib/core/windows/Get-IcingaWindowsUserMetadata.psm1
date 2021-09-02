function Get-IcingaWindowsUserMetadata()
{
    return @{
        'Description' = 'Dedicated user for Icinga for Windows with limited privileges. The user is only allowed to be used as service user, while local login or RDP sessions are disabled. For monitoring, this user requires a valid JEA profile.';
        'FullName'    = 'Icinga for Windows Monitoring User';
    };
}
