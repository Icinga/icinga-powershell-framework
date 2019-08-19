function Split-IcingaCheckCommandArgs()
{
    [array]$arguments = @();
    foreach ($arg in $args) {
        $arguments += $arg;
    }

    return $arguments;
}
