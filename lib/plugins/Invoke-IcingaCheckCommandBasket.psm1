function Invoke-IcingaCheckCommandBasket()
{
    param(
        $CheckName
    );

    [hashtable]$AllChecks = @{};

    if ($NULL -eq $CheckName) {
        $CheckName = (Get-Command Invoke-IcingaCheck*).Name
    }

    [int]$FieldID = 0;
    [hashtable]$Basket = @{};
    $Basket.Add('Datafield', @{});
    $Basket.Add('DataList', @{});
    $Basket.Add('Command', @{});

                        # DataList Entries (Default for NoPerfData)
                        if ($Basket.DataList.ContainsKey('PowerShell NoPerfData') -eq $FALSE) {
                            $Basket.DataList.Add(
                            'PowerShell NoPerfData', @{
                                'list_name' = 'PowerShell NoPerfData';
                                'owner' = $env:username;
                                'originalId' = '1'; #Gehört noch geändert
                                'entries' = @{};
                            }
                            );
                        }
    
                            $Basket.DataList["PowerShell NoPerfData"].entries.Add(
                                '0', @{
                                    'entry_name' = '0';
                                    'entry_value:' = "yes";
                                    'format' = 'string';
                                    'allowed_roles' = $NULL;
                                }
                            );
                            $Basket.DataList["PowerShell NoPerfData"].entries.Add(
                                '1', @{
                                    'entry_name' = '1';
                                    'entry_value:' = "no";
                                    'format' = 'string';
                                    'allowed_roles' = $NULL;
                                }
                            );
    
                                    # DataList Entries (Default for Verbose)
            if ($Basket.DataList.ContainsKey('PowerShell Verbose') -eq $FALSE) {
                $Basket.DataList.Add(
                'PowerShell Verbose', @{
                    'list_name' = 'PowerShell Verbose';
                    'owner' = $env:username;
                    'originalId' = '50'; #Gehört noch geändert
                    'entries' = @{};
                }
                );
            }
                $Basket.DataList["PowerShell Verbose"].entries.Add(
                    '0', @{
                        'entry_name' = '0';
                        'entry_value:' = "Show Default";
                        'format' = 'string';
                        'allowed_roles' = $NULL;
                    }
                );
                $Basket.DataList["PowerShell Verbose"].entries.Add(
                    '1', @{
                        'entry_name' = '1';
                        'entry_value:' = "Show Operator";
                        'format' = 'string';
                        'allowed_roles' = $NULL;
                    }
                );
                $Basket.DataList["PowerShell Verbose"].entries.Add(
                    '2', @{
                        'entry_name' = '2';
                        'entry_value:' = "Show Problems";
                        'format' = 'string';
                        'allowed_roles' = $NULL;
                    }
                )
                $Basket.DataList["PowerShell Verbose"].entries.Add(
                    '3', @{
                        'entry_name' = '3';
                        'entry_value:' = "Show All";
                        'format' = 'string';
                        'allowed_roles' = $NULL;
                    }
                );
    

    foreach ($check in $CheckName) {
    
#    [hashtable]$Basket = @{};

#    [int]$FieldID = 0;
    
    $Data = (Get-Help $check)

    $Basket.Command.Add(
            $Data.Syntax.syntaxItem.Name, @{
                'arguments'= @{
                    '-C' = @{
                        'value' = [string]::Format('Use-Icinga; {0}', $Data.Syntax.syntaxItem.Name);
                        'order' = '0';
                    }
                }
                'command' = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"; #Gehört noch geändert
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

#    $Basket.Add('Datafield', @{});
#    $Basket.Add('DataList', @{});

    foreach ($parameter in $Data.Syntax.syntaxItem.parameter) {
        if ($parameter.name -ne 'core') {
        # Is Numeric Check on position to determine the order value
        If (Test-Numeric($parameter.position) -eq $TRUE) {
            [string]$Order = [int]$parameter.position + 1
        } else {
            [string]$Order = 99
        }

        $IcingaCustomVariable = [string]::Format('$PowerShell_{0}_{1}$', $parameter.type.name, $parameter.Name);

        # Conditional whether type of parameter is switch
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
        # Required?
        if ($parameter.required -eq $TRUE) {
            $Required = 'y';
        } else {
            $Required = 'n';
        }
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

            if ($Basket.Datafield.Values.varname -eq $IcingaCustomVariable)
            {
            }
            else {
            [int]$FieldID = $FieldID + 1;
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
            [int]$FieldID = $FieldID + 1;
    }
}

    # Check whether or not noperfdata and verbose is set and add it if necessary
    if ($Basket.Command[$Data.Syntax.syntaxItem.Name].arguments.ContainsKey('-Verbose') -eq $FALSE) {
        [int]$FieldID = $FieldID + 1;
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
        [int]$FieldID = $FieldID + 1;
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
    $AllChecks.Add($check, $Basket);
    }

Write-Host $CheckName;
Write-Host $CheckName.Count;

#    if ([string]$CheckName.Count -eq '1') {
        $output=ConvertTo-Json -D 100 $Basket > Check.json;
#    } else {
#        $output=ConvertTo-Json -D 100 $AllChecks > Check.json;
#    }

    return $output;
}