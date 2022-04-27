<#
    Icinga for Windows Component compilation file.
    Will be overwritten to defaults with every update and contains
    all code pre-compiled for faster execution and for providing
    private/public commands.

    Fetches the current module and file location, reads all .psm1 files and compiles them into one large environment
#>
if ($null -eq (Get-Command -Name 'Write-IcingaForWindowsComponentCompilationFile' -ErrorAction SilentlyContinue)) {
    Write-Host '[' -NoNewline;
    Write-Host 'Error' -ForegroundColor Red -NoNewline;
    Write-Host ([string]::Format(']: Failed to compile Icinga for Windows component at location "{0}", because the required function "Write-IcingaForWindowsComponentCompilationFile" is not installed. Please ensure Icinga PowerShell Framework v1.9.0 or later is installed and try again.', $MyInvocation.MyCommand.Path));

    return;
}

Write-IcingaForWindowsComponentCompilationFile `
    -ScriptRootPath $PSScriptRoot `
    -CompiledFilePath ($MyInvocation.MyCommand.Path);
