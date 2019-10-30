<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

[hashtable]$IcingaExitCode = @{
    Ok        = 0;
    Warning   = 1;
    Critical  = 2;
    Unknown   = 3;
};

[hashtable]$IcingaExitCodeText = @{
    0 = '[OK]';
    1 = '[WARNING]';
    2 = '[CRITICAL]';
    3 = '[UNKNOWN]';
};

[hashtable]$IcingaMeasurementUnits = @{
    's'  = 'seconds';
    'ms' = 'milliseconds';
    'us' = 'microseconds';
    '%'  = 'percent';
    'B'  = 'bytes';
    'KB' = 'kilobytes';
    'MB' = 'megabytes';
    'GB' = 'gigabytes';
    'TB' = 'terabytes';
    'c'  = 'counter';
};

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaEnums.IcingaExitCode.Ok
 #>
[hashtable]$IcingaEnums = @{
    IcingaExitCode         = $IcingaExitCode;
    IcingaExitCodeText     = $IcingaExitCodeText;
    IcingaMeasurementUnits = $IcingaMeasurementUnits;
}

Export-ModuleMember -Variable @( 'IcingaEnums' );
