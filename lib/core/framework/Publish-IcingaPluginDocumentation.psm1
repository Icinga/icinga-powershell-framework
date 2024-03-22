function Publish-IcingaPluginDocumentation()
{
    param (
        [string]$ModulePath
    );

    if ([string]::IsNullOrEmpty($ModulePath) -Or (Test-Path $ModulePath) -eq $FALSE) {
        Write-IcingaConsoleError -Message 'Either your provided path "{0}" is empty or does not exist' -Objects $ModulePath;
        return;
    }

    [string]$PluginDir     = Join-Path -Path $ModulePath -ChildPath 'plugins';
    [string]$DocDir        = Join-Path -Path $ModulePath -ChildPath 'doc';
    [string]$PluginDocFile = Join-Path -Path $ModulePath -ChildPath 'doc/10-Icinga-Plugins.md';
    [string]$PluginDocDir  = Join-Path -Path $ModulePath -ChildPath 'doc/plugins';

    New-IcingaDocumentObject -Name 'Plugins Base' -Path $PluginDocFile;

    if ((Test-Path $PluginDocDir) -eq $FALSE) {
        New-Item -Path $PluginDocDir -ItemType Directory -Force | Out-Null;
    }

    $MDFiles               = Get-ChildItem -Path $PluginDocDir;
    [int]$FileCount        = $MDFiles.Count;
    [string]$FileCountStr  = '';

    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '# Icinga Plugins';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content 'Below you will find a documentation for every single available plugin provided by this repository. Most of the plugins allow the usage of default Icinga threshold range handling, which is defined as follows:';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| Argument | Throws error on | Ok range                     |';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| ---      | ---             | ---                          |';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| 20       | < 0 or > 20     | 0 .. 20                      |';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| 20:      | < 20            | between 20 .. ∞              |';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| ~:20     | > 20            | between -∞ .. 20             |';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| 30:40    | < 30 or > 40    | between {30 .. 40}           |';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| `@30:40  | ≥ 30 and ≤ 40   | outside -∞ .. 29 and 41 .. ∞ |';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content 'Please ensure that you will escape the `@` if you are configuring it on the Icinga side. To do so, you will simply have to write an *\`* before the `@` symbol: \``@`';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content 'To test thresholds with different input values, you can use the Framework Cmdlet `Get-IcingaHelpThresholds`.';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content 'Each plugin ships with a constant Framework argument `-ThresholdInterval`. This can be used to modify the value your thresholds are compared against from the current, fetched value to one collected over time by the Icinga for Windows daemon. In case you [Collect Metrics Over Time](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/) for specific time intervals, you can for example set the argument to `15m` to get the average value of 15m as base for your monitoring values. Please note that in this example, you will require to have collected the `15m` average for `Invoke-IcingaCheckCPU`.';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '```powershell';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content 'icinga> icinga { Invoke-IcingaCheckCPU -Warning 20 -Critical 40 -Core _Total -ThresholdInterval 15m }'
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content ''
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '[WARNING] CPU Load: [WARNING] Core Total (29,14817700%)'
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '\_ [WARNING] Core Total: 29,14817700% is greater than threshold 20% (15m avg.)';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content "| 'core_total_1'=31.545677%;;;0;100 'core_total_15'=29.148177%;20;40;0;100 'core_total_5'=28.827410%;;;0;100 'core_total_20'=30.032942%;;;0;100 'core_total_3'=27.731669%;;;0;100 'core_total'=33.87817%;;;0;100";
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '```';
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content ''
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| Plugin Name | Description |'
    Add-IcingaDocumentContent -Name 'Plugins Base' -Content '| ---         | --- |'

    $AvailablePlugins = Get-ChildItem -Path $PluginDir -Recurse -Filter *.psm1;
    foreach ($plugin in $AvailablePlugins) {
        [string]$PluginName     = $plugin.Name.Replace('.psm1', '');
        [string]$PluginDocName  = '';
        [string]$PluginSynopsis = '-';
        $PluginDetails          = Get-Help -Name $PluginName -Full;

        if ($null -ne $PluginDetails -And [string]::IsNullOrEmpty($PluginDetails.Synopsis) -eq $FALSE) {
            $PluginSynopsis = $PluginDetails.Synopsis.Replace("`r`n", ' ');
            $PluginSynopsis = $PluginSynopsis.Replace("`r", ' ');
            $PluginSynopsis = $PluginSynopsis.Replace("`n", ' ');
        }

        foreach ($DocFile in $MDFiles) {
            $DocFileName = $DocFile.Name;
            if ($DocFileName -Like "*$PluginName.md") {
                $PluginDocName = $DocFile.Name;
                break;
            }
        }

        if ([string]::IsNullOrEmpty($PluginDocName)) {
            $FileCount += 1;
            if ($FileCount -lt 10) {
                $FileCountStr = [string]::Format('0{0}', $FileCount);
            } else {
                $FileCountStr = $FileCount;
            }

            $PluginDocName = [string]::Format('{0}-{1}.md', $FileCountStr, $PluginName);
        }
        [string]$PluginDescriptionFile = Join-Path -Path $PluginDocDir -ChildPath $PluginDocName;

        New-IcingaDocumentObject -Name $PluginName -Path $PluginDescriptionFile;

        Add-IcingaDocumentContent -Name 'Plugins Base' -Content ([string]::Format(
            '| [{0}](plugins/{1}) | {2} |',
            $PluginName,
            $PluginDocName,
            $PluginSynopsis
        ));

        $PluginHelp = Get-Help $PluginName -Full;

        Add-IcingaDocumentContent -Name $PluginName -Content ([string]::Format('# {0}', $PluginHelp.Name));
        Add-IcingaDocumentContent -Name $PluginName -Content '';
        Add-IcingaDocumentContent -Name $PluginName -Content '## Description';
        Add-IcingaDocumentContent -Name $PluginName -Content '';
        Add-IcingaDocumentContent -Name $PluginName -Content $PluginHelp.details.description.Text;
        Add-IcingaDocumentContent -Name $PluginName -Content '';
        Add-IcingaDocumentContent -Name $PluginName -Content $PluginHelp.description.Text;
        Add-IcingaDocumentContent -Name $PluginName -Content '';
        Add-IcingaDocumentContent -Name $PluginName -Content '## Permissions';
        Add-IcingaDocumentContent -Name $PluginName -Content '';

        if ([string]::IsNullOrEmpty($PluginHelp.Role)) {
            Add-IcingaDocumentContent -Name $PluginName -Content 'No special permissions required.';
        } else {
            Add-IcingaDocumentContent -Name $PluginName -Content 'To execute this plugin you will require to grant the following user permissions.';
            Add-IcingaDocumentContent -Name $PluginName -Content '';
            Add-IcingaDocumentContent -Name $PluginName -Content $PluginHelp.Role;
        }

        if ($null -ne $PluginHelp.parameters.parameter) {
            Add-IcingaDocumentContent -Name $PluginName -Content '';
            Add-IcingaDocumentContent -Name $PluginName -Content '## Arguments';
            Add-IcingaDocumentContent -Name $PluginName -Content '';
            Add-IcingaDocumentContent -Name $PluginName -Content '| Argument | Type | Required | Default | Description |';
            Add-IcingaDocumentContent -Name $PluginName -Content '| ---      | ---  | ---      | ---     | ---         |';

            foreach ($parameter in $PluginHelp.parameters.parameter) {
                [string]$ParamDescription = $parameter.description.Text;
                if ([string]::IsNullOrEmpty($ParamDescription) -eq $FALSE) {
                    $ReplacementString = '<br /> ';

                    $ParamDescription = $ParamDescription.Replace("`r`n", $ReplacementString);
                    $ParamDescription = $ParamDescription.Replace("`r", $ReplacementString);
                    $ParamDescription = $ParamDescription.Replace("`n", $ReplacementString);

                    if ($ParamDescription.Contains('|')) {
                        $ParamDescription = $ParamDescription.Replace('|', '&#124;');
                    }
                }

                [string]$TableContent = [string]::Format(
                    '| {0} | {1} | {2} | {3} | {4} |',
                    $parameter.name,
                    $parameter.type.name,
                    $parameter.required,
                    $parameter.defaultValue,
                    $ParamDescription
                );
                Add-IcingaDocumentContent -Name $PluginName -Content $TableContent;
            }

            Add-IcingaDocumentContent -Name $PluginName -Content '| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |';
        }

        if ($null -ne $PluginHelp.examples) {
            [int]$ExampleIndex = 1;
            Add-IcingaDocumentContent -Name $PluginName -Content '';
            Add-IcingaDocumentContent -Name $PluginName -Content '## Examples';
            Add-IcingaDocumentContent -Name $PluginName -Content '';

            foreach ($example in $PluginHelp.examples.example) {
                [string]$ExampleDescription = $example.remarks.Text;
                if ([string]::IsNullOrEmpty($ExampleDescription) -eq $FALSE) {
                }

                Add-IcingaDocumentContent -Name $PluginName -Content ([string]::Format('### Example Command {0}', $ExampleIndex));
                Add-IcingaDocumentContent -Name $PluginName -Content '';
                Add-IcingaDocumentContent -Name $PluginName -Content '```powershell';
                Add-IcingaDocumentContent -Name $PluginName -Content $example.code;
                Add-IcingaDocumentContent -Name $PluginName -Content '```';
                Add-IcingaDocumentContent -Name $PluginName -Content '';
                Add-IcingaDocumentContent -Name $PluginName -Content ([string]::Format('### Example Output {0}', $ExampleIndex));
                Add-IcingaDocumentContent -Name $PluginName -Content '';
                Add-IcingaDocumentContent -Name $PluginName -Content '```powershell';
                Add-IcingaDocumentContent -Name $PluginName -Content $ExampleDescription;
                Add-IcingaDocumentContent -Name $PluginName -Content '```';
                Add-IcingaDocumentContent -Name $PluginName -Content '';

                $ExampleIndex += 1;
            }

            Write-IcingaDocumentFile $PluginName -ClearCache;
        }
    }

    Write-IcingaDocumentFile 'Plugins Base' -ClearCache;
}
