$Checker = New-Object -TypeName PSObject;

$Checker | Add-Member -membertype NoteProperty -name 'os'          -value '';
$Checker | Add-Member -membertype NoteProperty -name 'version'     -value '';
$Checker | Add-Member -membertype NoteProperty -name 'fqdn'        -value '';
$Checker | Add-Member -membertype NoteProperty -name 'bind'        -value 'wdt';
$Checker | Add-Member -membertype NoteProperty -name 'time_offset' -value 0;

$Checker | Add-Member -membertype ScriptMethod -name 'Start' -value {

    $Icinga2.PidManager.StopProcessByBind($this.bind);

    Start-Sleep 1;

    $Icinga2.PidManager.CreatePidFile($this.bind);

    $WindowsInformations = Get-CimInstance Win32_OperatingSystem;
    $this.version        = $WindowsInformations.CimInstanceProperties['Version'].Value;
    $this.os             = $WindowsInformations.CimInstanceProperties['Caption'].Value;
    $this.fqdn           = [System.Net.Dns]::GetHostEntry('localhost').HostName;

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Starting checker component of module.'
    );

    $Icinga2.ClientProtocol.setFQDN($this.fqdn);
    $Icinga2.Cache.Checker.ModuleScheduler = @{ };

    while($true) {

        $StopWatchHandler =  [System.Diagnostics.StopWatch]::StartNew()
        $this.ScheduleWindowsHello($FALSE);
        $this.UpdateModuleTimer();
        $Icinga2.ClientJobs.ParseJobResults();
        
        # This part will help us to keep the gap between module execution as low as possible
        # We will check how many seconds have been passed while the modules were executed
        # This value will then be added to our module timings, ensuring that in general
        # they will become executed right on time
        $StopWatchHandler.Stop();
        $this.time_offset = [math]::Round($StopWatchHandler.Elapsed.TotalSeconds, 0);
        $Icinga2.ClientJobs.AddTicks($this.time_offset);

        Start-Sleep -Seconds 1;
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Stopping checker component of module.'
    );
}

$Checker | Add-Member -membertype ScriptMethod -name 'UpdateModuleTimer' -value {
    if ($Icinga2.Cache.Checker.ModuleConfig -eq $null) {
        return;
    }

    foreach ($module in $Icinga2.Cache.Checker.ModuleConfig.Keys) {
        if ($Icinga2.Cache.Checker.ModuleScheduler.ContainsKey($module) -eq $FALSE) {
            $Icinga2.Cache.Checker.ModuleScheduler.Add($module, 0);
        } else {
            $Icinga2.Cache.Checker.ModuleScheduler[$module] += (1 + $this.time_offset);

            if ($Icinga2.Cache.Checker.ModuleScheduler[$module] -ge $Icinga2.Cache.Checker.ModuleConfig[$module]) {
                $Icinga2.Cache.Checker.ModuleScheduler[$module] = 0;
                $this.ScheduleModuleJob($module);
            }
        }
    }
    $this.time_offset = 0;
}

$Checker | Add-Member -membertype ScriptMethod -name 'ScheduleModuleJob' -value {
    param([string]$module);

    $Icinga2.ClientJobs.ScheduleJob($module);
}

$Checker | Add-Member -membertype ScriptMethod -name 'ScheduleWindowsHello' -value {
    param([bool]$force);
    $this.WriteLogOutput($Icinga2.ClientJobs.WindowsHello(
        $this.os,
        $this.fqdn,
        $this.version,
        $force
    ));
}

$Checker | Add-Member -membertype ScriptMethod -name 'WriteLogOutput' -value {
    param($response);

    if ($response -ne $null) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Debug,
            $response
        );
    }
}

$Checker | Add-Member -membertype ScriptMethod -name 'Stop' -value {
    $Icinga2.PidManager.StopProcessByBind($this.bind);
}

return $Checker;