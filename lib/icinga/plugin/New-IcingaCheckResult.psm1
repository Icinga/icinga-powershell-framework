function New-IcingaCheckResult()
{
    param (
        $Check,
        [bool]$NoPerfData = $FALSE,
        [switch]$Compile  = $FALSE
    );

    $IcingaCheckResult = New-Object -TypeName PSObject;
    $IcingaCheckResult | Add-Member -MemberType NoteProperty -Name 'Check'      -Value $Check;
    $IcingaCheckResult | Add-Member -MemberType NoteProperty -Name 'NoPerfData' -Value $NoPerfData;

    $IcingaCheckResult | Add-Member -MemberType ScriptMethod -Name 'Compile' -Value {
        # Always ensure our cache is cleared before compiling new check data
        Get-IcingaCheckSchedulerPluginOutput | Out-Null;
        Get-IcingaCheckSchedulerPerfData | Out-Null;

        if ($null -eq $this.Check) {
            return $IcingaEnums.IcingaExitCode.Unknown;
        }

        # Compile the check / package if not already done
        $this.Check.Compile();

        Write-IcingaPluginOutput -Output ($this.Check.__GetCheckOutput());

        if ($this.NoPerfData -eq $FALSE) {
            Write-IcingaPluginPerfData -IcingaCheck $this.Check;
        }

        # Ensure we reset our internal cache once the plugin was executed
        $CheckCommand = $this.Check.__GetCheckCommand();
        if ([string]::IsNullOrEmpty($CheckCommand) -eq $FALSE -And $Global:Icinga.Private.Scheduler.ThresholdCache.ContainsKey($CheckCommand)) {
            $Global:Icinga.Private.Scheduler.ThresholdCache[$CheckCommand] = $null;
        }
        # Reset the current execution date
        $Global:Icinga.CurrentDate = $null;

        $ExitCode = $this.Check.__GetCheckState();

        Set-IcingaInternalPluginExitCode -ExitCode $ExitCode;

        return $ExitCode;
    }

    if ($Compile) {
        return $IcingaCheckResult.Compile();
    }

    return $IcingaCheckResult;
}
