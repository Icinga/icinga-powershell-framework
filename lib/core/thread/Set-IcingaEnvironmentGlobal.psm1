function Set-IcingaEnvironmentGlobal()
{
    param (
        $GlobalEnvironment = $null
    );

    if ($null -eq $GlobalEnvironment -Or $null -eq $Global:Icinga) {
        return;
    }

    if ($Global:Icinga.ContainsKey('Public') -eq $FALSE) {
        return;
    }

    $Global:Icinga.Public = $GlobalEnvironment;
}
