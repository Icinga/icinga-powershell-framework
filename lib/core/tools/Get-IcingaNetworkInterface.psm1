<#
.SYNOPSIS
   Returns interface ip address, which will be used for the host object within the icinga director.
.DESCRIPTION
   Get-IcingaNetworkInterface returns the ip address of the interface, which will be used for the host object within the icinga director.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to determine the interface ip address, during kickstart wizard, but will also function standalone.
.EXAMPLE
   PS> Get-IcingaNetworkInterface 'icinga.com'
   192.168.243.88
.EXAMPLE
   PS> Get-IcingaNetworkInterface '8.8.8.8'
   192.168.243.88
.PARAMETER IP
   Used to specify either an IPv4, IPv6 address or an FQDN.
.INPUTS
   System.String
.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Get-IcingaNetworkInterface()
{
    param(
        [string]$IP
    );

    if ([string]::IsNullOrEmpty($IP)) {
        Write-IcingaConsoleError 'Please specify a valid IP-Address or FQDN';
        return $null;
    }

    # Ensure that we can still process on older Windows system where
    # Get-NetRoute ist not available
    if ((Test-IcingaFunction 'Get-NetRoute') -eq $FALSE) {
        Write-IcingaConsoleWarning 'Your Windows system does not support "Get-NetRoute". A fallback solution is used to fetch the IP of the first Network Interface routing through 0.0.0.0'
        return (Get-IcingaNetworkRoute).Interface;
    }

    try {
        [array]$IP = ([System.Net.Dns]::GetHostAddresses($IP)).IPAddressToString;
    } catch {
        Write-IcingaConsoleError 'Invalid IP was provided!';
        return $null;
    }

    $IPBinStringMaster = ConvertTo-IcingaIPBinaryString -IP $IP;

    [hashtable]$InterfaceData = @{ };

    $InterfaceInfo = Get-NetRoute;
    $Counter = 0;

    foreach ( $Info in $InterfaceInfo ) {
        $Counter++;

        $Divide   = $Info.DestinationPrefix;
        $IP, $Mask = $Divide.Split('/');

        foreach ($destinationIP in $IPBinStringMaster) {
            [string]$Key     = '';
            [string]$MaskKey = '';
            <# IPv4 #>
            if ($destinationIP.name -eq 'IPv4') {
                if ($IP -like '*.*') {
                    if ([int]$Mask -lt 10) {
                        $MaskKey = [string]::Format('00{0}', $Mask);
                    } else {
                        $MaskKey = [string]::Format('0{0}', $Mask);
                    }
                }
            }
            <# IPv6 #>
            if ($destinationIP.name -eq 'IPv6') {
                if ($IP -like '*:*') {
                    if ([int]$Mask -lt 10) {
                        $MaskKey = [string]::Format('00{0}', $Mask);
                    } elseif ([int]$Mask -lt 100) {
                        $MaskKey = [string]::Format('0{0}', $Mask);
                    } else {
                        $MaskKey = $Mask;
                    }
                }
            }

            $Key = [string]::Format('{0}-{1}', $MaskKey, $Counter);

            if ($InterfaceData.ContainsKey($Key)) {
                continue;
            }

            $InterfaceData.Add(
                $Key, @{
                    'Binary IP String' = (ConvertTo-IcingaIPBinaryString -IP $IP).value;
                    'Mask'             = $Mask;
                    'Interface'        = $Info.ifIndex;
                }
            );
        }
    }

    $InterfaceDataOrdered = $InterfaceData.GetEnumerator() | Sort-Object -Property Name -Descending;
    $ExternalInterfaces   = @{ };

    foreach ( $Route in $InterfaceDataOrdered ) {
        foreach ($destinationIP in $IPBinStringMaster) {
            [string]$RegexPattern = [string]::Format("^.{{{0}}}", $Route.Value.Mask);
            [string]$ToBeMatched = $Route.Value."Binary IP String";
            if ($null -eq $ToBeMatched) {
                continue;
            }

            $Match1=[regex]::Matches($ToBeMatched, $RegexPattern).Value;
            $Match2=[regex]::Matches($destinationIP.Value, $RegexPattern).Value;

            If ($Match1 -like $Match2) {
                $ExternalInterface = ((Get-NetIPAddress -InterfaceIndex $Route.Value.Interface -AddressFamily $destinationIP.Name -ErrorAction SilentlyContinue).IPAddress);

                # If no interface was found -> skip this entry
                if ($null -eq $ExternalInterface) {
                    continue;
                }

                if ($ExternalInterfaces.ContainsKey($ExternalInterface)) {
                    $ExternalInterfaces[$ExternalInterface].count += 1;
                } else {
                    $ExternalInterfaces.Add(
                        $ExternalInterface,
                        @{
                            'count' = 1
                        }
                    );
                }
            }
        }
    }

    if ($ExternalInterfaces.Count -eq 0) {
        foreach ($destinationIP in $IPBinStringMaster) {
            $ExternalInterface = ((Get-NetIPAddress -InterfaceIndex (Get-NetRoute | Where-Object -Property DestinationPrefix -Like '0.0.0.0/0')[0].IfIndex -AddressFamily $destinationIP.name).IPAddress).split('%')[0];
            if ($ExternalInterfaces.ContainsKey($ExternalInterface)) {
                $ExternalInterfaces[$ExternalInterface].count += 1;
            } else {
                $ExternalInterfaces.Add(
                    $ExternalInterface,
                    @{
                        'count' = 1
                    }
                );
            }
        }
    }

    $InternalCount        = 0;
    [array]$UseInterface  = @();
    foreach ($interface in $ExternalInterfaces.Keys) {
        $currentCount = $ExternalInterfaces[$interface].count;
        if ($currentCount -gt $InternalCount) {
            $InternalCount = $currentCount;
            $UseInterface += $interface;
        }
    }

    # In case we found multiple interfaces, fallback to our
    # 'route print' function and return this interface instead
    if ($UseInterface.Count -ne 1) {
        return (Get-IcingaNetworkRoute).Interface;
    }

    return $UseInterface[0];
}
