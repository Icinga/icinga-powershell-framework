param($Config = $null);

function ClassNetwork
{
    param($Config = $null);
    # The storage variables we require to store our data
    [hashtable]$NetworkData             = @{};
    [hashtable]$StructuredInterfaceData = @{};

    $CachedNetwork = $Icinga2.Utils.Modules.GetCacheElement(
        $MyInvocation.MyCommand.Name,
        'NetworkData'
    );

    # This will return a hashtable with every single counter
    # we specify within the array. Instead of returning all
    # the values in the returned hashtable, we will rebuild
    # the result a little to have a improved output which
    # is more user friendly and allows us to check for
    # certain interfaces in detail with a simpler
    # accessing possibility
    $counter = Get-Icinga-Counter -CounterArray @(
        '\Network Interface(*)\Bytes Received/sec',
        '\Network Interface(*)\Bytes Sent/sec',
        '\Network Interface(*)\Packets Received Unicast/sec',
        '\Network Interface(*)\Packets Sent Unicast/sec',
        '\Network Interface(*)\Packets Received Non-Unicast/sec',
        '\Network Interface(*)\Packets Sent Non-Unicast/sec',
        '\Network Interface(*)\Packets Outbound Errors',
        '\Network Interface(*)\Packets Sent/sec',
        '\Network Interface(*)\TCP RSC Exceptions/sec',
        '\Network Interface(*)\Packets Outbound Discarded',
        '\Network Interface(*)\TCP RSC Coalesced Packets/sec',
        '\Network Interface(*)\Bytes Total/sec',
        '\Network Interface(*)\Current Bandwidth',
        '\Network Interface(*)\Packets Received Unknown',
        '\Network Interface(*)\TCP Active RSC Connections',
        '\Network Interface(*)\Offloaded Connections',
        '\Network Interface(*)\Packets/sec',
        '\Network Interface(*)\Packets Received Errors',
        '\Network Interface(*)\Packets Received/sec',
        '\Network Interface(*)\Packets Received Discarded',
        '\Network Interface(*)\Output Queue Length',
        '\Network Interface(*)\TCP RSC Average Packet Size'
    );

    # This function will help us to build a structured output based on
    # interfaces found within the instances. We will use our
    # Network Interface as 'index' to assign our performance Counters to.
    # In addition we then provide the hashtable of counters we fetched
    # above.
    $StructuredInterfaceData = Get-Icinga-Counter `
                            -CreateStructuredOutputForCategory 'Network Interface' `
                            -StructuredCounterInput $counter;

    $NetworkData.Add('interfaces', $StructuredInterfaceData);

    # Add additional details to our interfaces, like MAC Address, Interface Index and current connection status
    $NetworkAdapter = Get-WMIObject Win32_NetworkAdapter;

    [hashtable]$DuplicateIDCache = @{};

    foreach ($adapter in $NetworkAdapter) {
        # The Performance Counter return values in brackets with [], while WMI returns ()
        # In addition, WMI uses / within Interface names, while Perf Counter uses _
        # We need to take care about this here
        [string]$AdapterName = $adapter.Name.Replace('(', '[').Replace(')', ']');
        [string]$AdapterName = $AdapterName.Replace('/', '_');
        [string]$AdapterName = $AdapterName.Replace('#', '_');

        # To ensure duplicate interface names will not cause this module
        # to crash, we will have to build up a cache and add numeric
        # additions.
        if ($DuplicateIDCache.ContainsKey($AdapterName) -eq $FALSE) {
            $DuplicateIDCache.Add($AdapterName, 0);
        }

        # In case we add adapters we have no performance counters for,
        # create a new hashtable object for the name
        if ($StructuredInterfaceData.ContainsKey($AdapterName) -eq $FALSE) {
            $StructuredInterfaceData.Add($AdapterName, @{});
        } else {
            # In case the interface does already exist, check if we require
            # to rename the interface with a index ID in addition. As we
            # have to ensure Performance Counters are added to Physical Adapters
            # only, we will focus in these indexes. All other instances will
            # receive a follow-up ID.
            [int]$ID = $DuplicateIDCache[$AdapterName] + 1;
            if ($adapter.PhysicalAdapter -eq $FALSE) {
                $ID += 1;
                $DuplicateIDCache[$AdapterName] = $ID;
            } else {
                # Physical Adapters always have unique names, therefor we should
                # always use index 1 for these to ensure Performance Counter data
                # is added to the correct interfaces
                $ID = 1;
            }

            # Only add index ID's to interfaces in case we are not equal 1
            if ($ID -ne 1) {
                $AdapterName = [string]::Format('{0} ({1})',
                    $AdapterName,
                    $ID
                );
                $StructuredInterfaceData.Add($AdapterName, @{});
            }
        }

        # Add the WMI informations to this interface
        $StructuredInterfaceData[$AdapterName].Add('NetConnectionID', $adapter.NetConnectionID);
        $StructuredInterfaceData[$AdapterName].Add('InterfaceIndex', $adapter.InterfaceIndex);
        $StructuredInterfaceData[$AdapterName].Add('NetConnectionStatus', $adapter.NetConnectionStatus);
        $StructuredInterfaceData[$AdapterName].Add('DeviceID', $adapter.DeviceID);
        $StructuredInterfaceData[$AdapterName].Add('MACAddress', $adapter.MACAddress);
        $StructuredInterfaceData[$AdapterName].Add('ServiceName', $adapter.ServiceName);
        $StructuredInterfaceData[$AdapterName].Add('Speed', $adapter.Speed);
        $StructuredInterfaceData[$AdapterName].Add('AdapterType', $adapter.AdapterType);
        $StructuredInterfaceData[$AdapterName].Add('NetworkAddresses', $adapter.NetworkAddresses);
        $StructuredInterfaceData[$AdapterName].Add('Manufacturer', $adapter.Manufacturer);
        $StructuredInterfaceData[$AdapterName].Add('PNPDeviceID', $adapter.PNPDeviceID);
        $StructuredInterfaceData[$AdapterName].Add('PhysicalAdapter', $adapter.PhysicalAdapter);
    }

    # In addition to our general network interface data, it might also
    # be helpful to have a look on the configured routing table
    $RoutingTable = Get-CimInstance -ClassName Win32_IP4RouteTable
    [array]$RoutingData = @();

    foreach ($tables in $RoutingTable) {
        $routes = @{};
        foreach($route in $tables.CimInstanceProperties) {
            $routes.Add($route.Name, $route.Value);
        }
        $RoutingData += $routes;
    }

    $NetworkData.Add('routes', $RoutingData);

    $Icinga2.Utils.Modules.AddCacheElement(
        $MyInvocation.MyCommand.Name,
        'NetworkData',
        $NetworkData
    );

    return $Icinga2.Utils.Modules.GetHashtableDiff(
        $NetworkData.Clone(),
        $CachedNetwork.Clone()
    );

    # At the end simply return the entire hashtable
    return $NetworkData;
}

return ClassNetwork -Config $Config;