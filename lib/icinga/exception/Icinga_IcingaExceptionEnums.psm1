<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

[hashtable]$Permission = @{
    PerformanceCounter = 'A Plugin failed to fetch Performance Counter information. This may be caused when the used Service User is not permitted to access these information. To fix this, please add the User the Icinga Agent is running on into the "Performance Log Users" group.';
};

[hashtable]$Inputs = @{
    PerformanceCounter = 'A plugin failed to fetch Performance Counter information. Please ensure the counter is written properly and available on your system.';
};

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaExceptionEnums.IcingaExecptionHandlers.PerformanceCounter
 #>
[hashtable]$IcingaExceptions = @{
    Permission = $Permission;
    Inputs     = $Inputs;
}

Export-ModuleMember -Variable @( 'IcingaExceptions' );
