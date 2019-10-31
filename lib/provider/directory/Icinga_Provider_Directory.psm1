Import-IcingaLib core\tools;

function Get-IcingaDirectoryAll()
{
    param(
        [string]$Path,
        [array]$FileNames,
        [bool]$Recurse,
        [string]$ChangeTimeEqual,
        [string]$ChangeYoungerThan,
        [string]$ChangeOlderThan,
        [string]$CreationTimeEqual,
        [string]$CreationOlderThan,
        [string]$CreationYoungerThan,
        [string]$FileSizeGreaterThan,
        [string]$FileSizeSmallerThan
    );

    if ($Recurse -eq $TRUE) {
        $DirectoryData = Get-IcingaDirectoryRecurse -Path $Path -FileNames $FileNames;
    } else {
        $DirectoryData = Get-IcingaDirectory -Path $Path -FileNames $FileNames;
    }

    if ([string]::IsNullOrEmpty($ChangeTimeEqual) -eq $FALSE) {
        $DirectoryData = Get-IcingaDirectoryChangeTimeEqual -ChangeTimeEqual $ChangeTimeEqual -DirectoryData $DirectoryData;
    }

    if ([string]::IsNullOrEmpty($CreationTimeEqual) -eq $FALSE) {
        $DirectoryData = Get-IcingaDirectoryCreationTimeEqual -CreationTimeEqual $CreationTimeEqual -DirectoryData $DirectoryData;
    }

    If ([string]::IsNullOrEmpty($ChangeTimeEqual) -eq $TRUE -Or [string]::IsNullOrEmpty($CreationTimeEqual) -eq $TRUE) {
        if ([string]::IsNullOrEmpty($ChangeOlderThan) -eq $FALSE) {
            $DirectoryData = Get-IcingaDirectoryChangeOlderThan -ChangeOlderThan $ChangeOlderThan -DirectoryData $DirectoryData;
        } 
        if ([string]::IsNullOrEmpty($ChangeYoungerThan) -eq $FALSE) {
            $DirectoryData = Get-IcingaDirectoryChangeYoungerThan -ChangeYoungerThan $ChangeYoungerThan -DirectoryData $DirectoryData;
        }
        if ([string]::IsNullOrEmpty($CreationOlderThan) -eq $FALSE) {
            $DirectoryData = Get-IcingaDirectoryCreationOlderThan -CreationOlderThan $CreationOlderThan -DirectoryData $DirectoryData;
        } 
        if ([string]::IsNullOrEmpty($CreationYoungerThan) -eq $FALSE) {
            $DirectoryData = Get-IcingaDirectoryCreationYoungerThan -CreationYoungerThan $CreationYoungerThan -DirectoryData $DirectoryData;
        } 
    }
    if ([string]::IsNullOrEmpty($FileSizeGreaterThan) -eq $FALSE) {
        $DirectoryData = (Get-IcingaDirectorySizeGreaterThan -FileSizeGreaterThan $FileSizeGreaterThan -DirectoryData $DirectoryData);
    }
    if ([string]::IsNullOrEmpty($FileSizeSmallerThan) -eq $FALSE) {
        $DirectoryData = (Get-IcingaDirectorySizeSmallerThan -FileSizeSmallerThan $FileSizeSmallerThan -DirectoryData $DirectoryData);
    }

    return $DirectoryData;
}



# RECURSE

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

# FILE SIZE

function Get-IcingaDirectorySizeGreaterThan()
{
    param(
        [string]$FileSizeGreaterThan,
        $DirectoryData
    );
    $FileSizeGreaterThanValue = (Convert-Bytes $FileSizeGreaterThan -Unit B).value
    $DirectoryData = ($DirectoryData | Where-Object {$_.Length -gt $FileSizeGreaterThanValue})

    return $DirectoryData;
}

function Get-IcingaDirectorySizeSmallerThan()
{
    param(
        [string]$FileSizeSmallerThan,
        $DirectoryData
    );
    $FileSizeSmallerThanValue = (Convert-Bytes $FileSizeSmallerThan -Unit B).value
    $DirectoryData = ($DirectoryData | Where-Object {$_.Length -gt $FileSizeSmallerThanValue})

    return $DirectoryData;
}

# TIME BASED CHANGE

function Get-IcingaDirectoryChangeOlderThan()
{
    param (
        [string]$ChangeOlderThan,
        $DirectoryData
    )
    $ChangeOlderThan = Set-NumericNegative (ConvertTo-Seconds $ChangeOlderThan);
    $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -lt (Get-Date).AddSeconds($ChangeOlderThan)})

    return $DirectoryData;
}

function Get-IcingaDirectoryChangeYoungerThan()
{
    param (
        [string]$ChangeYoungerThan,
        $DirectoryData
    )
    $ChangeYoungerThan = Set-NumericNegative (ConvertTo-Seconds $ChangeYoungerThan);
    $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime -gt (Get-Date).AddSeconds($ChangeYoungerThan)})

    return $DirectoryData;
}

function Get-IcingaDirectoryChangeTimeEqual()
{
    param (
        [string]$ChangeTimeEqual,
        $DirectoryData
    )
    $ChangeTimeEqual = Set-NumericNegative (ConvertTo-Seconds $ChangeTimeEqual);
    $ChangeTimeEqual = (Get-Date).AddSeconds($ChangeTimeEqual);
    $DirectoryData = ($DirectoryData | Where-Object {$_.LastWriteTime.Day -eq $ChangeTimeEqual.Day -And $_.LastWriteTime.Month -eq $ChangeTimeEqual.Month -And $_.LastWriteTime.Year -eq $ChangeTimeEqual.Year})

    return $DirectoryData;
}

# TIME BASED CREATION

function Get-IcingaDirectoryCreationYoungerThan()
{
    param (
        [string]$CreationYoungerThan,
        $DirectoryData
    )
    $CreationYoungerThan = Set-NumericNegative (ConvertTo-Seconds $CreationYoungerThan);
    $DirectoryData = ($DirectoryData | Where-Object {$_.CreationTime -gt (Get-Date).AddSeconds($CreationYoungerThan)})

    return $DirectoryData;
}

function Get-IcingaDirectoryCreationOlderThan()
{
    param (
        [string]$CreationOlderThan,
        $DirectoryData
    )
    $CreationOlderThan = Set-NumericNegative (ConvertTo-Seconds $CreationOlderThan);
    $DirectoryData = ($DirectoryData | Where-Object {$_.CreationTime -lt (Get-Date).AddSeconds($CreationOlderThan)})

    return $DirectoryData;
}

function Get-IcingaDirectoryCreationTimeEqual()
{
    param (
        [string]$CreationTimeEqual,
        $DirectoryData
    )
    $CreationTimeEqual = Set-NumericNegative (ConvertTo-Seconds $CreationTimeEqual);
    $CreationTimeEqual = (Get-Date).AddSeconds($CreationTimeEqual);
    $DirectoryData = ($DirectoryData | Where-Object {$_.CreationTime.Day -eq $CreationTimeEqual.Day -And $_.CreationTime.Month -eq $CreationTimeEqual.Month -And $_.CreationTime.Year -eq $CreationTimeEqual.Year})

    return $DirectoryData;
}