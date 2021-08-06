function Set-IcingaAcl()
{
    param(
        [string]$Directory,
        [string]$IcingaUser = (Get-IcingaServiceUser),
        [switch]$Remove     = $FALSE
    );

    if (-Not (Test-Path $Directory)) {
        Write-IcingaConsoleWarning 'Unable to set ACL for directory "{0}". Directory does not exist' -Objects $Directory;
        return;
    }

    $DirectoryAcl        = (Get-Item -Path $Directory).GetAccessControl('Access');
    $DirectoryAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $IcingaUser,
        'Modify',
        'ContainerInherit,ObjectInherit',
        'None',
        'Allow'
    );

    if ($Remove -eq $FALSE) {
        $DirectoryAcl.SetAccessRule($DirectoryAccessRule);
    } else {
        foreach ($entry in $DirectoryAcl.Access) {
            if (([string]($entry.IdentityReference)).ToLower() -like [string]::Format('*\{0}', $IcingaUser.ToLower())) {
                $DirectoryAcl.RemoveAccessRuleSpecific($entry);
            }
        }
    }

    Set-Acl -Path $Directory -AclObject $DirectoryAcl;

    if ($Remove -eq $FALSE) {
        Test-IcingaAcl -Directory $Directory -WriteOutput | Out-Null;
    }
}
