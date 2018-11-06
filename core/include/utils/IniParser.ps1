<#
 # Helper class allowing to read INI files basicly
 # and return the content as Hashtable
 #>

$IniParser = New-Object -TypeName PSObject;

$IniParser | Add-Member -membertype ScriptMethod -name 'LoadFromArray' -value {
    param([array]$content, [bool]$CutLastSpace);

    [hashtable]$IniContent = @{};
    [string]$IniKey        = '';
    [string]$SubIniKey     = '';

    # First, loop all lines of our NTP config
    foreach ($item in $content) {
        # At first we require to parse the section argument for the config
        if ($item.Contains('[')) {
            $IniKey = $item.Replace('[', '').Replace(']', '');
            $IniContent.Add($IniKey, @{ });
            continue;
        }

        if ([string]::IsNullOrEmpty($item) -eq $TRUE) {
            continue;
        }

        # In case our entry does not contain ':', we are not loading a config entry
        if ($item.Contains(':') -eq $FALSE) {
            $SubIniKey = $item;
            $IniContent[$IniKey].Add($SubIniKey, @{ });
            continue;
        }

        # Now as we found an config entry point, split the result at first to get
        # the key of our config. Afterwards we load the value by removing all
        # spaces before the actual value
        [array]$ConfigData = $item.Split(':');
        [string]$ConfigKey = $ConfigData[0];
        [string]$ConfigValue = $item.Substring($item.IndexOf(':') + 1, $item.Length - $item.IndexOf(':') - 1);

        # Some INI files (like NTP) add additional details behind the values if they
        # are configured by Local or Remote for example. With this we can cut these
        # informations out, idependently from our configured OS language
        if ($CutLastSpace -eq $TRUE) {
            $ConfigValue = $ConfigValue.Substring(0, $ConfigValue.LastIndexOf(' '));
        }

        while ($ConfigValue[0] -eq ' ') {
            $ConfigValue = $ConfigValue.Substring(1, $ConfigValue.Length - 1);
        }

        # It could happen that within a section keys are being overwritten again
        # We should take care of this and update a possible added key with the
        # next configured values to receive only the correct configuration as result
        # as it is interpreted by the time service
        if ([string]::IsNullOrEmpty($SubIniKey) -eq $TRUE) {
            if ($IniContent[$IniKey].ContainsKey($ConfigKey) -eq $FALSE) {
                $IniContent[$IniKey].Add($ConfigKey, $ConfigValue);
            } else {
                $IniContent[$IniKey][$ConfigKey] = $ConfigValue;
            }
        } else {
            if ($IniContent[$IniKey][$SubIniKey].ContainsKey($ConfigKey) -eq $FALSE) {
                $IniContent[$IniKey][$SubIniKey].Add($ConfigKey, $ConfigValue);
            } else {
                $IniContent[$IniKey][$SubIniKey][$ConfigKey] = $ConfigValue;
            }
        }
    }

    return $IniContent;
}

return $IniParser;