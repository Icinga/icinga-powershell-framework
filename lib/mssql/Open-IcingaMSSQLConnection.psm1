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
   The username who connects to the database.
.PARAMETER Password
   The password of the user who connects to the database.
.PARAMETER Address
   The target hosts IP or FQDN to build up a connection.
.PARAMETER IntegratedSecurity
   Use the local account credentials to connect to the database.
   This option makes -Username and -Password obsolete.
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
        [switch]$IntegratedSecurity = $FALSE
    );

    if ($IntegratedSecurity -eq $FALSE) {
        if ([string]::IsNullOrEmpty($Username)) {
            Exit-IcingaThrowException -ExceptionType 'Input' `
                                      -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling `
                                      -CustomMessage '-Username not set and -IntegratedSecurity is false' `
                                      -Force;
        } elseif ($null -eq $Password) {
            Exit-IcingaThrowException -ExceptionType 'Input' `
                                      -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling `
                                      -CustomMessage '-Password not set and -IntegratedSecurity is false' `
                                      -Force;
        }

        $Password.MakeReadOnly()
        $SqlCredential = New-Object System.Data.SqlClient.SqlCredential($Username, $Password);
    }

     try {

        $SqlConnection                  = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server=$Address;"

        if ($IntegratedSecurity -eq $TRUE) {
            $SqlConnection.ConnectionString += "Integrated Security=True;"
        }

        $SqlConnection.Credential = $SqlCredential

        Write-IcingaDebugMessage `
            -Message 'Open client connection for endpoint {0}' `
            -Objects $SqlConnection;

        $SqlConnection.Open()
    }
    catch {
       Exit-IcingaThrowException -InputString $_.Exception.Message `
                                 -StringPattern $Username `
                                 -ExceptionType 'Input' `
                                 -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling

       Exit-IcingaThrowException -InputString $_.Exception.Message `
                                 -StringPattern '40' `
                                 -ExceptionType 'Connection' `
                                 -ExceptionThrown $IcingaExceptions.Connection.SQLConnectionError
    }

    return $SqlConnection
}

