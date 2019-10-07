function Format-IcingaPerfDataLabel()
{
    param(
        $PerfData
    );

    $Output = ((($PerfData) -Replace ' ', '_') -Replace '[\W]', '');

    while ($Output.Contains('__')) {
        $Output = $Output.Replace('__', '_');
    }
    # Remove all special characters and spaces on label names
    return $Output;
}
