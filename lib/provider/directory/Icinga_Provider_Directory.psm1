Import-IcingaLib core\tools;

function Get-IcingaDirectoryAll()
{
    param(
        [string]$Path,
        [array]$FileNames,
        [bool]$Recurse,
        [string]$YoungerThen,
        [string]$OlderThen
    );

    if ($Recurse -eq $TRUE) {
        $DirectoryData = Get-ChildItem -Recurse -Path $Path -Include $FileNames;
    } else {
        $DirectoryData = Get-ChildItem -Path $Path -Include $FileNames;
    }
    
    if ([string]::IsNullOrEmpty($OlderThen) -eq $FALSE -And [string]::IsNullOrEmpty($YoungerThen) -eq $FALSE) {
      $OlderThen = Set-NumericNegative (ConvertTo-Seconds $OlderThen);
      $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -lt (Get-Date).AddSeconds($OlderThen)})
      $YoungerThen = Set-NumericNegative (ConvertTo-Seconds $YoungerThen);
      $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -gt (Get-Date).AddSeconds($YoungerThen)})
    } elseif ([string]::IsNullOrEmpty($OlderThen) -eq $FALSE) {
      $OlderThen = Set-NumericNegative (ConvertTo-Seconds $OlderThen);
      $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -lt (Get-Date).AddSeconds($OlderThen)})
    } elseif ([string]::IsNullOrEmpty($YoungerThen) -eq $FALSE) {
      $YoungerThen = Set-NumericNegative (ConvertTo-Seconds $YoungerThen);
      $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -gt ((Get-Date).AddSeconds($YoungerThen))})
    }

    return $DirectoryData;
}

function Get-IcingaDirectory()
{
    param(
        [string]$Path,
        [array]$FileNames
    );

    $DirectoryData = Get-ChildItem -Include $FileNames -Path $Path;

    return $DirectoryData;
}

function Get-IcingaDirectoryRecurse()
{
    param(
        [string]$Path,
        [array]$FileNames
    );

    $DirectoryData = Get-ChildItem -Recurse -Include $FileNames -Path $Path;

    return $DirectoryData;
}