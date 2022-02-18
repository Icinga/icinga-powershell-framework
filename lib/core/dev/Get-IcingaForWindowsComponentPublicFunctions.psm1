function Get-IcingaForWindowsComponentPublicFunctions()
{
    param (
        $FileObject         = $null,
        [string]$ModuleName = ''
    );

    [array]$ExportFunctions = @();

    # First first if we are inside a public space
    if ((Test-IcingaForWindowsComponentPublicFunctions -FileObject $FileObject -ModuleName $ModuleName) -eq $FALSE) {
        $FileData = (Read-IcingaPowerShellModuleFile -File $FileObject.FullName);

        foreach ($entry in $FileData.FunctionList) {
            if ($entry.Contains('Global:')) {
                $ExportFunctions += $entry.Replace('Global:', '');
            }
        }

        $ExportFunctions += $FileData.ExportFunction;

        return $ExportFunctions;
    }

    $FileData         = (Read-IcingaPowerShellModuleFile -File $FileObject.FullName);
    $ExportFunctions += $FileData.FunctionList;
    $ExportFunctions += $FileData.ExportFunction;

    # If we are, add all functions we found
    return $ExportFunctions;
}
