Import-IcingaLib provider\bios;

<#
.SYNOPSIS
   Checks how many files are in a directory.

.DESCRIPTION
   Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g 'C:\Users\Icinga\Backup' contains 200 files, WARNING is set to 150, CRITICAL is set to 300. In this case the check will return CRITICAL

   More Information on https://github.com/LordHepipud/icinga-module-windows

.FUNCTIONALITY
   This module is intended to be used to check how many files and directories are within are specified path. 
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.

.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbose 3
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 19

.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbose 3
   [WARNING]: Check package "C:\Users\Icinga\Downloads" is [WARNING] (Match All)
    \_ [WARNING]: C:\Users\Icinga\Downloads is 24

.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbose 3 -YoungerThen 08.10.2018 -OlderThen 10.12.2018
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 1

.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -FileNames "*.txt","*.sql" -Warning 20 -Critical 30 -Verbose 3
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 4

.PARAMETER IcingaCheckDirectory_Int_Warning
   Used to specify a Warning threshold. In this case an integer value.

.PARAMETER IcingaCheckDirectory_Int_Critical
   Used to specify a Critical threshold. In this case an integer value.

.PARAMETER Path
   Used to specify a path.
   e.g. 'C:\Users\Icinga\Downloads'

.PARAMETER FileNames
   Used to specify an array of filenames or expressions to match against.
   
   e.g '*.txt','.sql' # Fiends all files ending with .txt and .sql

.PARAMETER Recurse
   A switch, which can be set to filter through directories recursively.

.PARAMETER YoungerThen
   String that expects input format "MM.dd.yyyy". Used to only filter for files younger then the specified date.

.PARAMETER OlderThen
   String that expects input format "MM.dd.yyyy". Used to only filter for files older then the specified date.

.INPUTS
   System.String

.OUTPUTS
   System.String

.LINK
   https://github.com/LordHepipud/icinga-module-windows

.NOTES
#>

function Invoke-IcingaCheckDirectory()
{
    param(
        [string]$Path,
        [array]$FileNames,
        [switch]$Recurse,
        [int]$IcingaCheckDirectory_Int_Critical,
        [int]$IcingaCheckDirectory_Int_Warning,
        [string]$YoungerThen,
        [string]$OlderThen,
        [int]$Verbose
    );

    if ($Recurse -eq $TRUE) {
        $FileCount = (Get-ChildItem -Include $FileNames -Recurse -Path $Path);
    } else {
        $FileCount = (Get-ChildItem -Include $FileNames -Path $Path);
    }
    
    if ($OlderThen -ne "" -And $YoungerThen -ne "") {
        $OlderThen=[datetime]::ParseExact($OlderThen,'MM.dd.yyyy',$null)
        $YoungerThen=[datetime]::ParseExact($YoungerThen,'MM.dd.yyyy',$null)
        $FileCount = ($FileCount | Where-Object {$_.LastWriteTime -lt ($OlderThen)}) #| Where-Object {$_LastWriteTime -gt ($YoungerThen)}
        $FileCount = ($FileCount | Where-Object {$_.LastWriteTime -gt ($YoungerThen)})
    } elseif ($OlderThen -ne "") {
        $OlderThen=[datetime]::ParseExact($OlderThen,'MM.dd.yyyy',$null)
        $FileCount = ($FileCount | Where-Object {$_.LastWriteTime -lt ($OlderThen)})
    } elseif ($YoungerThen -ne "") {
        $YoungerThen=[datetime]::ParseExact($YoungerThen,'MM.dd.yyyy',$null)
        $FileCount = ($FileCount | Where-Object {$_.LastWriteTime -gt ($YoungerThen)})
    }

    $DirectoryCheck = New-IcingaCheck -Name $Path -Value $FileCount.Count -NoPerfData;

    $DirectoryCheck.WarnOutOfRange(
        ($IcingaCheckDirectory_Int_Warning)
    ).CritOutOfRange(
        ($IcingaCheckDirectory_Int_Critical)
    ) | Out-Null;

    $DirectoryPackage = New-IcingaCheckPackage -Name $Path -OperatorAnd -Checks $DirectoryCheck -Verbose $Verbose;

    exit (New-IcingaCheckresult -Check $DirectoryPackage -NoPerfData $TRUE -Compile);
}
