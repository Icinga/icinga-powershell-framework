
function Set-NumericNegative()
{
    param(
        $Value
    );

    $Value = $Value * -1;

    return $Value;
}