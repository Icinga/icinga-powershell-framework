param(
    [string]$AddKey       = '',
    [Object]$AddValue     = '',
    [string]$GetConfig    = '',
    [string]$RemoveConfig = '',
    [boolean]$ListConfig  = $FALSE,
    [boolean]$Reload      = $FALSE
);

function ClassConfig()
{
    param(
        [string]$AddKey       = '',
        [Object]$AddValue     = '',
        [string]$GetConfig    = '',
        [string]$RemoveConfig = '',
        [boolean]$ListConfig  = $FALSE,
        [boolean]$Reload      = $FALSE
    );

    $instance = New-Object -TypeName PSObject;

    $instance | Add-Member -membertype NoteProperty -name 'ConfigDirectory' -value (Join-Path $Icinga2.App.RootPath     -ChildPath 'agent\config');
    $instance | Add-Member -membertype NoteProperty -name 'ConfigFile'      -value (Join-Path $instance.ConfigDirectory -ChildPath 'config.conf');

    $instance | Add-Member -membertype ScriptMethod -name 'Init' -value {
        if ($ListConfig) {
            return $this.DumpConfig();
        }

        if ($Reload) {
            return $this.ReloadConfig();
        }

        if ([string]::IsNullOrEmpty($GetConfig) -eq $FALSE) {
            return $this.GetAttribute();
        }

        if ([string]::IsNullOrEmpty($AddKey) -eq $FALSE) {
            return $this.SetAttribute();
        }

        if ([string]::IsNullOrEmpty($RemoveConfig) -eq $FALSE) {
            return $this.RemoveAttribute();
        }

        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            '{ Invalid or insufficient arguments specified. }'
        );
        return 1;
    }

    $instance | Add-Member -membertype ScriptMethod -name 'ReloadConfig' -value {
        $Icinga2.Config = & (Join-Path $Icinga2.App.RootPath -ChildPath '\core\include\Config.ps1');
    }

    $instance | Add-Member -membertype ScriptMethod -name 'WriteConfig' -value {
        If ((Test-Path ($this.ConfigDirectory)) -eq $FALSE) {
            $Icinga2.Log.WriteConsole(
                $Icinga2.Enums.LogState.Warning,
                'Config Directory is not present. Please run "Icinga-Setup" for the base installation'
            );
            return 1;
        }
        $config = ConvertTo-Json $Icinga2.Config -Depth 100;
        [System.IO.File]::WriteAllText($this.ConfigFile, $config);
        return 0;
    }

    $instance | Add-Member -membertype ScriptMethod -name 'DumpConfig' -value {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            ([string]::Format('Config location: {0}', $this.ConfigFile))
        );
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            $Icinga2.Config
        );
        return 0;
    }

    $instance | Add-Member -membertype ScriptMethod -name 'GetAttribute' -value {
        return $Icinga2.Config.$GetConfig;
    }

    $instance | Add-Member -membertype ScriptMethod -name 'SetAttribute' -value {
        $value = $AddValue;

        if ([string]::IsNullOrEmpty($AddValue)) {
            $value = $null;
        }

        if ([bool]($Icinga2.Config.PSobject.Properties.Name -eq $AddKey) -eq $FALSE) {
            $Icinga2.Config | Add-Member -membertype NoteProperty -name $AddKey -value $value;
        } else {
            $Icinga2.Config.$AddKey = $value;
        }

        if ($this.WriteConfig() -eq 0) {
            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Info,
                ([string]::Format('{0} Set config attribute "{1}" to "{2}. {3}', '{', $AddKey, $value, '}'))
            );
            return 0;
        }

        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            ([string]::Format('{0} Unable to write config file to disk. Failed to update attribute "{1}" to "{2}. {3}', '{', $AddKey, $value, '}'))
        );
        return 1;
    }

    $instance | Add-Member -membertype ScriptMethod -name 'RemoveAttribute' -value {
        if ([bool]($Icinga2.Config.PSobject.Properties.Name -eq $RemoveConfig) -eq $TRUE) {
            $Icinga2.Config.PSobject.Members.Remove($RemoveConfig);
            if ($this.WriteConfig() -eq 0) {
                $Icinga2.Log.Write(
                    $Icinga2.Enums.LogState.Info,
                    ([string]::Format('{0} Successfully removed config attribute "{1}" {2}', '{', $RemoveConfig, '}'))
                );
                return 0;
            }
            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Error,
                ([string]::Format('{0} Config attribute "{1}" was removed, but storing the new config file failed. {2}', '{', $RemoveConfig, '}'))
            );
            return 1;
        }

        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            ([string]::Format('{0} Unable to remove attribute "{1}". Attribute not found {2}', '{', $RemoveConfig, '}'))
        );
        return 1;
    }

    return $instance.Init();
}

return ClassConfig -AddKey $AddKey -AddValue $AddValue -GetConfig $GetConfig -RemoveConfig $RemoveConfig -ListConfig $ListConfig -Reload $Reload;