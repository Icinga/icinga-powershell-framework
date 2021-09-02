function Uninstall-IcingaSecurity()
{
    param (
        $IcingaUser = 'icinga'
    );

    Uninstall-IcingaServiceUser -IcingaUser $IcingaUser;
    Uninstall-IcingaJEAProfile;
}
