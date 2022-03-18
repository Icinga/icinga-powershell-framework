function Set-IcingaEnvironmentThreadName()
{
    param (
        [string]$ThreadName = ''
    );

    $Global:Icinga.Protected.ThreadName = $ThreadName;
}
