<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

[hashtable]$Permission = @{
    PerformanceCounter    = 'A Plugin failed to fetch Performance Counter information. This may be caused when the used Service User is not permitted to access these information. To fix this, please add the User the Icinga Agent is running on into the "Performance Monitor Users" group and restart the service.';
    CacheFolder           = "A plugin failed to write new data into the configured cache directory. Please update the permissions of this folder to allow write access for the user the Icinga Service is running with or use another folder as cache directory.";
    CimInstance           = @{
        'Message' = 'The user you are running this command as does not have permission to access the requested Cim-Object. To fix this, please add the user the Agent is running with to the "Remote Management Users" groups and grant access to the WMI branch for the Class/Namespace mentioned above and add the permission "Remote enable".';
        'IWKB'    = 'IWKB000001';
    };
    WMIObject             = @{
        'Message' = 'The user you are running this command as does not have permission to access the requested Wmi-Object. To fix this, please add the user the Agent is running with to the "Remote Management Users" groups and grant access to the WMI branch for the Class/Namespace mentioned above and add the permission "Remote enable".';
        'IWKB'    = 'IWKB000001';
    };
    WindowsUpdate         = @{
        'Message' = 'The user you are running this command as does not have permission to access the Windows Update ComObject "Microsoft.Update.Session".';
        'IWKB'    = 'IWKB000006';
    };
    WindowsAuthentication = "A plugin failed to authenticate against the authentication servers or the local machine with the given credentials";
};

[hashtable]$Inputs = @{
    PerformanceCounter      = 'A plugin failed to fetch Performance Counter information. Please ensure the counter is written properly and available on your system.';
    EventLogLogName         = 'Failed to fetch EventLog information. Please specify a valid LogName.';
    EventLog                = 'Failed to fetch EventLog information. Please check your inputs for EntryTypes and other categories and try again.';
    ConversionUnitMissing   = 'Unable to parse input value. You have to add an unit to your input value. Example: "10GB". Allowed units are: "B, KB, MB, GB, TB, PB, KiB, MiB, GiB, TiB, PiB".';
    MultipleUnitUsage       = 'Failed to convert your Icinga threshold units as you were trying to convert values with a different type of unit category. This feature only supports the conversion of one unit category. For example you can not convert 20MB:10d in the same call, as size and time units are not compatible.';
    CimClassNameUnknown     = 'The provided class name you try to fetch with Get-CimInstance is not known on this system.';
    WmiObjectClassUnknown   = 'The provided class name you try to fetch with Get-WmiObject is not known on this system.';
    MSSQLCredentialHandling = 'The connection to MSSQL was not possible because your login credential was not correct.';
    MSSQLCommandMissing     = 'Failed to build a SQL query';
    RegexError              = 'A request was not handled properly because a provided regex could not be interpreted. Please validate your regex and try again. In case you are trying to access a ressource containing [], you will have to escape each symbol by using `. Example: myservice`[`]';
};

[hashtable]$Configuration = @{
    PluginArgumentConflict     = 'Your plugin argument configuration is causing a conflict. Mostly this error is caused by mismatching configurations by enabling multiple switch arguments which are resulting in a conflicting configuration for the plugin.';
    PluginArgumentMissing      = 'Your plugin argument configuration is missing mandatory arguments. This error is caused when mandatory or required arguments are missing from a plugin call and the operation is unable to process without them.';
    PluginArgumentAsymmetry    = 'Your plugin argument configuration is causing an asymmetry. This error is caused by an uneven amount of arguments in your plugin call. Please ensure that your plugin call is properly configured and all arguments are set correctly.';
    PluginNotInstalled         = 'The plugin assigned to this service check seems not to be installed on this machine. Please review your service check configuration for spelling errors and check if the plugin is installed and executable on this machine by PowerShell. You can ensure modules are available by manually importing them by their name with the following commands: Import-Module -Name "module name" -Force; Import-Module -Name "module name" -Global -Force;';
    PluginNotAssigned          = 'Your check for this service could not be processed because it seems like no valid Cmdlet was assigned to the check command. Please review your check command to ensure that a valid Cmdlet is assigned and executed by a PowerShell call.';
    EventLogNotInstalled       = 'Your Icinga PowerShell Framework has been executed by an unprivileged user before it was properly installed. The Windows EventLog application could not be registered because the current user has insufficient permissions. Please log into the machine and run "Use-Icinga" once from an administrative shell to complete the setup process. Once done this error should vanish.';
    PerfCounterCategoryMissing = 'The specified Performance Counter category was not found on this system. This could either be a configuration error on your local Windows machine or a wrong usage of the plugin. Please check on different Windows machines if this issue persis. In case it only occurs on certain machines it is likely that the counter is simply not present and the plugin can not be processed.';
}

[hashtable]$Connection = @{
    MSSQLConnectionError = 'Could not open a connection to SQL Server. This failure may be caused by the fact that under the default settings SQL Server does not allow remote connections or the host is unreachable.';
}

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaException.Inputs.PerformanceCounter
 #>

if ($null -eq $IcingaExceptions) {
    [hashtable]$IcingaExceptions = @{
        Permission    = $Permission;
        Inputs        = $Inputs;
        Configuration = $Configuration;
        Connection    = $Connection;
    }
}

Export-ModuleMember -Variable @( 'IcingaExceptions' );
