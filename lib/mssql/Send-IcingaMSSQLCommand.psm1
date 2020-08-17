<#
.SYNOPSIS
   Executes a SQL query
.DESCRIPTION
   This Cmdlet will send a SQL query to a given database and
   execute the query and returns the output.
.FUNCTIONALITY
   Executes a SQL query
.EXAMPLE
   PS> Send-IcingaMSSQLCommand -SqlCommand $SqlCommand;
.PARAMETER SqlCommand
   The SQL query which will be executed, e.g. $SqlCommand = New-IcingaMSSQLCommand
.INPUTS
   System.Data.SqlClient.SqlCommand
.OUTPUTS
   System.Data.DataSet
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Send-IcingaMSSQLCommand {
    param (
        [System.Data.SqlClient.SqlCommand]$SqlCommand = $null
    );

    $Adapter = New-Object System.Data.SqlClient.SqlDataAdapter $SqlCommand;

    $Data    = New-Object System.Data.DataSet;
    $Adapter.Fill($Data) | Out-Null;

    return $Data.Tables;
}
