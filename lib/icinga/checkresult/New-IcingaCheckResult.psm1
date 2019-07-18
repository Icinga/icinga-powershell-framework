Import-IcingaLib icinga\enums;

function New-IcingaCheckresult()
{
    $CheckResult = New-Object -TypeName PSObject;
    $CheckResult | Add-Member -membertype NoteProperty -name 'HasResult'     -value $FALSE;
    $CheckResult | Add-Member -membertype NoteProperty -name 'ExitCode'      -value -1;
    $CheckResult | Add-Member -membertype NoteProperty -name 'OutputMessage' -value @();
    $CheckResult | Add-Member -membertype NoteProperty -name 'PerfData'      -value @();

    $CheckResult | Add-Member -membertype ScriptMethod -name 'Matches' -value {
        param($match, $value, $message, [bool]$negate = $FALSE);

        [string]$phrase = 'IS';
        [int]$exitcode = $IcingaEnums.IcingaExitCode.Unknown;

        if ($negate) {
            if ($value -ne $match) {
                $phrase = 'IS';
                $exitcode = $IcingaEnums.IcingaExitCode.Ok;
            } else {
                $phrase = 'is NOT';
                $exitcode = $IcingaEnums.IcingaExitCode.Critical;
            }
        } else {
            if ($value -ne $match) {
                $phrase = 'is NOT';
                $exitcode = $IcingaEnums.IcingaExitCode.Critical;
            } else {
                $phrase = 'IS';
                $exitcode = $IcingaEnums.IcingaExitCode.Ok;
            }
        }

        $message = [string]::Format('{0} (Input value "{1}" {3} matching "{2}")', $message, $value, $match, $phrase);
        $this.SetExitCode($exitcode);
        $this.AddOutputMessage($message, $exitcode);
    }

    $CheckResult | Add-Member -membertype ScriptMethod -name 'Lower' -value {
        param($warning, $critical, $value, $message);

        [int]$exitcode = $IcingaEnums.IcingaExitCode.Unknown;

        if ($value -ge $critical) {
            $exitcode = $IcingaEnums.IcingaExitCode.Critical;
        } elseif ($value -ge $warning) {
            $exitcode = $IcingaEnums.IcingaExitCode.Warning;
        } else {
            $exitcode = $IcingaEnums.IcingaExitCode.Ok;
        }

        $this.SetExitCode($exitcode);
        $this.AddOutputMessage($message, $exitcode);
    }

    $CheckResult | Add-Member -membertype ScriptMethod -name 'LowerEqual' -value {
        param($warning, $critical, $value, $message);

        [int]$exitcode = $IcingaEnums.IcingaExitCode.Unknown;

        if ($value -gt $critical) {
            $exitcode = $IcingaEnums.IcingaExitCode.Critical;
        } elseif ($value -gt $warning) {
            $exitcode = $IcingaEnums.IcingaExitCode.Warning;
        } else {
            $exitcode = $IcingaEnums.IcingaExitCode.Ok;
        }

        $this.SetExitCode($exitcode);
        $this.AddOutputMessage($message, $exitcode);
    }

    $CheckResult | Add-Member -membertype ScriptMethod -name 'Greater' -value {
        param($warning, $critical, $value, $message);

        [int]$exitcode = $IcingaEnums.IcingaExitCode.Unknown;

        if ($value -le $critical) {
            $exitcode = $IcingaEnums.IcingaExitCode.Critical;
        } elseif ($value -le $warning) {
            $exitcode = $IcingaEnums.IcingaExitCode.Warning;
        } else {
            $exitcode = $IcingaEnums.IcingaExitCode.Ok;
        }

        $this.SetExitCode($exitcode);
        $this.AddOutputMessage($message, $exitcode);
    }

    $CheckResult | Add-Member -membertype ScriptMethod -name 'GreaterEqual' -value {
        param($warning, $critical, $value, $message);

        [int]$exitcode = $IcingaEnums.IcingaExitCode.Unknown;

        if ($value -lt $critical) {
            $exitcode = $IcingaEnums.IcingaExitCode.Critical;
        } elseif ($value -lt $warning) {
            $exitcode = $IcingaEnums.IcingaExitCode.Warning;
        } else {
            $exitcode = $IcingaEnums.IcingaExitCode.Ok;
        }

        $this.SetExitCode($exitcode);
        $this.AddOutputMessage($message, $exitcode);
    }

    $CheckResult | Add-Member -membertype ScriptMethod -name 'SetExitCode' -value {
        param($exitcode);

        # Only overwrite the exit code in case our new value is greater then
        # the current one Ok > Warning > Critical
        if ($this.ExitCode -gt $exitcode) {
            return;
        }

        $this.ExitCode = $exitcode;
    }

    $CheckResult | Add-Member -membertype ScriptMethod -name 'AddOutputMessage' -value {
        param($exitcode, $message);

        $this.OutputMessage.Add(
            [string]::Format(
                '{0}: {1}',
                $IcingaEnums.IcingaExitCodeText[$exitcode],
                $message
            )
        )
    }
}
