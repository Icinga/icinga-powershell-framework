<#
.SYNOPSIS
   Exports command as JSON for icinga director

.DESCRIPTION
   Invoke-IcingaCheckCommandBasket returns a JSON-file of one or all 'Invoke-IcingaCheck'-Commands, which can be imported via Icinga-Director
   When no single command is specified all commands will be exported, and vice versa.

   More Information on https://github.com/LordHepipud/icinga-module-windows

.EXAMPLE
   PS>Invoke-IcingaCheckCommandBasket
   The following commands have been exported:
   - 'Invoke-IcingaCheckBiosSerial'
   - 'Invoke-IcingaCheckCommandBasket'
   - 'Invoke-IcingaCheckCPU'
   - 'Invoke-IcingaCheckProcessCount'
   - 'Invoke-IcingaCheckService'
   - 'Invoke-IcingaCheckUpdates'
   - 'Invoke-IcingaCheckUptime'
   - 'Invoke-IcingaCheckUsedPartitionSpace'
   - 'Invoke-IcingaCheckUsers'
   JSON export created to 'C:\Program Files\WindowsPowerShell\Modules\icinga-module-windows\Checks.json'

.EXAMPLE
   PS>Invoke-IcingaCheckCommandBasket Invoke-IcingaCheckCPU
   The following commands have been exported:
   - 'Invoke-IcingaCheckCPU'
   JSON export created to 'C:\Program Files\WindowsPowerShell\Modules\icinga-module-windows\Invoke-IcingaCheckCPU.json'
.PARAMETER CheckName
   Used to specify a single command which should be exported.
   Has to be a single string.
 .INPUTS
   System.String

 .OUTPUTS
   System.String
   System.Object

 .LINK
   https://github.com/LordHepipud/icinga-module-windows

 .NOTES
#>

function Invoke-IcingaCheckCommandBasket()
{
    param(
        $CheckName
    );

    # Check whether all Checks will be exported or just the single one specified
    if ($NULL -eq $CheckName) {
        $CheckName = (Get-Command Invoke-IcingaCheck*).Name
    }

    # Variable definition and initialization
    [int]$FieldID = 0;
    [hashtable]$Basket = @{};

    # Define basic hashtable structure by adding fields: "Datafield", "DataList", "Command"
    $Basket.Add('Datafield', @{});
    $Basket.Add('DataList', @{});
    $Basket.Add('Command', @{});

    
    # "NoPerfData" gets added to all Checks build and exported no matter what, so we add it from the start
    if ($Basket.DataList.ContainsKey('PowerShell NoPerfData') -eq $FALSE) {
    
    # DataList Content for NoPerfData
        $Basket.DataList.Add(
            'PowerShell NoPerfData', @{
                'list_name' = 'PowerShell NoPerfData';
                'owner' = $env:username;
                'originalId' = '1'; #Gehört noch geändert
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
                'originalId' = '50';
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

    <# 
    Loop through either:
    $CheckName = (Get-Command Invoke-IcingaCheck*).Name
    or one of $CheckName = 'Invoke-IcingaCheckCommand'
    #>
    foreach ($check in $CheckName) {
    if ($check -eq 'Invoke-IcingaCheckCommandBasket') {
    } else {
    
    # Get Necessary Syntax-Information and more through cmdlet "Get-Help"
    $Data = (Get-Help $check)

    # Add Command Structure
    $Basket.Command.Add(
            $Data.Syntax.syntaxItem.Name, @{
                'arguments'= @{
                    # Gets set for every command as Default
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
    )

    # Loop through Parameter of a given command
    foreach ($parameter in $Data.Syntax.syntaxItem.parameter) {
        # Filter for Parameter 'core', because its set by default
        if ($parameter.name -ne 'core') {

            # Is Numeric Check on position to determine the order value
            If (Test-Numeric($parameter.position) -eq $TRUE) {
                [string]$Order = [int]$parameter.position + 1
            } else {
                [string]$Order = 99
            }

            $IcingaCustomVariable = [string]::Format('$PowerShell_{0}_{1}$', $parameter.type.name, $parameter.Name);

            #Adding arguments to a given command
            if ($parameter.type.name -eq 'switch') {
                $Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'set_if' = $IcingaCustomVariable;
                        'set_if_format' = 'string';
                        'order' = $Order;
                    }
                );
                $Basket.Command[$Data.Syntax.syntaxItem.Name].vars.Add(
                    $parameter.Name, "0"
                );
        # Condotional whether type of parameter is array
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
        
            # Fields

            # Determine wether a parameter is required based on given syntax-information
            if ($parameter.required -eq $TRUE) {
            $Required = 'y';
            } else {
            $Required = 'n';
            }

            [int]$FieldID = $FieldID + 1;
            $Basket.Command[$Data.Syntax.syntaxItem.Name].fields.Add(
                [string]$FieldID, @{
                    'datafield_id' = [int]$FieldID;
                    'is_required' = $Required;
                    'var_filter' = $NULL;
                }
            );

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
                        'settings', @{}
                    );
                }
            }
        }
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
        $Basket.Command[$Data.Syntax.syntaxItem.Name].vars.Add(
            'PowerShell_switch_NoPerfData', "0"
        );

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
    }

    if ($CheckName.Count -eq 1) {
        $FileName = "${CheckName}.json";
    } else {
        $FileName = "Checks.json";
    }

    $output=ConvertTo-Json -D 100 $Basket > "$FileName";

    $FilePath = (Get-Location).Path

    # Output-Text
    Write-Host "The following commands have been exported:"
    foreach ($check in $CheckName) {
        if ($check -ne "Invoke-IcingaCheckCommandBasket") {
            Write-Host "- '$check'"
        }
    }
    Write-Host "JSON export created in '${FilePath}\${FileName}'"

    return $output;
}