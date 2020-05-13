function Get-IcingaFirewallConfig()
{
    param(
        [switch]$NoOutput
    );

    [bool]$LegacyFirewallPresent = $FALSE;
    [bool]$IcingaFirewallPresent = $FALSE;

    $LegacyFirewall = Start-IcingaProcess -Executable 'netsh' -Arguments 'advfirewall firewall show rule name="Icinga 2 Agent Inbound by PS-Module"';

    if ($LegacyFirewall.ExitCode -eq 0) {
        if ($NoOutput -eq $FALSE) {
            Write-IcingaConsoleWarning 'Legacy firewall configuration has been detected.';
        }
        $LegacyFirewallPresent = $TRUE;
    }

    $IcingaFirewall = Start-IcingaProcess -Executable 'netsh' -Arguments 'advfirewall firewall show rule name="Icinga Agent Inbound"';

    if ($IcingaFirewall.ExitCode -eq 0) {
        if ($NoOutput -eq $FALSE) {
            Write-IcingaConsoleNotice 'Icinga firewall is present.';
        }
        $IcingaFirewallPresent = $TRUE;
    } else {
        if ($NoOutput -eq $FALSE) {
            Write-IcingaConsoleError 'Icinga firewall is not present';
        }
    }

    return @{
        'LegacyFirewall' = $LegacyFirewallPresent;
        'IcingaFirewall' = $IcingaFirewallPresent;
    }
}
