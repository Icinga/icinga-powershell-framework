function Format-IcingaPerfDataLabel()
{
    param(
        $PerfData,
        [switch]$MultiOutput = $FALSE
    );

    if ($MultiOutput) {
        return (($PerfData) -Replace '[\W]', '');
    }

    $Output = ((($PerfData) -Replace ' ', '_') -Replace '[\W]', '');

    while ($Output.Contains('__')) {
        $Output = $Output.Replace('__', '_');
    }

    # Remove all special characters and spaces on label names
    return $Output;
}
