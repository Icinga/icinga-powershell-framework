<#
.SYNOPSIS
   Exports command as JSON for icinga director

.DESCRIPTION
   Get-IcingaCheckCommandConfig returns a JSON-file of one or all 'Invoke-IcingaCheck'-Commands, which can be imported via Icinga-Director
   When no single command is specified all commands will be exported, and vice versa.

   More Information on https://github.com/Icinga/icinga-powershell-framework

.FUNCTIONALITY
   This module is intended to be used to export one or all PowerShell-Modules with the namespace 'Invoke-IcingaCheck'.
   The JSON-Export, which will be generated through this module is structured like an Icinga-Director-JSON-Export, so it can be imported via the Icinga-Director the same way.

.EXAMPLE
   PS>Get-IcingaCheckCommandConfig
   Check Command JSON for the following commands:
   - 'Invoke-IcingaCheckBiosSerial'
   - 'Invoke-IcingaCheckCPU'
   - 'Invoke-IcingaCheckProcessCount'
   - 'Invoke-IcingaCheckService'
   - 'Invoke-IcingaCheckUpdates'
   - 'Invoke-IcingaCheckUptime'
   - 'Invoke-IcingaCheckUsedPartitionSpace'
   - 'Invoke-IcingaCheckUsers'
############################################################

.EXAMPLE
   Get-IcingaCheckCommandConfig -OutDirectory 'C:\Users\icinga\config-exports'
   The following commands have been exported:
   - 'Invoke-IcingaCheckBiosSerial'
   - 'Invoke-IcingaCheckCPU'
   - 'Invoke-IcingaCheckProcessCount'
   - 'Invoke-IcingaCheckService'
   - 'Invoke-IcingaCheckUpdates'
   - 'Invoke-IcingaCheckUptime'
   - 'Invoke-IcingaCheckUsedPartitionSpace'
   - 'Invoke-IcingaCheckUsers'
   JSON export created in 'C:\Users\icinga\config-exports\PowerShell_CheckCommands_09-13-2019-10-55-1989.json'

.EXAMPLE
   Get-IcingaCheckCommandConfig Invoke-IcingaCheckBiosSerial, Invoke-IcingaCheckCPU -OutDirectory 'C:\Users\icinga\config-exports'
   The following commands have been exported:
   - 'Invoke-IcingaCheckBiosSerial'
   - 'Invoke-IcingaCheckCPU'
   JSON export created in 'C:\Users\icinga\config-exports\PowerShell_CheckCommands_09-13-2019-10-58-5342.json'

.PARAMETER CheckName
   Used to specify an array of commands which should be exported.
   Separated with ','

.PARAMETER FileName
   Define a custom file name for the exported `.json`/`.conf` file

.PARAMETER IcingaConfig
   Will switch the configuration generator to write plain Icinga 2 `.conf`
   files instead of Icinga Director Basket `.json` files

.INPUTS
   System.Array

.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework

.NOTES
#>

