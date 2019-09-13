<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

 [hashtable]$Throw = @{
    PerformanceCounter = 'Icinga failed to fetch Performance Counter information. This may be caused when the Icinga Service User is not permited to access these information. To fix this, please add the User the Icinga Agent is running on into the "Performance Log Users" group.';
};

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaExceptionEnums.IcingaExecptionHandlers.PerformanceCounter
 #>
[hashtable]$IcingaExceptions = @{
    Throw = $Throw;
}

Export-ModuleMember -Variable @( 'IcingaExceptions' );
