<#
 # This script will provide 'Enums' we can use for proper
 # error handling and to provide more detailed descriptions
 #
 # Example usage:
 # $IcingaEventLogEnums[2000]
 #>
 [hashtable]$IcingaEventLogEnums += @{
    'Framework' = @{
        # TODO: Add event log messages
    }
};

Export-ModuleMember -Variable @( 'IcingaEventLogEnums' );
