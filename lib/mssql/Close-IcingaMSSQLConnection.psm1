<#
.SYNOPSIS
   Closes a open connection to a MSSQL server
.DESCRIPTION
   This Cmdlet will close an open connection to a MSSQL server.
.FUNCTIONALITY
   Closes an open connection to a MSSQL server.
.EXAMPLE
   PS>Close-IcingaMSSQLConnection $OpenMSSQLConnection;
.INPUTS
   System.Data.SqlClient.SqlConnection
.OUTPUTS
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Close-IcingaMSSQLConnection()
{
    param (
        [System.Data.SqlClient.SqlConnection]$SqlConnection = $null
    );

    if ($null -eq $SqlConnection) {
        return;
    }

    Write-IcingaDebugMessage `
        -Message 'Closing client connection for endpoint {0}' `
        -Objects $SqlConnection;

    $SqlConnection.Close();
    $SqlConnection.Dispose();
    $SqlConnection = $null;
}