function Get-IcingaCheckCommandConfig()
{
    param(
        [array]$CheckName,
        [string]$OutDirectory = '',
        [string]$Filename,
        [switch]$IcingaConfig
    );

    # Check whether all Checks will be exported or just the ones specified
    if ([string]::IsNullOrEmpty($CheckName) -eq $true) {
        $CheckName = (Get-Command Invoke-IcingaCheck*).Name
    }

    [int]$FieldID = 2; # Starts at '2', because '0' and '1' are reserved for 'Verbose' and 'NoPerfData'
    [hashtable]$Basket = @{};

    # Define basic hashtable structure by adding fields: "Datafield", "DataList", "Command"
    $Basket.Add('Datafield', @{});
    $Basket.Add('DataList', @{});
    $Basket.Add('Command', @{});

    # At first generate a base Check-Command we can use as import source for all other commands
    $Basket.Command.Add(
        'PowerShell Base',
        @{
            'arguments'       = @{};
            'command'         = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe';
            'disabled'        = $FALSE;
            'fields'          = @();
            'imports'         = @();
            'is_string'       = $NULL;
            'methods_execute' = 'PluginCheck';
            'object_name'     = 'PowerShell Base';
            'object_type'     = 'object';
            'timeout'         = '180';
            'vars'            = @{};
            'zone'            = $NULL;
        }
    );

    # Loop through ${CheckName}, to get information on every command specified/all commands.
    foreach ($check in $CheckName) {

        # Get necessary syntax-information and more through cmdlet "Get-Help"
        $Data            = (Get-Help $check);
        $ParameterList   = (Get-Command -Name $check).Parameters;
        $PluginNameSpace = $Data.Name.Replace('Invoke-', '');

        # Add command Structure
        $Basket.Command.Add(
            $Data.Name, @{
                'arguments'   = @{
                    # Set the Command handling for every check command
                    '-C' = @{
                        'value' = [string]::Format('try {{ Use-Icinga; }} catch {{ Write-Output {1}The Icinga PowerShell Framework is either not installed on the system or not configured properly. Please check https://icinga.com/docs/windows for further details{1}; exit 3; }}; Exit-IcingaPluginNotInstalled {1}{0}{1}; exit {0}', $Data.Name, "'");
                        'order' = '0';
                    }
                }
                'fields'      = @();
                'imports'     = @( 'PowerShell Base' );
                'object_name' = $Data.Name;
                'object_type' = 'object';
                'vars'        = @{};
            }
        );

        # Loop through parameters of a given command
        foreach ($parameter in $Data.parameters.parameter) {

            $IsDataList      = $FALSE;

            # IsNumeric-Check on position to determine the order-value
            If (Test-Numeric($parameter.position) -eq $TRUE) {
                [string]$Order = [int]$parameter.position + 1;
            } else {
                [string]$Order = 99
            }

            $IcingaCustomVariable = [string]::Format('${0}_{1}_{2}$', $PluginNameSpace, (Get-Culture).TextInfo.ToTitleCase($parameter.type.name), $parameter.Name);

            if ($IcingaCustomVariable.Length -gt 66) {
                Write-IcingaConsoleError 'The argument "{0}" for the plugin "{1}" is too long. The maximum size of generated custom variables is 64 digits. Current argument size: "{2}", Name: "{3}"' -Objects $parameter.Name, $check, ($IcingaCustomVariable.Length - 2), $IcingaCustomVariable.Replace('$', '');
                return;
            }

            # Todo: Should we improve this? Actually the handling would be identical, we just need to assign
            #       the proper field for this
            if ($IcingaCustomVariable -like '*_Int32_Verbose$' -Or $IcingaCustomVariable -like '*_Int_Verbose$' -Or $IcingaCustomVariable -like '*_Object_Verbose$') {
                $IcingaCustomVariable = [string]::Format('${0}_Int_Verbose$', $PluginNameSpace);
            }

            # Add arguments to a given command
            if ($parameter.type.name -eq 'SwitchParameter') {
                $Basket.Command[$Data.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'set_if'        = $IcingaCustomVariable;
                        'set_if_format' = 'string';
                        'order'         = $Order;
                    }
                );

                $Basket.Command[$Data.Name].vars.Add($IcingaCustomVariable.Replace('$', ''), $FALSE);

            } elseif ($parameter.type.name -eq 'Array') {
                # Conditional whether type of parameter is array
                $Basket.Command[$Data.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'value' = @{
                            'type' = 'Function';
                            'body' = [string]::Format(
                                'var arr = macro("{0}");{1}if (len(arr) == 0) {2}{1}return "@()";{1}{3}{1}return arr.join(",");',
                                $IcingaCustomVariable,
                                "`r`n",
                                '{',
                                '}'
                            );
                        }
                        'order' = $Order;
                    }
                );
            } elseif ($parameter.type.name -eq 'SecureString') {
                # Convert out input string as SecureString
                $Basket.Command[$Data.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'value' = (
                            [string]::Format(
                                "(ConvertTo-IcingaSecureString '{0}')",
                                $IcingaCustomVariable
                            )
                        )
                        'order' = $Order;
                    }
                );
            } else {
                # Default to Object
                $Basket.Command[$Data.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'value' = $IcingaCustomVariable;
                        'order' = $Order;
                    }
                );
            }

            # Determine wether a parameter is required based on given syntax-information
            if ($parameter.required -eq $TRUE) {
                $Required = 'y';
            } else {
                $Required = 'n';
            }

            $IcingaCustomVariable = [string]::Format('{0}_{1}_{2}', $PluginNameSpace, (Get-Culture).TextInfo.ToTitleCase($parameter.type.name), $parameter.Name);

            # Todo: Should we improve this? Actually the handling would be identical, we just need to assign
            #       the proper field for this
            if ($IcingaCustomVariable -like '*_Int32_Verbose' -Or $IcingaCustomVariable -like '*_Int_Verbose' -Or $IcingaCustomVariable -like '*_Object_Verbose') {
                $IcingaCustomVariable = [string]::Format('{0}_Int_Verbose', $PluginNameSpace);
            }

            [bool]$ArgumentKnown = $FALSE;

            foreach ($argument in $Basket.Datafield.Keys) {
                if ($Basket.Datafield[$argument].varname -eq $IcingaCustomVariable) {
                    $ArgumentKnown = $TRUE;
                    break;
                }
            }

            if ($ArgumentKnown) {
                continue;
            }

            $DataListName = [string]::Format('{0} {1}', $PluginNameSpace, $parameter.Name);

            if ($null -ne $ParameterList[$parameter.Name].Attributes.ValidValues) {
                $IcingaDataType = 'Datalist';
                Add-PowerShellDataList -Name $DataListName -Basket $Basket -Arguments $ParameterList[$parameter.Name].Attributes.ValidValues;
                $IsDataList = $TRUE;
            } elseif ($parameter.type.name -eq 'SwitchParameter') {
                $IcingaDataType = 'Boolean';
            } elseif ($parameter.type.name -eq 'Object') {
                $IcingaDataType = 'String';
            } elseif ($parameter.type.name -eq 'Array') {
                $IcingaDataType = 'Array';
            } elseif ($parameter.type.name -eq 'Int' -Or $parameter.type.name -eq 'Int32') {
                $IcingaDataType = 'Number';
            } else {
                $IcingaDataType = 'String';
            }

            $IcingaDataType = [string]::Format('Icinga\Module\Director\DataType\DataType{0}', $IcingaDataType)

            if ($Basket.Datafield.Values.varname -ne $IcingaCustomVariable) {
                $Basket.Datafield.Add(
                    [string]$FieldID, @{
                        'varname'     = $IcingaCustomVariable;
                        'caption'     = $parameter.Name;
                        'description' = $parameter.Description.Text;
                        'datatype'    = $IcingaDataType;
                        'format'      = $NULL;
                        'originalId'  = [string]$FieldID;
                    }
                );

                if ($IsDataList) {
                    [string]$DataListDataType = 'string';

                    if ($parameter.type.name -eq 'Array') {
                        $DataListDataType = 'array';
                    }

                    $Basket.Datafield[[string]$FieldID].Add(
                        'settings', @{
                            'datalist'  = $DataListName;
                            'data_type' = $DataListDataType;
                            'behavior'  = 'strict';
                        }
                    );
                } else {
                    $Basket.Datafield[[string]$FieldID].Add(
                        'settings', @{
                            'visbility' = 'visible';
                        }
                    );
                }

                # Increment FieldID, so unique datafields are added.
                [int]$FieldID = [int]$FieldID + 1;
            }

            # Increment FieldNumeration, so unique fields for a given command are added.
            [int]$FieldNumeration = [int]$FieldNumeration + 1;
        }
    }

    foreach ($check in $CheckName) {
        [int]$FieldNumeration = 0;

        $Data            = (Get-Help $check)
        $PluginNameSpace = $Data.Name.Replace('Invoke-', '');

        foreach ($parameter in $Data.parameters.parameter) {
            $IcingaCustomVariable = [string]::Format('{0}_{1}_{2}', $PluginNameSpace, (Get-Culture).TextInfo.ToTitleCase($parameter.type.name), $parameter.Name);

            # Todo: Should we improve this? Actually the handling would be identical, we just need to assign
            #       the proper field for this
            if ($IcingaCustomVariable -like '*_Int32_Verbose' -Or $IcingaCustomVariable -like '*_Int_Verbose' -Or $IcingaCustomVariable -like '*_Object_Verbose') {
                $IcingaCustomVariable = [string]::Format('{0}_Int_Verbose', $PluginNameSpace);
            }

            foreach ($DataFieldID in $Basket.Datafield.Keys) {
                [string]$varname = $Basket.Datafield[$DataFieldID].varname;
                if ([string]$varname -eq [string]$IcingaCustomVariable) {
                    $Basket.Command[$Data.Name].fields +=  @{
                        'datafield_id' = [int]$DataFieldID;
                        'is_required'  = $Required;
                        'var_filter'   = $NULL;
                    };
                }
            }
        }
    }

    [string]$FileType = '.json';
    if ($IcingaConfig) {
        $FileType = '.conf';
    }

    if ([string]::IsNullOrEmpty($Filename)) {
        $TimeStamp = (Get-Date -Format "MM-dd-yyyy-HH-mm-ffff");
        $FileName  = [string]::Format("PowerShell_CheckCommands_{0}{1}", $TimeStamp, $FileType);
    } else {
        if ($Filename.Contains($FileType) -eq $FALSE) {
            $Filename = [string]::Format('{0}{1}', $Filename, $FileType);
        }
    }

    # Generate JSON Output from Hashtable
    $output = ConvertTo-Json -Depth 100 $Basket -Compress;

    # Determine whether json output via powershell or in file (based on param -OutDirectory)
    if ([string]::IsNullOrEmpty($OutDirectory) -eq $false) {
        $ConfigDirectory = $OutDirectory;
        $OutDirectory    = (Join-Path -Path $OutDirectory -ChildPath $FileName);
        if ((Test-Path($OutDirectory)) -eq $false) {
            New-Item -Path $OutDirectory -ItemType File -Force | Out-Null;
        }

        if ((Test-Path($OutDirectory)) -eq $false) {
            throw 'Failed to create specified directory. Please try again or use a different target location.';
        }

        if ($IcingaConfig) {
            Write-IcingaPlainConfigurationFiles -Content $Basket -OutDirectory $ConfigDirectory -FileName $FileName;
        } else {
            Set-Content -Path $OutDirectory -Value $output;
        }

        # Output-Text
        Write-IcingaConsoleNotice "The following commands have been exported:"
        foreach ($check in $CheckName) {
            Write-IcingaConsoleNotice "- '$check'";
        }
        Write-IcingaConsoleNotice "JSON export created in '${OutDirectory}'"
        Write-IcingaConsoleWarning 'By using this generated check command configuration you will require the Icinga PowerShell Framework 1.2.0 or later to be installed on ALL monitored machines!';
        return;
    }

    Write-IcingaConsoleNotice "Check Command JSON for the following commands:"
    foreach ($check in $CheckName) {
        Write-IcingaConsoleNotice "- '$check'"
    }
    Write-IcingaConsoleWarning 'By using this generated check command configuration you will require the Icinga PowerShell Framework 1.2.0 or later to be installed on ALL monitored machines!';
    Write-IcingaConsoleNotice '############################################################';

    return $output;
}

