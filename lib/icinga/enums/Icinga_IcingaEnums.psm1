<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

[hashtable]$IcingaExitCode = @{
    Ok       = 0;
    Warning  = 1;
    Critical = 2;
    Unknown  = 3;
};

[hashtable]$IcingaExitCodeText = @{
    0 = '[OK]';
    1 = '[WARNING]';
    2 = '[CRITICAL]';
    3 = '[UNKNOWN]';
};

[hashtable]$IcingaExitCodeColor = @{
    0 = 'Green';
    1 = 'Yellow';
    2 = 'Red';
    3 = 'Magenta';
};

[hashtable]$IcingaMeasurementUnits = @{
    's'    = 'seconds';
    'ms'   = 'milliseconds';
    'us'   = 'microseconds';
    '%'    = 'percent';
    'B'    = 'bytes';
    'KB'   = 'Kilobytes';
    'MB'   = 'Megabytes';
    'GB'   = 'Gigabytes';
    'TB'   = 'Terabytes';
    'c'    = 'counter';
    'Kbit' = 'Kilobit';
    'Mbit' = 'Megabit';
    'Gbit' = 'Gigabit';
    'Tbit' = 'Terabit';
    'Pbit' = 'Petabit';
    'Ebit' = 'Exabit';
    'Zbit' = 'Zettabit';
    'Ybit' = 'Yottabit';
};

<##################################################################################################
################# Service Enums ##################################################################
##################################################################################################>

[hashtable]$ServiceStartupTypeName = @{
    0 = 'Boot';
    1 = 'System';
    2 = 'Automatic';
    3 = 'Manual';
    4 = 'Disabled';
    5 = 'Unknown'; # Custom
}

[hashtable]$ServiceWmiStartupType = @{
    'Boot'     = 0;
    'System'   = 1;
    'Auto'     = 2;
    'Manual'   = 3;
    'Disabled' = 4;
    'Unknown'  = 5; # Custom
}

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaEnums.IcingaExitCode.Ok
 #>
if ($null -eq $IcingaEnums) {
    [hashtable]$IcingaEnums = @{
        IcingaExitCode         = $IcingaExitCode;
        IcingaExitCodeText     = $IcingaExitCodeText;
        IcingaExitCodeColor    = $IcingaExitCodeColor;
        IcingaMeasurementUnits = $IcingaMeasurementUnits;
        #services
        ServiceStartupTypeName = $ServiceStartupTypeName;
        ServiceWmiStartupType  = $ServiceWmiStartupType;
    }
}

Export-ModuleMember -Variable @( 'IcingaEnums' );
