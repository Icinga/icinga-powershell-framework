<#
.SYNOPSIS
   Sends a basic auth request back to the client
.DESCRIPTION
   Sends a basic auth request back to the client
.FUNCTIONALITY
   Sends a basic auth request back to the client
.EXAMPLE
   PS>Send-IcingaWebAuthMessage -Connection $Connection;
.PARAMETER Connection
   The connection data of the Framework containing the client and stream object
.INPUTS
   System.Hashtable
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Send-IcingaWebAuthMessage()
{
    param (
        [Hashtable]$Connection = @{ }
    );

    Send-IcingaTCPClientMessage -Message (
        New-IcingaTCPClientRESTMessage `
            -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.Unauthorized) `
            -ContentBody 'Please provide your credentials for login.' `
            -BasicAuth
    ) -Stream $Connection.Stream;
}
