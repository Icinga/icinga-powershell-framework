<#
.SYNOPSIS
   Builds a SQL query
.DESCRIPTION
   This Cmdlet will  build a SQL query
   and returns it as an string.
.FUNCTIONALITY
   Build a SQL queryNew
.EXAMPLE
   PS>New-IcingaMSSQLCommand -SqlConnection $SqlConnection -SqlQuery "SELECT object_name FROM sys.dm_os_performance_counters";
.PARAMETER SqlConnection
   An open SQL connection object e.g. $SqlConnection = Open-IcingaMSSQLConnection -IntegratedSecurity;
.PARAMETER SqlQuery
   A SQL query as string.
.INPUTS
   System.Data.SqlClient.SqlConnection
   System.String
.OUTPUTS
   System.Data.SqlClient.SqlCommand
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function New-IcingaMSSQLCommand {
    param (
        [System.Data.SqlClient.SqlConnection]$SqlConnection = $null,
        [string]$SqlQuery                                   = $null
    );

    try {
      $SqlCommand             = New-Object System.Data.SqlClient.SqlCommand;
      $SqlCommand.Connection  = $SqlConnection;
      $SqlCommand.CommandText = $SqlQuery;
    }
    catch {
       
    }
    

    return $SqlCommand;
}
