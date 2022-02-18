function Test-IcingaForWindowsComponentPublicFunctions()
{
    param (
        $FileObject         = $null,
        [string]$ModuleName = ''
    );

    if ($null -eq $FileObject -Or [string]::IsNullOrEmpty($ModuleName)) {
        return $FALSE;
    }

    # If we load the main .psm1 file of this module, add all functions inside to the public space
    if ($FileObject.Name -eq ([string]::Format('{0}.psm1', $ModuleName))) {
        return $TRUE;
    }

    [int]$RelativPathStartIndex = $FileObject.FullName.IndexOf($ModuleName) + $ModuleName.Length;
    $ModuleFileRelativePath     = $FileObject.FullName.SubString($RelativPathStartIndex, $FileObject.FullName.Length - $RelativPathStartIndex);

    if ($ModuleFileRelativePath.Contains('\public\') -Or $ModuleFileRelativePath.Contains('\plugins\') -Or $ModuleFileRelativePath.Contains('\endpoint\') -Or $ModuleFileRelativePath.Contains('\daemon\')) {
        return $TRUE;
    }

    return $FALSE;
}
