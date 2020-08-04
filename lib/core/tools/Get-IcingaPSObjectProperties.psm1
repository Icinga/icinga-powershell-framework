function Get-IcingaPSObjectProperties()
{
    param(
        $Object         = $null,
        [array]$Include = @(),
        [array]$Exclude = @()
    );

    [hashtable]$RetValue = @{};

    if ($null -eq $Object) {
        return $RetValue;
    }

    foreach ($property in $Object.PSObject.Properties) {
        [string]$DataType = $property.TypeNameOfValue;

        if ($Include.Count -ne 0 -And -Not ($Include -Contains $property.Name)) {
            continue;
        }

        if ($Exclude.Count -ne 0 -And $Exclude -Contains $property.Name) {
            continue;
        }

        if ($DataType.Contains('string') -or $DataType.Contains('int') -Or $DataType.Contains('bool')) {
            $RetValue.Add(
                $property.Name,
                $property.Value
            );
        } else {
            try {
                $RetValue.Add(
                    $property.Name,
                    (Get-IcingaPSObjectProperties -Object $property.Value)
                );
            } catch {
                $RetValue.Add(
                    $property.Name,
                    ([string]$property.Value)
                );
            }

        }
    }

    return $RetValue;
}
