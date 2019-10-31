Import-IcingaLib core\tools;

function Get-IcingaDirectoryAll()
{
    param(
        [string]$Path,
        [array]$FileNames,
        [bool]$Recurse,
        [string]$YoungerThan,
        [string]$OlderThan,
        [string]$FileSizeGreaterThan,
        [string]$FileSizeSmallerThan
    );

    if ($Recurse -eq $TRUE) {
        $DirectoryData = Get-ChildItem -Recurse -Path $Path -Include $FileNames;
    } else {
        $DirectoryData = Get-ChildItem -Path $Path -Include $FileNames;
    }
    
    if ([string]::IsNullOrEmpty($OlderThan) -eq $FALSE -And [string]::IsNullOrEmpty($YoungerThan) -eq $FALSE) {
        $OlderThan = Set-NumericNegative (ConvertTo-Seconds $OlderThan);
        $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -lt (Get-Date).AddSeconds($OlderThan)})
        $YoungerThan = Set-NumericNegative (ConvertTo-Seconds $YoungerThan);
        $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -gt (Get-Date).AddSeconds($YoungerThan)})
    } elseif ([string]::IsNullOrEmpty($OlderThan) -eq $FALSE) {
        $OlderThan = Set-NumericNegative (ConvertTo-Seconds $OlderThan);
        $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -lt (Get-Date).AddSeconds($OlderThan)})
    } elseif ([string]::IsNullOrEmpty($YoungerThan) -eq $FALSE) {
        $YoungerThan = Set-NumericNegative (ConvertTo-Seconds $YoungerThan);
        $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -gt ((Get-Date).AddSeconds($YoungerThan))})
    }

    if ([string]::IsNullOrEmpty($FileSizeGreaterThan) -eq $FALSE) {
        $FileSizeGreaterThanValue = (Convert-Bytes $FileSizeGreaterThan -Unit B).value
        $DirectoryData = ($DirectoryData | Where-Object {$_.Length -gt $FileSizeGreaterThanValue})
    }

    if ([string]::IsNullOrEmpty($FileSizeSmallerThan) -eq $FALSE) {
        $FileSizeSmallerThanValue = (Convert-Bytes $FileSizeSmallerThan -Unit B).value
        $DirectoryData = ($DirectoryData | Where-Object {$_.Length -gt $FileSizeSmallerThanValue})
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