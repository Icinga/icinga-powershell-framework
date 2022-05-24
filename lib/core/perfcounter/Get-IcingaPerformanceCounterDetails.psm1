function Get-IcingaPerformanceCounterDetails()
{
    param (
        [string]$Counter = $null
    );

    [hashtable]$RetValue = @{
        'RawCounter'      = $Counter;
        'HasValue'        = $TRUE;
        'HasInstance'     = $FALSE;
        'Category'        = '';
        'Instance'        = '';
        'Counter'         = '';
        'CounterInstance' = '';
    }

    if ([string]::IsNullOrEmpty($Counter)) {
        $RetValue.HasValue = $FALSE;

        return $RetValue;
    }

    [array]$CounterElements = $Counter.Split('\');
    [string]$Instance       = '';
    [string]$Category       = '';
    [bool]$HasInstance      = $FALSE;

    if ($CounterElements[1].Contains('(') -And $CounterElements[1].Contains(')')) {
        $HasInstance              = $TRUE;
        [int]$StartIndex          = $CounterElements[1].IndexOf('(') + 1;
        [int]$EndIndex            = $CounterElements[1].Length - $StartIndex - 1;
        $Instance                 = $CounterElements[1].Substring($StartIndex, $EndIndex);
        $RetValue.HasInstance     = $HasInstance;
        $Category                 = $CounterElements[1].Substring(0, $CounterElements[1].IndexOf('('));
        $RetValue.CounterInstance = [string]::Format('{0}_{1}', $Instance, $CounterElements[2]);
    } else {
        $Category = $CounterElements[1];
    }

    $RetValue.Category = $Category;
    $RetValue.Instance = $Instance;
    $RetValue.Counter  = $CounterElements[2];

    return $RetValue;
}
