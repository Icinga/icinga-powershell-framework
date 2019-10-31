<#
.SYNOPSIS
   Checks hash against filehash of a file
.DESCRIPTION
   Invoke-IcingaCheckCheckSum returns either 'OK' or 'CRITICAL', whether the check matches or not.

   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to be used to check a hash against a filehash of a file, to determine whether changes have occured.
   Based on the match result the status will change between 'OK' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS> Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt"
   [OK] CheckSum C:\Users\Icinga\Downloads\test.txt is 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B
   |0
.EXAMPLE
   PS> Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt" -Hash 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B
   [OK] CheckSum C:\Users\Icinga\Downloads\test.txt is 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B|
   0
.EXAMPLE
   PS> Invoke-IcingaCheckCheckSum -Path "C:\Users\Icinga\Downloads\test.txt" -Hash 008FB84A017F5DFDAF038DB2FDD6934E6E5D
   [CRITICAL] CheckSum C:\Users\Icinga\Downloads\test.txt 008FB84A017F5DFDAF038DB2FDD6934E6E5D9CD3C7AACE2F2168D7D93AF51E4B is not matching 008FB84A017F5DFDAF038DB2FDD6934E6E5D
   | 
   2
.PARAMETER WarningBytes
   Used to specify a string to the path of a file, which will be checked.

   The string has to be like "C:\Users\Icinga\test.txt"

.PARAMETER Algorithm
   Used to specify a string, which contains the algorithm to be used.

   Allowed algorithms: 'SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5'

.INPUTS
   System.String

.OUTPUTS
   System.String

.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckCheckSum()
{
    param(
        [string]$Path       = $null,
        [ValidateSet]('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')
        [string]$Algorithm  = 'SHA256',
        [string]$Hash       = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0
    );

        [string]$FileHash      = (Get-FileHash $Path -Algorithm $Algorithm).Hash
        $CheckSumCheck = New-IcingaCheck -Name "CheckSum $Path" -Value $FileHash;

        If(([string]::IsNullOrEmpty($Hash)) -eq $FALSE){
            $CheckSumCheck.CritIfNotMatch($Hash) | Out-Null;
        }

    return (New-IcingaCheckresult -Check $CheckSumCheck -NoPerfData $NoPerfData -Compile);
}