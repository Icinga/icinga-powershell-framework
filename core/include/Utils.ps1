# Provide a collection of utility functions for the module
[hashtable]$Utils = @{};

Get-ChildItem (Join-Path -Path $PSScriptRoot -ChildPath '\utils\') -Filter *.ps1 |
    Foreach-Object {
        $path = $_.FullName;
        $name = $_.Name.Replace('.ps1', '');

        $Utils.Add($name, (& $path));
    }

return $Utils;