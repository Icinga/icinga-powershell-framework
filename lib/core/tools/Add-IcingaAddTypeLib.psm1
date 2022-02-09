<#
.SYNOPSIS
    Compiles Add-Type calls as DLL inside our cache/lib folder
.DESCRIPTION
    Allows to compile DLLs for .NET related code required for plugins
    or certain tasks on the Windows machine, not natively supported by
    PowerShell.

    All DLL files are compiled within the cache/lib folder within the Framework
    and loaded on demand in case required. Once loaded within a shell session,
    there the function will simply do nothing
.PARAMETER TypeDefinition
    The code to compile a DLL for. Like Add-Type, the code has to start with @"
    at the beginning and end with "@ at the very beginning of a new line without
    spaces or tabs
.PARAMETER TypeName
    The name of the DLL and function being generated. The '.dll' name is NOT required
.PARAMETER Force
    Allows to force create the library again and load it inside the shell
.EXAMPLE
    $TypeDefinition = @"
    /*
        Your code
    */
"@
    Add-IcingaAddTypeLib -TypeDefinition $TypeDefinition -TypeName 'Example';
#>
function Add-IcingaAddTypeLib()
{
    param (
        $TypeDefinition   = $null,
        [string]$TypeName = '',
        [switch]$Force    = $FALSE
    );

    # Do nothing if TypeDefinition is null
    if ($null -eq $TypeDefinition) {
        Write-IcingaConsoleError -Message 'Failed to add type with name "{0}". The TypeDefinition is empty' -Objects $TypeName;
        return;
    }

    # If no name is set, return an error as we require the name for identification
    if ([string]::IsNullOrEmpty($TypeName)) {
        Write-IcingaConsoleError -Message 'Failed to add type, as no name is specified';
        return;
    }

    # If the type does already exist within our shell, to not load it again
    if ((Test-IcingaAddTypeExist -Type $TypeName) -And $Force -eq $FALSE) {
        return;
    }

    # Get our DLL folder
    [string]$DLLFolder = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'dll');

    if ((Test-Path $DLLFolder) -eq $FALSE) {
        New-Item -Path $DLLFolder -ItemType 'Directory' | Out-Null;
    }

    # Update the TypeName to include .dll ending
    if ($TypeName.Contains('.dll') -eq $FALSE) {
        $TypeName = [string]::Format('{0}.dll', $TypeName);
    }

    # Create the full path to our file
    [string]$DLLPath = Join-Path -Path $DLLFolder -ChildPath $TypeName;

    # If the DLL already exist, load the DLL from disk
    if ((Test-Path $DLLPath) -And $Force -eq $FALSE) {
        Add-Type -Path $DLLPath;
        return;
    }

    # If the DLL does not exist or we use -Force, create it
    Add-Type -TypeDefinition $TypeDefinition -OutputType 'Library' -OutputAssembly $DLLPath;
    # Load the newly created DLL
    Add-Type -Path $DLLPath;
}
