function Close-IcingaMSSQLConnection() {
    param (
        [System.Data.SqlClient.SqlConnection]$SqlConnection = $null
    )
    
    if ($null -eq $SqlConnection) {
        return;
    }

    Write-IcingaDebugMessage `
        -Message 'Closing client connection for endpoint {0}' `
        -Objects $SqlConnection;

    $SqlConnection.Close();
    $SqlConnection.Dispose();
    $SqlConnection = $null
}
