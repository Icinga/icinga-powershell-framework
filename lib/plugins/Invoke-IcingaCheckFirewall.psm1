<#
.SYNOPSIS
   Checks whether a firewall module is enabled or not
.DESCRIPTION
   Invoke-IcingaCheckFirewall returns either 'OK' or 'CRITICAL', whether the check matches or not.

   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to be used to check the status of a firewall profile.
   Based on the match result the status will change between 'OK' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS> Invoke-IcingaCheckFirewall -Profile "Domain" -Verbosity 3
   [OK] Check package "Firewall profiles" (Match All)
   \_ [OK] Firewall Profile Domain is True
   | 'firewall_profile_domain'=True;; 
   0
.EXAMPLE
   PS> Invoke-IcingaCheckFirewall -Profile "Domain", "Private" -Verbosity 1}
   [OK] Check package "Firewall profiles" (Match All)
   | 'firewall_profile_domain'=True;; 'firewall_profile_private'=True;; 
   0
        [array]$Profile,
        [bool]$Status     = $TRUE,
.PARAMETER Profile
   Used to specify an array of profiles to check.

.PARAMETER Status
   Used to specify a bool value, which determines, whether the firewall profiles should be enabled or disabled.

   -Status $TRUE
   translates to enabled, while
   -Status $FALSE
   translates to disabled.
.INPUTS
   System.String

.OUTPUTS
   System.String

.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckFirewall()
{
    param(
        [array]$Profile,
        [bool]$Status     = $TRUE,
        [switch]$NoPerfData,
        [int]$Verbosity     = 0
    );

    if ($Status -eq $TRUE) {
        $StatusString = "true"
    } else {
        $StatusString = "false"
    }

    $FirewallPackage = New-IcingaCheckPackage -Name 'Firewall profiles' -OperatorAnd -Verbos $Verbosity;

    foreach ($singleprofile in $Profile) {
        $FirewallData = (Get-NetFirewallProfile -Name $singleprofile)

        $FirewallCheck = New-IcingaCheck -Name "Firewall Profile $singleprofile" -Value $FirewallData.Enabled;
        $FirewallCheck.CritIfNotMatch($StatusString) | Out-Null;
    
    $FirewallPackage.AddCheck($FirewallCheck)
    }


    return (New-IcingaCheckResult -Check $FirewallPackage -NoPerfData $NoPerfData -Compile);
}