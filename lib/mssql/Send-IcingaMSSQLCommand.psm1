function Send-IcingaMSSQLCommand {
    param (
        [System.Data.SqlClient.SqlCommand]$SqlCommand = $null
    );

    $Adapter = New-Object System.Data.Sql.SqlDataAdapter $SqlCommand;

    $Data    = New-Object System.Data.DataSet;
    $Adapter.Fill($Data) | Out-Null;

    return $Data.Tables;
}
