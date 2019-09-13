function Format-IcingaPerfDataLabel()
{
    param(
        $PerfData
    );

    # Remove all special characters and spaces on label names
    return ((($PerfData) -Replace ' ', '_') -Replace '[\W]', '');
}
