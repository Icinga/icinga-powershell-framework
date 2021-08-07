function Get-IcingaHelpThresholds()
{
    param (
        $Value,
        $Warning,
        $Critical
    );

    if ([string]::IsNullOrEmpty($Value) -eq $FALSE) {
        $ExampleCheck = New-IcingaCheck -Name 'Example' -Value $Value;
        $ExampleCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

        return (New-IcingaCheckResult -Check $ExampleCheck -Compile);
    }

    Write-IcingaConsolePlain
    '
    Icinga is providing a basic handling for thresholds to make it easier to check if certain values of metrics should rise an event or not.
    By default, you are always fine to specify simple numeric values for thresholds throughout the entire Check-Plugins.

    #####################

    -Warning  60
    -Critical 90

    This example will always raise an event, in case the value is below 0. On the other hand, it will raise
    Warning, if the value is above 60 and
    Critical, if the value is above 90.

    Example: Get-IcingaHelpThresholds -Value 40 -Warning 60 -Critical 90; #This will return Ok
             Get-IcingaHelpThresholds -Value 70 -Warning 60 -Critical 90; #This will return Warning

    There is however a smart way available, to check for ranges of metric values which are explained below.

    #####################

    Between Range
    -Warning "30:50"

    This configuration will check if a value is within the specified range. In this example it would return Ok, whenver the
    value is >= 30 and <= 50

    Example: Get-IcingaHelpThresholds -Value 40 -Warning "30:50" -Critical "10:70"; #This will return Ok
             Get-IcingaHelpThresholds -Value 20 -Warning "30:50" -Critical "10:70"; #This will return Warning
             Get-IcingaHelpThresholds -Value 5 -Warning "30:50" -Critical "10:70"; #This will return Critical

    #####################

    Outside Range
    -Warning "@40:70"

    The exact opposite of the between range. Simply write an @ before your range and it will return Ok only, if the value is
    outside the range. In this case, it will only return Ok if the value is <= 40 and >= 70

    Example: Get-IcingaHelpThresholds -Value 10 -Warning "@20:90" -Critical "@40:60"; #This will return Ok
             Get-IcingaHelpThresholds -Value 20 -Warning "@20:90" -Critical "@40:60"; #This will return Warning
             Get-IcingaHelpThresholds -Value 50 -Warning "@20:90" -Critical "@40:60"; #This will return Critical

    #####################

    Above value
    -Warning "50:"

    A threshold followed by a : will always return Ok in case the value is above the configured start value. In this case it will
    always return Ok as long as the value itself is above 50

    Example: Get-IcingaHelpThresholds -Value 100 -Warning "90:" -Critical "50:"; #This will return Ok
             Get-IcingaHelpThresholds -Value 60 -Warning "90:" -Critical "50:"; #This will return Warning
             Get-IcingaHelpThresholds -Value 10 -Warning "90:" -Critical "50:"; #This will return Critical

    #####################

    Below value
    -Warning "~:40"

    Like the above value, you can also configure a threshold to require to be lower then a certain value. In this example, every value
    below 40 will return Ok

    Example: Get-IcingaHelpThresholds -Value 20 -Warning "~:40" -Critical "~:70"; #This will return Ok
             Get-IcingaHelpThresholds -Value 60 -Warning "~:40" -Critical "~:70"; #This will return Warning
             Get-IcingaHelpThresholds -Value 90 -Warning "~:40" -Critical "~:70"; #This will return Critical

    #####################

    You can play around yourself with this by using this Cmdlet with different values and -Warning / -Critical thresholds:

    Get-IcingaHelpThresholds -Value <value> -Warning <warning> -Critical <critical>;
    ';
}
