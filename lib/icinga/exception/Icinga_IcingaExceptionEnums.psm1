<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

[hashtable]$Permission = @{
    PerformanceCounter = 'A Plugin failed to fetch Performance Counter information. This may be caused when the used Service User is not permitted to access these information. To fix this, please add the User the Icinga Agent is running on into the "Performance Log Users" group and restart the service.';
    CacheFolder        = "A plugin failed to write new data into the configured cache directory. Please update the permissions of this folder to allow write access for the user the Icinga Service is running with or use another folder as cache directory.";
    CimInstance        = 'The user you are running this command as does not have permission to access the requested Cim-Object. To fix this, please add the user the Agent is running with to the "Remote Management Users" groups and grant access to the WMI branch "root/cimv2" and add the permission "Remote enable".';
    WMIObject          = 'The user you are running this command as does not have permission to access the requested Wmi-Object. To fix this, please add the user the Agent is running with to the "Remote Management Users" groups and grant access to the WMI branch "root/cimv2" and add the permission "Remote enable".';
};

[hashtable]$Inputs = @{
    PerformanceCounter      = 'A plugin failed to fetch Performance Counter information. Please ensure the counter is written properly and available on your system.';
    EventLogLogName         = 'Failed to fetch EventLog information. Please specify a valid LogName.';
    EventLog                = 'Failed to fetch EventLog information. Please check your inputs for EntryTypes and other categories and try again.';
    ConversionUnitMissing   = 'Unable to parse input value. You have to add an unit to your input value. Example: "10GB". Allowed units are: "B, KB, MB, GB, TB, PB, KiB, MiB, GiB, TiB, PiB".';
    CimClassNameUnknown     = 'The provided class name you try to fetch with Get-CimInstance is not known on this system.';
    WmiObjectClassUnknown   = 'The provided class name you try to fetch with Get-WmiObject is not known on this system.';
    MSSQLCredentialHandling = 'The connection to MSSQL was not possbible because your login credential was not correct.';
    MSSQLCommandMissing     = 'Failed to build a SQL query'
};

[hashtable]$Configuration = @{
    PluginArgumentConflict = 'Your plugin argument configuration is causing a conflict. Mostly this error is caused by missmatching configurations by enabling multiple switch arguments which are resulting in a conflicting configuration for the plugin.';
<<<<<<< HEAD
    PluginArgumentMissing  = 'Your plugin argument configuration is missing mandatory arguments. This is error is caused when mandatory or required arguments are missing from a plugin call and the operation is unable to process without them.';
    PluginNotInstalled     = 'The plugin assigned to this service check seems not to be installed on this machine. Please review your service check configuration for spelling errors and check if the plugin is installed and executable on this machine by PowerShell.';
    PluginNotAssigned      = 'Your check for this service could not be processed because it seems like no valid Cmdlet was assigned to the check command. Please review your check command to ensure that a valid Cmdlet is assigned and executed by a PowerShell call.';
    EventLogNotInstalled   = 'Your Icinga PowerShell Framework has been executed by an unprivileged user before it was properly installed. The Windows EventLog application could not be registered because the current user has insufficient permissions. Please log into the machine and run "Use-Icinga" once from an administrative shell to complete the setup process. Once done this error should vanish.';
=======
    PluginArgumentmissing  = 'Your plugin argument configuration is missing mandatory arguments. This error is caused when mandatory or required arguments are missing from a plugin call and the operation is unable to process without them.';
>>>>>>> 9409d33... WIP
}

[hashtable]$Connection = @{
    MSSQLConnectionError = 'Could not open a connection to SQL Server. This failure may be caused by the fact that under the default settings SQL Server does not allow remote connections or the host is unreachable.';
}

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaExceptionEnums.IcingaExecptionHandlers.PerformanceCounter
 #>
[hashtable]$IcingaExceptions = @{
    Permission    = $Permission;
    Inputs        = $Inputs;
    Configuration = $Configuration;
    Connection    = $Connection;
}

Export-ModuleMember -Variable @( 'IcingaExceptions' );
