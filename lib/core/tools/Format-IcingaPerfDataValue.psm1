function Format-IcingaPerfDataValue()
{
    param(
        $PerfValue
    );

    if ((Test-Numeric $PerfValue) -eq $FALSE) {
        return $PerfValue;
    }

    # Convert our value to a string and replace ',' with a '.' to allow Icinga to parse the output
    # In addition, round every output to 6 digits
    return (([string]([math]::round($PerfValue, 6))).Replace(',', '.'));
}
