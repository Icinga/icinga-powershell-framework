<#
.SYNOPSIS
   Exports command as JSON for icinga director

.DESCRIPTION
   Get-IcingaCheckCommandConfig returns a JSON-file of one or all 'Invoke-IcingaCheck'-Commands, which can be imported via Icinga-Director
   When no single command is specified all commands will be exported, and vice versa.

   More Information on https://github.com/LordHepipud/icinga-module-windows

.FUNCTIONALITY
   This module is intended to be used to export one or all PowerShell-Modules with the namespace 'Invoke-IcingaCheck'.
   The JSON-Export, which will be egenerated through this module is structured like an Icinga-Director-JSON-Export, so it can be imported via the Icinga-Director the same way.

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
   Get-IcingaCheckCommandConfig -OutFile 'C:\Users\icinga\config-exports'
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
   Get-IcingaCheckCommandConfig Invoke-IcingaCheckBiosSerial, Invoke-IcingaCheckCPU -OutFile 'C:\Users\icinga\config-exports'
   The following commands have been exported:
   - 'Invoke-IcingaCheckBiosSerial'
   - 'Invoke-IcingaCheckCPU'
   JSON export created in 'C:\Users\icinga\config-exports\PowerShell_CheckCommands_09-13-2019-10-58-5342.json'

.PARAMETER CheckName
   Used to specify an array of commands which should be exported.
   Seperated with ','

 .INPUTS
   System.Array

 .OUTPUTS
   System.String

 .LINK
   https://github.com/LordHepipud/icinga-module-windows

 .NOTES
#>

