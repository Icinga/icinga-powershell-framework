function Find-IcingaAgentObjects()
{
    param(
        $Find    = @(),
        $OutFile = $null
    );

    if ($Find.Length -eq 0) {
        throw 'Please specify content you want to look for';
    }

    [array]$ObjectList = (Get-IcingaAgentObjectList).Split("`r`n");
    [int]$lineIndex    = 0;
    [array]$Result     = @();

    foreach ($line in $ObjectList) {
        if ([string]::IsNullOrEmpty($line)) {
            continue;
        }

        foreach ($entry in $Find) {
            if ($line -like $entry) {
                [string]$ResultLine = [string]::Format(
                    'Line #{0} => "{1}"',
                    $lineIndex,
                    $line
                );
                $Result += $ResultLine;
            }
        }

        $lineIndex += 1;
    }

    if ([string]::IsNullOrEmpty($OutFile)) {
        Write-Output $Result;
    } else {
        Write-IcingaFileSecure -File $OutFile -Value $Result;
    }
}
