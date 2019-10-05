Import-IcingaLib icinga\enums;

function New-IcingaCheckresult()
{
    param(
        $Check,
        [bool]$NoPerfData,
        [switch]$Compile
    );

    $CheckResult = New-Object -TypeName PSObject;
    $CheckResult | Add-Member -membertype NoteProperty -name 'check'      -value $Check;
    $CheckResult | Add-Member -membertype NoteProperty -name 'noperfdata' -value $NoPerfData;

    $CheckResult | Add-Member -membertype ScriptMethod -name 'Compile' -value {
        if ($null -eq $this.check) {
            return $IcingaEnums.IcingaExitCode.Unknown;
        }

        $CheckCommand = (Get-PSCallStack)[1].Command;

        # Compile the check / package if not already done
        $this.check.AssignCheckCommand($CheckCommand);
        $this.check.Compile($TRUE) | Out-Null;

        if ([int]$this.check.exitcode -ne [int]$IcingaEnums.IcingaExitCode.Unknown -And -Not $this.noperfdata) {
            Write-IcingaPluginPerfData -PerformanceData ($this.check.GetPerfData().perfdata) -CheckCommand $CheckCommand;
        }

        return $this.check.exitcode;
    }

    if ($Compile) {
        return $CheckResult.Compile();
    }

    return $CheckResult;
}
