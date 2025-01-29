function New-IcingaCheckBaseObject()
{
    $IcingaCheckBaseObject = New-Object -TypeName PSObject;

    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name 'Name'             -Value '';
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name 'Verbose'          -Value 0;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__Hidden'         -Value $FALSE;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__SkipSummary'    -Value $FALSE;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__Parent'         -Value $IcingaCheckBaseObject;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__Indention'      -Value 0;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__ErrorMessage'   -Value '';
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__CheckState'     -Value $IcingaEnums.IcingaExitCode.Ok;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__CheckCommand'   -Value '';
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__CheckOutput'    -Value $null;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__ObjectType'     -Value 'IcingaCheckBaseObject';

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetCheckCommand' -Value {
        $CallStack = Get-PSCallStack;

        foreach ($entry in $CallStack) {
            [string]$CheckCommand = $entry.Command;
            if ($CheckCommand.ToLower() -Like 'invoke-icingacheck*') {
                $this.__CheckCommand                          = $CheckCommand;
                $Global:Icinga.Private.Scheduler.CheckCommand = $CheckCommand;
                break;
            }
        }

        if ([string]::IsNullOrEmpty($this.__CheckCommand)) {
            return;
        }

        if ($Global:Icinga.Private.Scheduler.ThresholdCache.ContainsKey($this.__CheckCommand) -eq $FALSE) {
            $Global:Icinga.Private.Scheduler.ThresholdCache.Add($this.__CheckCommand, $null);
        }

        if ($null -ne $Global:Icinga.Private.Scheduler.ThresholdCache[$this.__CheckCommand]) {
            return;
        }

        if ($Global:Icinga.Public.Daemons.ContainsKey('ServiceCheck') -And $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache.ContainsKey($this.__CheckCommand) -And $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache[$CheckCommand].Count -ne 0) {
            $Global:Icinga.Private.Scheduler.ThresholdCache[$this.__CheckCommand] = $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache[$CheckCommand];
        } else {
            # Fallback in case the service is not registered within the daemon or we are running a plugin from without the daemon environment
            $Global:Icinga.Private.Scheduler.ThresholdCache[$this.__CheckCommand] = (Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult' -KeyName $this.__CheckCommand);
        }
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetParent' -Value {
        param ($Parent);

        $this.__Parent = $Parent;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetParent' -Value {
        return $this.__Parent;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__IsHidden' -Value {
        return $this.__Hidden;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetHidden' -Value {
        param ([bool]$Hidden);

        $this.__Hidden = $Hidden;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__NoHeaderReport' -Value {
        return $this.__SkipSummary;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetNoHeaderReport' -Value {
        param ([bool]$SkipSummary);

        $this.__SkipSummary = $SkipSummary;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetName' -Value {
        return $this.Name;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetIndention' -Value {
        param ($Indention);

        $this.__Indention = $Indention;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetIndention' -Value {
        return $this.__Indention;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__NewIndention' -Value {
        return ($this.__Indention + 1);
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetCheckState' -Value {
        return $this.__CheckState;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetCheckCommand' -Value {
        return $this.__CheckCommand;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Force -Name '__SetCheckOutput' -Value {
        param ($PluginOutput);
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetCheckOutput' -Value {

        if ($this.__IsHidden()) {
            return ''
        };

        if ($this._CanOutput() -eq $FALSE) {
            return '';
        }

        return (
            [string]::Format(
                '{0}{1}',
                (New-StringTree -Spacing $this.__GetIndention()),
                $this.__CheckOutput
            )
        );
    }

    # Shared function
    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name 'Compile' -Value {
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetVerbosity' -Value {
        param ($Verbosity);

        $this.Verbose = $Verbosity;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetVerbosity' -Value {
        return $this.Verbose;
    }

    # Shared function
    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetHeaderOutputValue' -Value {
        return '';
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '_CanOutput' -Value {
        # Always allow the output of the top parent elements
        if ($this.__GetIndention() -eq 0) {
            return $TRUE;
        }

        switch ($this.Verbose) {
            0 { # Only print states not being OK
                if ($this.__CheckState -ne $IcingaEnums.IcingaExitCode.Ok) {
                    return $TRUE;
                }

                if ($this.__ObjectType -eq 'IcingaCheckPackage') {
                    return $this.__HasNotOkChecks();
                }

                return $FALSE;
            };
            1 { # Print states not being OK and all content of affected check packages
                if ($this.__CheckState -ne $IcingaEnums.IcingaExitCode.Ok) {
                    return $TRUE;
                }

                if ($this.__ObjectType -eq 'IcingaCheckPackage') {
                    return $this.__HasNotOkChecks();
                }

                if ($this.__GetParent().__ObjectType -eq 'IcingaCheckPackage') {
                    return $this.__GetParent().__HasNotOkChecks();
                }

                return $FALSE;
            };
        }

        # For any other verbosity, print everything
        return $TRUE;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__ValidateThresholdInput' -Value {
        # Shared function
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name 'HasChecks' -Value {
        # Shared function
    }

    $IcingaCheckBaseObject.__SetCheckCommand();

    return $IcingaCheckBaseObject;
}
