function Set-IcingaAcl()
{
    param(
        [string]$Directory
    );

    if (-Not (Test-Path $Directory)) {
        throw 'Failed to set Acl for directory. Directory does not exist';
        return;
    }

    $DirectoryAcl        = (Get-Item -Path $Directory).GetAccessControl('Access');
    $DirectoryAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        (Get-IcingaServiceUser),
        'Modify',
        'ContainerInherit,ObjectInherit',
        'None',
        'Allow'
    );

    $DirectoryAcl.SetAccessRule($DirectoryAccessRule);
    Set-Acl -Path $Directory -AclObject $DirectoryAcl;
    Test-IcingaAcl -Directory $Directory -WriteOutput | Out-Null;
}
