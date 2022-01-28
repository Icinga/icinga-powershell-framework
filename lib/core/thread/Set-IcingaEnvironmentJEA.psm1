function Set-IcingaEnvironmentJEA()
{
    param (
        [bool]$JeaEnabled = $FALSE
    );

    if ($null -ne $Global:Icinga -And $Global:Icinga.ContainsKey('Protected') -And $Global:Icinga.Protected.ContainsKey('JEAContext')) {
        $Global:Icinga.Protected.JEAContext = $JeaEnabled;
    }
}
