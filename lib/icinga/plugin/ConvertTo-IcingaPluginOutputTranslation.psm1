function ConvertTo-IcingaPluginOutputTranslation()
{
    param (
        $Value                  = $null,
        [hashtable]$Translation = @{ }
    );

    if ($null -eq $Value) {
        return 'Nothing';
    }

    if ($null -eq $Translation -Or $Translation.Count -eq 0) {
        return $Value;
    }

    [array]$TranslationKeys   = $Translation.Keys;
    [array]$TranslationValues = $Translation.Values;
    [int]$Index               = 0;
    [bool]$FoundTranslation   = $FALSE;

    foreach ($entry in $TranslationKeys) {
        if (([string]($Value)).ToLower() -eq ([string]($entry)).ToLower()) {
            $FoundTranslation = $TRUE;
            break;
        }
        $Index += 1;
    }

    if ($FoundTranslation -eq $FALSE) {
        return $Value;
    }

    return $TranslationValues[$Index];
}
