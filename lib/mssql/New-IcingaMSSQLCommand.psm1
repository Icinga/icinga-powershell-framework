function New-IcingaMSSQLCommand {
    param (
        [System.Data.SqlClient.SqlConnection]$SqlConnection = $null,
        [string]$SqlQuery = $null
    );
    
    $SqlCommand = $SqlConnection.CreateCommand()
    $SqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $SqlCommand.Connection = $SqlConnection
    
    $SqlCommand.CommandText = $SqlQuery

    return $SqlCommand.CommandText
}