function Open-IcingaMSSQLConnection()
{
    param (
        [string]$Username,
        [securestring]$Password,
        [string]$Address,
        [switch]$IntegratedSecurity = $FALSE
    );

    if ([string]::IsNullOrEmpty($Username) -and $IntegratedSecurity -eq $FALSE) {
        Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling -CustomMessage '-Username not set and -IntegratedSecurity is false' -Force;
    }
    
    if ($null -ne $Password) {
        $Password = $Password.MakeReadOnly()
    }

    if ($IntegratedSecurity -eq $FALSE) {
        $sqlCredential = New-Object System.Data.SqlClient.SqlCredential($Username, $Password)
    }
    
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection

    $sqlConnection.ConnectionString = "Server=$Address;"

    if ($IntegratedSecurity) {
        $sqlConnection.ConnectionString += "Integrated Security=True;"
    }
    
    $sqlConnection.Credential = $sqlCredential

    Write-IcingaDebugMessage `
        -Message 'Open client connection for endpoint {0}' `
        -Objects $sqlConnection;


    # try catch block open connection 
    $sqlConnection.Open()

    return $sqlConnection
}
