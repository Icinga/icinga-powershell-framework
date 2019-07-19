Import-IcingaLib icinga\enums;

function New-IcingaCheckresult()
{
    param(
        $Check,
        [switch]$NoPerfData,
        [switch]$Compile
    );

    $CheckResult = New-Object -TypeName PSObject;
    $CheckResult | Add-Member -membertype NoteProperty -name 'check'      -value $Check;
    $CheckResult | Add-Member -membertype NoteProperty -name 'noperfdata' -value $NoPerfData;

    $CheckResult | Add-Member -membertype ScriptMethod -name 'Compile' -value {
        if ($this.check -eq $null) {
            return $IcingaEnums.IcingaExitCode.Unknown;
        }

        # Compile the check / package if not already done
        $this.check.Compile() | Out-Null;

        Write-Host ([string]::Format('| {0}', $this.check.GetPerfData()));

        return $this.check.exitcode;
    }

    if ($Compile) {
        return $CheckResult.Compile();
    }

    return $CheckResult;
}