function Write-IcingaPlainConfigurationFiles()
{
    param (
        $Content,
        $OutDirectory,
        $FileName
    );

    $ConfigDirectory = $OutDirectory;
    $OutDirectory    = (Join-Path -Path $OutDirectory -ChildPath $FileName);

    $IcingaConfig = '';

    foreach ($entry in $Content.Command.Keys) {
        $CheckCommand = $Content.Command[$entry];

        # Skip PowerShell base, this is written at the end in a separate file
        if ($CheckCommand.object_name -eq 'PowerShell Base') {
            continue;
        }

        # Create the CheckCommand object
        $IcingaConfig += [string]::Format('object CheckCommand "{0}" {{{1}', $CheckCommand.object_name, (New-IcingaNewLine));

        # Import all defined import templates
        foreach ($import in $CheckCommand.imports) {
            $IcingaConfig += [string]::Format('    import "{0}"{1}', $import, (New-IcingaNewLine));
        }
        $IcingaConfig += New-IcingaNewLine;

        if ($CheckCommand.arguments.Count -ne 0) {
            # Arguments for the configuration
            $IcingaConfig += '    arguments += {'
            $IcingaConfig += New-IcingaNewLine;

            foreach ($argument in $CheckCommand.arguments.Keys) {
                $CheckArgument = $CheckCommand.arguments[$argument];

                # Each single argument, like "-Verbosity" = {
                $IcingaConfig += [string]::Format('        "{0}" = {{{1}', $argument, (New-IcingaNewLine));

                foreach ($argconfig in $CheckArgument.Keys) {
                    $Value = '';

                    if ($argconfig -eq 'set_if_format') {
                        continue;
                    }

                    # Order is numeric -> no "" required
                    if ($argconfig -eq 'order') {
                        $StringFormater = '            {0} = {1}{2}';
                    } else {
                        # All other entries should be handled as strings and contain ""
                        $StringFormater ='            {0} = "{1}"{2}'
                    }

                    # In case it is a hashtable, this is most likely a DSL function
                    # We have to render it differently to also match the intends
                    if ($CheckArgument[$argconfig] -is [Hashtable]) {
                        $Value = $CheckArgument[$argconfig].body;
                        $DSLArray = $Value.Split("`r`n");
                        $Value = '';
                        foreach ($item in $DSLArray) {
                            if ([string]::IsNullOrEmpty($item)) {
                                continue;
                            }
                            $Value += [string]::Format('                {0}{1}', $item, (New-IcingaNewLine));
                        }
                        $Value = $Value.Substring(0, $Value.Length - 2);
                        $StringFormater ='            {0} = {{{{{2}{1}{2}            }}}}{2}'
                    } else {
                        # All other values besides DSL
                        $Value = $CheckArgument[$argconfig];
                    }

                    # Read description from our variables
                    if ($argconfig -eq 'value') {
                        foreach ($item in $Content.DataField.Keys) {
                            $DataField = $Content.DataField[$item];

                            if ($Value.Contains($DataField.varname)) {
                                if ([string]::IsNullOrEmpty($DataField.description)) {
                                    break;
                                }
                                $Description = $DataField.description.Replace("`r`n", ' ');
                                $Description = $Description.Replace("\", '\\');
                                $Description = $Description.Replace("`n", ' ');
                                $Description = $Description.Replace("`r", ' ');
                                $Description = $Description.Replace('"', "'");
                                $IcingaConfig += [string]::Format('            description = "{0}"{1}', $Description, (New-IcingaNewLine));
                                break;
                            }
                        }
                    }

                    # Write the argument to your CheckCommand
                    $IcingaConfig += [string]::Format($StringFormater, $argconfig, $Value, (New-IcingaNewLine));
                }

                # Close this specific argument
                $IcingaConfig += '        }'
                $IcingaConfig += New-IcingaNewLine;
            }

            $IcingaConfig = $IcingaConfig.Substring(0, $IcingaConfig.Length - 2);

            # Close all arguments content
            $IcingaConfig += New-IcingaNewLine;
            $IcingaConfig += '    }'
        }

        # In case we pre-define custom variables, we should add them here
        if ($CheckCommand.vars.Count -ne 0) {
            $IcingaConfig += New-IcingaNewLine;

            foreach ($var in $CheckCommand.vars.Keys) {
                [string]$Value = $CheckCommand.vars[$var];
                $IcingaConfig += [string]::Format('    vars.{0} = {1}{2}', $var, $Value.ToLower(), (New-IcingaNewLine));
            }
        } else {
            $IcingaConfig += New-IcingaNewLine;
        }

        # Close the CheckCommand object
        $IcingaConfig += '}';
        if ($Content.Command.Count -gt 2) {
            $IcingaConfig += New-IcingaNewLine;
            $IcingaConfig += New-IcingaNewLine;
        }
    }

    # Write the PowerShell Base command to a separate file for Icinga 2 configuration
    [string]$PowerShellBase  = [string]::Format('object CheckCommand "PowerShell Base" {{{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('    import "plugin-check-command"{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('    command = [{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('        "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('    ]{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('    timeout = 3m{0}', (New-IcingaNewLine));
    $PowerShellBase         += '}';

    Set-Content -Path (Join-Path -Path $ConfigDirectory -ChildPath 'PowerShell_Base.conf') -Value $PowerShellBase;
    Set-Content -Path $OutDirectory -Value $IcingaConfig;
}

function Add-PowerShellDataList()
{
    param(
        $Name,
        $Basket,
        $Arguments
    );

    $Basket.DataList.Add(
        $Name, @{
            'list_name'  = $Name;
            'owner'      = $env:username;
            'originalId' = '2';
            'entries'    = @();
        }
    );

    foreach ($entry in $Arguments) {
        if ([string]::IsNullOrEmpty($entry)) {
            Write-IcingaConsoleWarning `
                -Message 'The plugin argument "{0}" contains the illegal ValidateSet $null which will not be rendered. Please remove it from the arguments list of "{1}"' `
                -Objects $Name, $Arguments;

            continue;
        }
        $Basket.DataList[$Name]['entries'] += @{
            'entry_name'    = $entry;
            'entry_value'   = $entry;
            'format'        = 'string';
            'allowed_roles' = $NULL;
        };
    }
}
