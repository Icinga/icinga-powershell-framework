function Enable-IcingaFirewall()
{
    param(
        [int]$IcingaPort = 5665,
        [switch]$Force
    );

    $FirewallConfig = Get-IcingaFirewallConfig -NoOutput;

    if ($FirewallConfig.IcingaFirewall -And $Force -eq $FALSE) {
        Write-IcingaConsoleNotice 'Icinga Firewall is already enabled'
        return;
    }

    if ($Force) {
        Disable-IcingaFirewall;
    }

    $IcingaBinary         = Get-IcingaAgentBinary;
    [string]$FirewallRule = [string]::Format(
        'advfirewall firewall add rule dir=in action=allow program="{0}" name="{1}" description="{2}" enable=yes remoteip=any localip=any localport={3} protocol=tcp',
        $IcingaBinary,
        'Icinga Agent Inbound',
        'Inbound Firewall Rule to allow Icinga 2 masters / satellites to connect to the Icinga 2 Agent installed on this system.',
        $IcingaPort
    );
    
    $FirewallResult = Start-IcingaProcess -Executable 'netsh' -Arguments $FirewallRule;

    if ($FirewallResult.ExitCode -ne 0) {
        Write-IcingaConsoleError ([string]::Format('Failed to open Icinga firewall for port "{0}": {1}[2}', $IcingaPort, $FirewallResult.Message, $FirewallResult.Error));
    } else {
        Write-IcingaConsoleNotice ([string]::Format('Successfully enabled firewall for port "{0}"', $IcingaPort));
    }
}