function Get-IcingaCheckCommandConfig()
{
    param(
        [Parameter(ValueFromPipeline)]
        [array]$CheckName,
        [string]$OutFile
    );

    # Check whether all Checks will be exported or just the ones specified
    if ([string]::IsNullOrEmpty($CheckName) -eq $true) {
        $CheckName = (Get-Command Invoke-IcingaCheck*).Name
    }

    [int]$FieldID = 2;              # Starts at '2', because '0' and '1' are reserved for 'Verbose' and 'NoPerfData'
    [hashtable]$Basket = @{};

    # Define basic hashtable structure by adding fields: "Datafield", "DataList", "Command"
    $Basket.Add('Datafield', @{});
    $Basket.Add('DataList', @{});
    $Basket.Add('Command', @{});

    
    # "NoPerfData" gets added to all checks build and exported no matter what, so we add it from the start
    if ($Basket.DataList.ContainsKey('PowerShell NoPerfData') -eq $FALSE) {
    
        # DataList Content for NoPerfData
        $Basket.DataList.Add(
            'PowerShell NoPerfData', @{
                'list_name' = 'PowerShell NoPerfData';
                'owner' = $env:username;
                'originalId' = '1';
                'entries' = @(
                    @{
                        'entry_name' = '0';
                        'entry_value:' = "yes";
                        'format' = 'string';
                        'allowed_roles' = $NULL;
                    },
                    @{
                        'entry_name' = '1';
                        'entry_value:' = "no";
                        'format' = 'string';
                        'allowed_roles' = $NULL;
                    }
                );
            }
        );
    }

    # "Verbose" gets added to all Checks build and exported no matter what, so we add it from the start
    if ($Basket.DataList.ContainsKey('PowerShell Verbose') -eq $FALSE) {
        $Basket.DataList.Add(
            'PowerShell Verbose', @{
                'list_name' = 'PowerShell Verbose';
                'owner' = $env:username;
                'originalId' = '2';
                'entries' = @(
                    @{
                    'entry_name' = '0';
                    'entry_value:' = "Show Default";
                    'format' = 'string';
                    'allowed_roles' = $NULL;
                    },
                    @{
                    'entry_name' = '1';
                    'entry_value:' = "Show Operator";
                    'format' = 'string';
                    'allowed_roles' = $NULL;
                    },
                    @{
                    'entry_name' = '2';
                    'entry_value:' = "Show Problems";
                    'format' = 'string';
                    'allowed_roles' = $NULL;
                    },
                    @{
                    'entry_name' = '3';
                    'entry_value:' = "Show All";
                    'format' = 'string';
                    'allowed_roles' = $NULL;
                    }
                );
            }
        );
    }

    # Loop through ${CheckName}, to get information on every command specified/all commands.
    foreach ($check in $CheckName) {

        [int]$FieldNumeration = 0;
    
        # Get necessary syntax-information and more through cmdlet "Get-Help"
        $Data = (Get-Help $check)

        # Add command Structure
        $Basket.Command.Add(
            $Data.Syntax.syntaxItem.Name, @{
                'arguments'= @{
                    # Gets set for every command as default
                    '-C' = @{
                        'value' = [string]::Format('Use-Icinga; {0}', $Data.Syntax.syntaxItem.Name);
                        'order' = '0';
                    }
                }
                'command' = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";
                'disabled' = $FALSE;
                'fields' = @{};
                'imports' = @();
                'is_string' = $NULL;
                'methods_excute' = 'PluginCheck';
                'object_name' = $Data.Syntax.syntaxItem.Name;
                'object_type' = 'object';
                'timeout' = '180';
                'vars' = @{};
                'zone' = $NULL;
            }
        );

        # Loop through parameters of a given command
        foreach ($parameter in $Data.Syntax.syntaxItem.parameter) {

            # Filter for Parameter 'core', because its set by default
            if ($parameter.name -ne 'core') {

                # IsNumeric-Check on position to determine the order-value
                If (Test-Numeric($parameter.position) -eq $TRUE) {
                    [string]$Order = [int]$parameter.position + 1;
                } else {
                    [string]$Order = 99
                }

                $IcingaCustomVariable = [string]::Format('$PowerShell_{0}_{1}$', $parameter.type.name, $parameter.Name);

                # Add arguments to a given command
                if ($parameter.type.name -eq 'switch') {
                    $Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.Add(
                        [string]::Format('-{0}', $parameter.Name), @{
                            'set_if' = $IcingaCustomVariable;
                            'set_if_format' = 'string';
                            'order' = $Order;
                        }
                    );
                
                $Basket.Command[$Data.Syntax.syntaxItem.Name].vars.Add($parameter.Name, "0");

                # Conditional whether type of parameter is array
                } elseif ($parameter.type.name -eq 'array') {
                    $Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.Add(
                        [string]::Format('-{0}', $parameter.Name), @{
                            'value' = [string]::Format('(Split-IcingaCheckCommandArgs {0})', $IcingaCustomVariable);
                            'order' = $Order;
                        }
                    );
                } else {
                # Default to Object
                    $Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.Add(
                        [string]::Format('-{0}', $parameter.Name), @{
                            'value' = $IcingaCustomVariable;
                            'order' = $Order;
                        }
                    );

                    if ($parameter.name -ne 'Verbose') {
                        $Basket.Command[$Data.Syntax.syntaxItem.Name].vars.Add($parameter.Name, '$$null');
                    } else {
                        $Basket.Command[$Data.Syntax.syntaxItem.Name].vars.Add($parameter.Name, "0");
                    }
                }

                # Determine wether a parameter is required based on given syntax-information
                if ($parameter.required -eq $TRUE) {
                    $Required = 'y';
                } else {
                    $Required = 'n';
                }

                $IcingaCustomVariable = [string]::Format('PowerShell_{0}_{1}', $parameter.type.name, $parameter.Name);

                $DataListName = [string]::Format('PowerShell {0}', $parameter.Name)
            
                if ($parameter.type.name -eq 'switch') {
                    $IcingaDataType='Datalist';
                    if ($Basket.DataList.ContainsKey($DataListName) -eq $FALSE) {
                        $Basket.DataList.Add(
                            $DataListName, @{
                                'list_name' = $DataListName;
                                'owner' = $env:username;
                                'originalId' = '50'; #Gehört noch geändert
                                'entries' = @{};
                            }
                        );
                    }
                } elseif ($parameter.type.name -eq 'Object') {
                    if ($parameter.Name -eq 'Verbose') {
                        $IcingaDataType='Datalist'
                    }

                    $IcingaDataType='String';

                } elseif ($parameter.type.name -eq 'Array') {
                    $IcingaDataType='Array';
                } else {
                    $IcingaDataType='String';
                }

               if($Basket.Datafield.ContainsKey('0') -eq $FALSE){
                    $Basket.Datafield.Add(
                        '0', @{
                            'varname' = 'PowerShell_switch_NoPerfData';
                            'caption' = 'NoPerfData';
                            'description' = $NULL;
                            'datatype' = 'Icinga\\Module\\Director\\DataType\\DataTypeDatalist';
                            'format' = $NULL;
                            'originalId' = '0';
                            'settings' = @{
                                'datalist' = 'PowerShell NoPerfData';
                                'datatype' = 'string';
                                'behavior' = 'strict';
                            }
                        }
                    );
                }

                if($Basket.Datafield.ContainsKey('1') -eq $FALSE){
                    $Basket.Datafield.Add(
                        '1', @{
                            'varname' = 'PowerShell_switch_NoPerfData';
                            'caption' = 'Verbose';
                            'description' = $NULL;
                            'datatype' = 'Icinga\\Module\\Director\\DataType\\DataTypeString';
                            'format' = $NULL;
                            'originalId' = '1';
                            'settings' = @{
                                'datalist' = 'PowerShell Verbose';
                                'datatype' = 'string';
                                'behavior' = 'strict';
                            }
                        }
                    );
                }

                $IcingaDataType = [string]::Format('Icinga\Module\Director\DataType\DataType{0}', $IcingaDataType)

                if ($Basket.Datafield.Values.varname -eq $IcingaCustomVariable) {
                } else {
                    $Basket.Datafield.Add(
                        [string]$FieldID, @{
                            'varname' = $IcingaCustomVariable;
                            'caption' = $parameter.Name;
                            'description' = $NULL;
                            'datatype' = $IcingaDataType;
                            'format' = $NULL;
                            'originalId' = [string]$FieldID;
                        }
                    );

                    if ($parameter.type.name -eq 'switch' -or $parameter.Name -eq 'Verbose') {
                        $Basket.Datafield[[string]$FieldID].Add(
                            'settings', @{
                                'behavior' = 'strict';
                                'datatype' = 'string';
                                'datalist' = $DataListName;
                            }
                        );
                    } elseif ($parameter.type.name -eq 'Object') {
                        $Basket.Datafield[[string]$FieldID].Add(
                            'settings', @{
                                'visbility' = 'visible';
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
            }

            # Increment FieldNumeation, so unique fields for a given command are added.
            [int]$FieldNumeration = [int]$FieldNumeration + 1;
        }

        # Check whether or not noperfdata and verbose is set and add it if necessary
        if ($Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.ContainsKey('-Verbose') -eq $FALSE) {
            $Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.Add(
                '-Verbose', @{
                    'value' = '$PowerShell_Object_Verbose$';
                    'order' = '99';
                }
            );

            $Basket.Command[$Data.Syntax.syntaxItem.Name].vars.Add(
                'PowerShell_Object_Verbose', "0"
            );

            if ($Basket.Datafield.Values.varname -eq $IcingaCustomVariable) {
            } else {
                $Basket.Datafield.Add(
                    [string]$FieldID, @{
                        'varname' = 'PowerShell_Object_Verbose';
                        'caption' = 'Verbose';
                        'description' = $NULL;
                        'datatype' = 'Icinga\Module\Director\DataType\DataTypeDatalist';
                        'format' = $NULL;
                        'originalId' = [string]$FieldID;
                        'settings' = @{
                            'behavior' = 'strict';
                            'data_type' = 'string';
                            'datalist' = 'PowerShell Verbose'
                        }
                    }
                );
            }
        }

        if ($Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.ContainsKey('-NoPerfData') -eq $FALSE) {
            $Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.Add(
                '-NoPerfData', @{
                    'set_if' = '$PowerShell_switch_NoPerfData$';
                    'set_if_format' = 'string';
                    'order' = '99';
                }
            );
            $Basket.Command[$Data.Syntax.syntaxItem.Name].vars.Add('PowerShell_switch_NoPerfData', "0");

            if ($Basket.Datafield.Values.varname -eq $IcingaCustomVariable) {
            } else {
                $Basket.Datafield.Add(
                    [string]$FieldID, @{
                        'varname' = 'PowerShell_switch_NoPerfData';
                        'caption' = 'Perf Data';
                        'description' = $NULL;
                        'datatype' = 'Icinga\Module\Director\DataType\DataTypeDatalist';
                        'format' = $NULL;
                        'originalId' = [string]$FieldID;
                        'settings' = @{
                            'behavior' = 'strict';
                            'data_type' = 'string';
                            'datalist' = 'PowerShell NoPerfData'
                        }
                    }
                );
            }
        }
    }

    foreach ($check in $CheckName) {
        [int]$FieldNumeration = 0;

        $Data = (Get-Help $check)    
    
        foreach ($parameter in $Data.Syntax.syntaxItem.parameter){
            $IcingaCustomVariable = [string]::Format('PowerShell_{0}_{1}', $parameter.type.name, $parameter.Name);

            # Hashtable for Matching Command.Name.Fields to DataFields (and there given IDs)
            [hashtable]$TranslationDataField = @{}

            # Looping through IDs of existing DataFields
            foreach ($DataFieldID in $Basket.Datafield.Keys)
            {
                # Ignore Default-Set Deatafield "NoPerfData"
                if ($TranslationDataField.Contains('PowerShell_switch_NoPerfData') -eq $TRUE){
                }else{
                $TranslationDataField.Add($Basket.Datafield.$DataFieldID.varname, $DataFieldID);
                }
            }
        
            foreach($key in $TranslationDataField.Keys)
            {
                if ([string]$IcingaCustomVariable -eq [string]$key) {
                    $MatchedDataFieldID = $TranslationDataField[$IcingaCustomVariable];
                } else {}
            }
    
            $Basket.Command[$Data.Syntax.syntaxItem.Name].fields.Add(
                [string]$FieldNumeration, @{
                        'datafield_id' = [int]$MatchedDataFieldID;
                        'is_required' = $Required;
                        'var_filter' = $NULL;
                    }
                );

            [int]$FieldNumeration = [int]$FieldNumeration + 1;
        }
    }

    # Build Filename with given Timestamp
    $TimeStamp = (Get-Date -Format "MM-dd-yyyy-HH-mm-ffff");
    $FileName = "PowerShell_CheckCommands_$TimeStamp.json";

    # Generate JSON Output from Hashtable
    $output = ConvertTo-Json -Depth 100 $Basket -Compress;

    # Determine whether json output via powershell or in file (based on param -OutFile)
    if ([string]::IsNullOrEmpty($OutFile) -eq $false) {
        $OutFile = (Join-Path -Path $OutFile -ChildPath $FileName);
        if ((Test-Path($OutFile)) -eq $false) {
            New-Item -Path $OutFile -Force | Out-Null;
        }

        if ((Test-Path($OutFile)) -eq $false) {
            throw 'Failed to create specified directory. Please try again or use a different target location.';
        }
        
        Set-Content -Path $OutFile -Value $output;

        # Output-Text
        Write-Host "The following commands have been exported:"
        foreach ($check in $CheckName) {
            Write-Host "- '$check'";
        }
        Write-Host "JSON export created in '${OutFile}'"
        return;
    }

    Write-Host "Check Command JSON for the following commands:"
    foreach ($check in $CheckName) {
        Write-Host "- '$check'"
    }
    Write-Host '############################################################';

    return $output;
}
