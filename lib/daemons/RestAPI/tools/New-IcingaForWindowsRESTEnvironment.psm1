function New-IcingaForWindowsRESTEnvironment()
{
    param (
        [int]$ThreadCount = 5
    );

    $Global:Icinga.Public.Daemons.Add(
        'RESTApi',
        @{
            'ApiRequests'             = @{ };
            'ApiCallThreadAssignment' = @{ };
            'TotalThreads'            = $ThreadCount;
            'LastThreadId'            = 0;
            # This will add another hashtable to our previous
            # IcingaPowerShellRestApi hashtable to store actual
            # endpoint configurations for the API
            'RegisteredEndpoints'     = @{ };
            # This will add another hashtable to our previous
            # IcingaPowerShellRestApi hashtable to store actual
            # command aliases for execution for the API
            'CommandAliases'          = @{ };
            # This will add another hashtable to our previous
            # IcingaPowerShellRestApi hashtable to store actual
            # command aliases for execution for the API
            'ClientBlacklist'         = @{ };
        }
    );

    Add-IcingaThreadPool -Name 'RESTApiPool' -MaxInstances ($ThreadCount * 2);
}
