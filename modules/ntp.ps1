param($Config = $null);

function ClassNTP
{
    param($Config = $null);
    [hashtable]$NTPInformations = @{};
    # This will return a hashtable with every single counter
    # we specify within the array
    $counter = Get-Icinga-Counter -CounterArray @(
        '\Windows Time service\clock frequency adjustment',
        '\Windows Time service\ntp client time source count',
        '\Windows Time service\ntp server outgoing responses',
        '\Windows Time service\computed time offset',
        '\Windows Time service\ntp roundtrip delay',
        '\Windows Time service\ntp server incoming requests'
    );
    $NTPInformations.Add('counter', $counter);

    # Load the source from which we receive our NTP config
    $NTPInformations.Add('source', (&W32tm /query /source));

    # Load the NTP config and parse it properly
    $NTPInformations.Add(
        'config',
        $Icinga2.Utils.IniParser.LoadFromArray(
            (&W32tm /query /configuration),
            $TRUE
        )
    );

    return $NTPInformations;
}

return ClassNTP -Config $Config;