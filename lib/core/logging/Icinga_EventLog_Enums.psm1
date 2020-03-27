<#
 # This script will provide 'Enums' we can use for proper
 # error handling and to provide more detailed descriptions
 #
 # Example usage:
 # $IcingaEventLogEnums[2000]
 #>
 [hashtable]$IcingaEventLogEnums += @{
    'Framework' = @{
        1000 = @{
            'EntryType' = 'Information';
            'Message'   = 'Generic debug message issued by the Framework or its components';
            'Details'   = 'The Framework or is components can issue generic debug message in case the debug log is enabled. Please ensure to disable it, if not used. You can do so with the command "Disable-IcingaFrameworkDebugMode"';
            'EventId'   = 1000;
        };
    }
};

Export-ModuleMember -Variable @( 'IcingaEventLogEnums' );
