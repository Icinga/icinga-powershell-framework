Import-IcingaLib icinga\enums;

function New-IcingaCheck()
{
    param(
        [string]$Name = '',
        $Value        = $null,
        $Unit         = $null
    );

    $Check = New-Object -TypeName PSObject;
    $Check | Add-Member -membertype NoteProperty -name 'name'     -value $Name;
    $Check | Add-Member -membertype NoteProperty -name 'messages' -value @();
    $Check | Add-Member -membertype NoteProperty -name 'value'    -value $Value;
    $Check | Add-Member -membertype NoteProperty -name 'exitcode' -value -1;
    $Check | Add-Member -membertype NoteProperty -name 'unit'     -value $Unit;

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfLike' -value {
        param($warning);

        if ($this.value -Like $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'like'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfNotLike' -value {
        param($warning);

        if (-Not ($this.value -Like $warning)) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'not like'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfMatch' -value {
        param($warning);

        if ($this.value -eq $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'matching'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfNotMatch' -value {
        param($warning);

        if ($this.value -ne $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'not matching'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfLowerThan' -value {
        param($warning);

        if ($this.value -lt $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'lower than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfLowerEqualThan' -value {
        param($warning);

        if ($this.value -le $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'lower or equal than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfGreaterThan' -value {
        param($warning);

        if ($this.value -gt $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'greater than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WarnIfGreaterEqualThan' -value {
        param($warning);

        if ($this.value -ge $warning) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Warning,
                $warning,
                'greater or equal than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfLike' -value {
        param($critical);

        if ($this.value -Like $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'like'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfNotLike' -value {
        param($critical);

        if (-Not ($this.value -Like $critical)) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'not like'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfMatch' -value {
        param($critical);

        if ($this.value -eq $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'matching'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfNotMatch' -value {
        param($critical);

        if ($this.value -ne $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'not matching'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfLowerThan' -value {
        param($critical);

        if ($this.value -lt $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'lower than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfLowerEqualThan' -value {
        param($critical);

        if ($this.value -le $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'lower or equal than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfGreaterThan' -value {
        param($critical);

        if ($this.value -gt $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'greater than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'CritIfGreaterEqualThan' -value {
        param($critical);

        if ($this.value -ge $critical) {
            $this.AddInternalCheckMessage(
                $IcingaEnums.IcingaExitCode.Critical,
                $critical,
                'greater or equal than'
            );
        }

        return $this;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AddInternalCheckMessage' -value {
        param($state, $value, $type);

        $this.SetExitCode($state);
        $this.AddMessage([string]::Format(
            '{0} {1}{4} is {2} {3}{4}', $this.name, $this.value, $type, $value, $this.unit
        ), $state);
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AddMessage' -value {
        param($message, $exitcode);

        $this.messages += [string]::Format(
                              '{0}: {1}',
                              $IcingaEnums.IcingaExitCodeText[$exitcode],
                              $message
                          );
    }

    $Check | Add-Member -membertype ScriptMethod -name 'SetExitCode' -value {
        param([int]$code);

        # Only overwrite the exit code in case our new value is greater then
        # the current one Ok > Warning > Critical
        if ([int]$this.exitcode -gt $code) {
            return $this;
        }

        $this.exitcode = $code;
    }

    $Check | Add-Member -membertype ScriptMethod -name 'WriteUnitError' -value {
        if ($null -ne $this.unit -And (-Not $IcingaEnums.IcingaMeasurementUnits.ContainsKey($this.unit))) {
            Write-Host (
                [string]::Format(
                    'Error: Usage of invalid plugin unit "{0}". Allowed units are: {1}',
                    $this.unit,
                    (($IcingaEnums.IcingaMeasurementUnits.Keys | Sort-Object name)  -Join ', ')
                )
            );
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'AddOkOutput' -value {
        if ([int]$this.exitcode -eq -1) {
            $this.exitcode = $IcingaEnums.IcingaExitCode.Ok;
            $this.AddMessage([string]::Format('{0} is {1}{2}', $this.name, $this.value, $this.unit), $IcingaEnums.IcingaExitCode.Ok);
        }
    }

    $Check | Add-Member -membertype ScriptMethod -name 'SilentCompile' -value {
        $this.WriteUnitError();
        $this.AddOkOutput();
    }

    $Check | Add-Member -membertype ScriptMethod -name 'Compile' -value {
        param([bool]$Verbose = $FALSE);

        if ($Verbose) {
            Write-Host ($this.messages | Out-String);
        }

        $this.WriteUnitError();
        $this.AddOkOutput();

        return $this.exitcode;
    }

    return $Check;
}
