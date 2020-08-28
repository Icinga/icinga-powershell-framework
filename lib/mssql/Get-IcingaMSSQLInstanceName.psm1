function Get-IcingaMSSQLInstanceName()
{
    param (
        $SqlConnection              = $null,
        [string]$Username,
        [securestring]$Password,
        [string]$Address            = "localhost",
        [int]$Port                  = 1433,
        [switch]$IntegratedSecurity = $FALSE,
        [switch]$TestConnection     = $FALSE
    );

    [bool]$NewSqlConnection = $FALSE;

    if ($null -eq $SqlConnection) {
        $SqlConnection = Open-IcingaMSSQLConnection -Username $Username -Password $Password -Address $Address -IntegratedSecurity:$IntegratedSecurity -Port $Port -TestConnection:$TestConnection;

        if ($null -eq $SqlConnection) {
            return 'Unknown';
        }

        $NewSqlConnection = $TRUE;
    }

    $Query        = 'SELECT @@servicename'
    $SqlCommand   = New-IcingaMSSQLCommand -SqlConnection $SqlConnection -SqlQuery $Query;
    $InstanceName = (Send-IcingaMSSQLCommand -SqlCommand $SqlCommand).Column1;

    if ($NewSqlConnection -eq $TRUE) {
        Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;
    }

    return $InstanceName;
}
