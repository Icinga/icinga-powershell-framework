<#
.SYNOPSIS
   Opens a connection to a MSSQL server
.DESCRIPTION
   This Cmdlet will open a  connection to a MSSQL server
   and returns that connection object.
.FUNCTIONALITY
   Opens a connection to a MSSQL server
.EXAMPLE
   PS>Open-IcingaMSSQLConnection -IntegratedSecurity -Address localhost;
.EXAMPLE
   PS>Open-IcingaMSSQLConnection -Username Exampleuser -Password (ConvertTo-IcingaSecureString 'examplePassword') -Address 123.125.123.2;
.PARAMETER Username
    The username for connecting to the MSSQL database
.PARAMETER Password
    The password for connecting to the MSSQL database as secure string
.PARAMETER Address
    The IP address or FQDN to the MSSQL server to connect to (default: localhost)
.PARAMETER Port
    The port of the MSSQL server/instance to connect to with the provided credentials (default: 1433)
.PARAMETER SqlDatabase
    The name of a specific database to connect to. Leave empty to connect "globaly"
.PARAMETER IntegratedSecurity
    Allows this plugin to use the credentials of the current PowerShell session inherited by
    the user the PowerShell is running with. If this is set and the user the PowerShell is
    running with can access to the MSSQL database you will not require to provide username
    and password
.PARAMETER TestConnection
    Set this if you want to return $null on connection errors during MSSQL.open() instead of
    exception messages.
.OUTPUTS
   System.Data.SqlClient.SqlConnection
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Open-IcingaMSSQLConnection()
{
    param (
        [string]$Username,
        [securestring]$Password,
        [string]$Address            = "localhost",
        [int]$Port                  = 1433,
        [string]$SqlDatabase,
        [switch]$IntegratedSecurity = $FALSE,
        [switch]$TestConnection     = $FALSE
    );

    if ($IntegratedSecurity -eq $FALSE) {
        if ([string]::IsNullOrEmpty($Username)) {
            Exit-IcingaThrowException `
                -ExceptionType 'Input' `
                -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling `
                -CustomMessage '-Username not set and -IntegratedSecurity is false' `
                -Force;
        } elseif ($null -eq $Password) {
            Exit-IcingaThrowException `
                -ExceptionType 'Input' `
                -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling `
                -CustomMessage '-Password not set and -IntegratedSecurity is false' `
                -Force;
        }

        $Password.MakeReadOnly();
        $SqlCredential = New-Object System.Data.SqlClient.SqlCredential($Username, $Password);
    }

    try {
        $SqlConnection                  = New-Object System.Data.SqlClient.SqlConnection;
        $SqlConnection.ConnectionString = "Server=$Address,$Port;";

        if ([string]::IsNullOrEmpty($SqlDatabase) -eq $FALSE) {
            $SqlConnection.ConnectionString += "Database=$SqlDatabase;";
        }

        if ($IntegratedSecurity -eq $TRUE) {
            $SqlConnection.ConnectionString += "Integrated Security=True;";
        }

        $SqlConnection.Credential = $SqlCredential;

        Write-IcingaDebugMessage `
            -Message 'Open client connection for endpoint {0}' `
            -Objects $SqlConnection;

        $SqlConnection.Open();
    } catch {

        if ($TestConnection) {
            return $null;
        }

        if ([string]::IsNullOrEmpty($Username) -eq $FALSE) {
            Exit-IcingaThrowException `
                -InputString $_.Exception.Message `
                -StringPattern $Username `
                -ExceptionType 'Input' `
                -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling;
        }

        Exit-IcingaThrowException `
            -InputString $_.Exception.Message `
            -StringPattern 'error: 40' `
            -ExceptionType 'Connection' `
            -ExceptionThrown $IcingaExceptions.Connection.MSSQLConnectionError;

        Exit-IcingaThrowException `
            -InputString $_.Exception.Message `
            -StringPattern 'error: 0' `
            -ExceptionType 'Connection' `
            -ExceptionThrown $IcingaExceptions.Connection.MSSQLConnectionError;

        Exit-IcingaThrowException `
            -InputString $_.Exception.Message `
            -StringPattern 'error: 25' `
            -ExceptionType 'Connection' `
            -ExceptionThrown $IcingaExceptions.Connection.MSSQLConnectionError;
        # Last resort
        Exit-IcingaThrowException `
            -InputString $_.Exception.Message `
            -ExceptionType 'Custom' `
            -Force;
    }

    return $SqlConnection;
}
