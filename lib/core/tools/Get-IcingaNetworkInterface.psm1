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

    try {
        $IP = ([System.Net.Dns]::GetHostAddresses($IP)).IPAddressToString;
    } catch {
        Write-Host 'Invalid IP was provided!';
        return $null;
    }

    $IPBinStringMaster = ConvertTo-IcingaIPBinaryString -IP $IP;

    [hashtable]$InterfaceData=@{};

    $InterfaceInfo = Get-NetRoute;
    $Counter = 0;

    foreach ( $Info in $InterfaceInfo ) {
        $Counter++;

        $Divide = $Info.DestinationPrefix;
        $IP,$Mask = $Divide.Split('/');

############################################################################
################################  IPv4  ####################################
############################################################################
        if ($IPBinStringMaster.name -eq 'IPv4') {
            if ($IP -like '*.*') {
############################################################################
                if ([int]$Mask -lt 10) {
                    [string]$MaskKey = [string]::Format('00{0}', $Mask);
                } else {
                    [string]$MaskKey = [string]::Format('0{0}', $Mask);
                }

                [string]$Key = [string]::Format('{0}-{1}', $MaskKey, $Counter);

                $InterfaceData.Add(
                    $Key, @{
                        'Binary IP String' = (ConvertTo-IcingaIPBinaryString -IP $IP).value;
                        'Mask' = $Mask;
                        'Interface' = $Info.ifIndex;
                    }
                );
############################################################################
            }
        }
############################################################################
################################  IPv4  ####################################
############################################################################
        if ($IPBinStringMaster.name -eq 'IPv6') {
            if ($IP -like '*:*') {
############################################################################
                if ([int]$Mask -lt 10) {
                    [string]$MaskKey = [string]::Format('00{0}', $Mask);
                } elseif ([int]$Mask -lt 100) {
                    [string]$MaskKey = [string]::Format('0{0}', $Mask);
                } else {
                    [string]$MaskKey = $Mask;
                }

                [string]$Key = [string]::Format('{0}-{1}', $MaskKey, $Counter);

                $InterfaceData.Add(
                    $Key, @{
                        'Binary IP String' = (ConvertTo-IcingaIPBinaryString -IP $IP);
                        'Mask' = $Mask;
                        'Interface' = $Info.ifIndex;
                    }
                );
############################################################################
            }
        }
    }

    $InterfaceDataOrdered = $InterfaceData.GetEnumerator() | Sort-Object -Property Name -Descending;

    foreach ( $Route in $InterfaceDataOrdered ) {
        [string]$RegexPattern = [string]::Format("^.{{{0}}}", $Route.Value.Mask);
        [string]$ToBeMatched = $Route.Value."Binary IP String";
        $Match1=[regex]::Matches($ToBeMatched, $RegexPattern).Value;
        $Match2=[regex]::Matches($IPBinStringMaster.Value, $RegexPattern).Value;

        If ($Match1 -like $Match2) {
            return ((Get-NetIPAddress -InterfaceIndex $Route.Value.Interface -AddressFamily $IPBinStringMaster.name).IPAddress);
        }
    }
    return  ((Get-NetIPAddress -InterfaceIndex (Get-NetRoute | Where-Object -Property DestinationPrefix -like '0.0.0.0/0')[0].IfIndex -AddressFamily $IPBinStringMaster.name).IPAddress).split('%')[0];
}