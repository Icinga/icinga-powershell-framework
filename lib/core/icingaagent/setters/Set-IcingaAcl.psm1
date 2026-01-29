<#
.SYNOPSIS
    Configure strict ACLs for a directory so only Administrators, Domain Admins (optional)
    and the specified Icinga service user(s) have FullControl.

.DESCRIPTION
    This function validates the provided accounts, disables inheritance on the target
    directory, clears existing explicit ACL entries, sets the directory owner and
    grants FullControl recursively to the local Administrators group, an optional
    Domain Admins group and one or more Icinga service user accounts.

.PARAMETER Directory
    The path to the target directory to update ACLs for. Must be a directory path.

.PARAMETER Owner
    The account to set as owner of the directory. Default is 'Administrators'.

.PARAMETER IcingaUser
    One or more accounts (string or string[]) which should receive FullControl on
    the directory. Default is the value returned by `Get-IcingaServiceUser`.

.PARAMETER DomainName
    Optional domain name. When provided the function will also grant FullControl to
    '<DomainName>\Domain Admins'.

.OUTPUTS
    None. This function writes progress and errors to the Icinga console helpers.

.NOTES
    - Requires administrative privileges to set ownership and modify ACLs on system
      directories.
    - Intended for use on Windows hosts only.
#>
function Set-IcingaAcl()
{
    param (
        [string]$Directory    = $null,
        [string]$Owner        = 'NT AUTHORITY\SYSTEM',
        [string[]]$IcingaUser = (Get-IcingaServiceUser),
        [string]$DomainName   = ($env:USERDOMAIN).ToLower()
    );

    # First check if the directory exists
    if (-not (Test-Path -Path $Directory -PathType Container)) {
        Write-IcingaConsoleWarning -Message 'The folder does not exist: {0}' -Objects $Directory;
        return;
    }

    # Create the owner account object and validate
    try {
        $ownerAccount = New-Object System.Security.Principal.NTAccount($Owner);
        $ownerAccount.Translate([System.Security.Principal.SecurityIdentifier]) | Out-Null;
    } catch {
        Write-IcingaConsoleError -Message 'The owner account does not exist or is invalid: {0}' -Objects $Owner;
        return;
    }

    # Create and validate IcingaUser accounts
    foreach ($user in $IcingaUser) {
        try {
            $userAccount = New-Object System.Security.Principal.NTAccount($user);
            $userAccount.Translate([System.Security.Principal.SecurityIdentifier]) | Out-Null;
        } catch {
            Write-IcingaConsoleError -Message 'The user account does not exist or is invalid: {0}' -Objects $user;
            return;
        }
    }

    # Validate if the local Administrators group exists (shouldn't happen anyway)
    try {
        $adminGroup = New-Object System.Security.Principal.NTAccount('Administrators');
        $adminGroup.Translate([System.Security.Principal.SecurityIdentifier]) | Out-Null;
    } catch {
        Write-IcingaConsoleError -Message 'The local Administrators group does not exist or is invalid' -Objects $null;
        return;
    }

    [bool]$AddDomainAdmins = $TRUE;

    # Validate if the Domain Admins group exists (if DomainName is provided)
    if (-not [string]::IsNullOrEmpty($DomainName) ) {
        try {
            $domainAdminGroup = New-Object System.Security.Principal.NTAccount(([string]::Format('{0}\Domain Admins', $DomainName)));
            $domainAdminGroup.Translate([System.Security.Principal.SecurityIdentifier]) | Out-Null;
        } catch {
            # Continue in this case, just warn the user
            Write-IcingaConsoleWarning -Message 'The Domain Admins group does not exist or is invalid: {0}' -Objects ([string]::Format('{0}\Domain Admins', $DomainName));
            $AddDomainAdmins = $FALSE;
        }
    }

    try {
        # Get the ACL for the directory
        $acl = Get-Acl -Path $Directory;

        # Now disable inheritance for the parent folder
        $acl.SetAccessRuleProtection($true, $false) | Out-Null;

        # Update the owner of the folder to "Administrators" first, to ensure we don't
        # run into any exceptions
        $acl.SetOwner((New-Object System.Security.Principal.NTAccount('Administrators'))) | Out-Null;

        Write-IcingaConsoleNotice -Message 'Disabled inheritance for directory {0}' -Objects $Directory;

        # Clear all existing ACL entries to ensure we start fresh
        $acl.Access | ForEach-Object {
            $acl.RemoveAccessRule($_) | Out-Null;
        };

        Write-IcingaConsoleNotice -Message 'Cleared existing ACL entries for directory {0}' -Objects $Directory;

        # Add the permission for each defined user with Full Control
        # Only add Icinga user permissions if we are not removing them
        foreach ($user in $IcingaUser) {
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $user,
                'FullControl',
                'ContainerInherit, ObjectInherit',
                'None',
                'Allow'
            );
            $acl.AddAccessRule($rule) | Out-Null;
        }

        # Add local Administrators group (Full Control)
        $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            'Administrators',
            'FullControl',
            'ContainerInherit, ObjectInherit',
            'None',
            'Allow'
        );

        $acl.AddAccessRule($adminRule) | Out-Null;

        # We need to ensure we add Domain Admins, as most likely those will require to have access as well
        # and allow them to configure Icinga for Windows
        if ($AddDomainAdmins) {
            $domainAdminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                ([string]::Format('{0}\Domain Admins', $DomainName)),
                'FullControl',
                'ContainerInherit, ObjectInherit',
                'None',
                'Allow'
            );
            $acl.AddAccessRule($domainAdminRule) | Out-Null;
        }

        Write-IcingaConsoleNotice -Message 'Configured new ACL entries for directory {0}' -Objects $Directory;

        # Update the ACL on the directory
        Set-Acl -Path $Directory -AclObject $acl | Out-Null;

        # Let's now enable inheritance for all subfolders and files, ensuring they inherit the correct permissions
        # from the parent folder and we only require to configure permissions there
        Get-ChildItem -Path $Directory -Recurse -Force | ForEach-Object {
            try {
                $childAcl = Get-Acl -Path $_.FullName;
                $childAcl.SetAccessRuleProtection($false, $true) | Out-Null;
                # As our parent or current Acl might be owned by SYSTEM,
                # we need to set the owner to Administrators here as well to fix exceptions
                # for SYSTEM user not being allowed to own this file
                $childAcl.SetOwner((New-Object System.Security.Principal.NTAccount('Administrators'))) | Out-Null;

                Set-Acl -Path $_.FullName -AclObject $childAcl | Out-Null;
            } catch {
                Write-IcingaConsoleWarning -Message 'Failed to enable inheritance for directory {0}: {1}' -Objects $_.FullName, $_.Exception.Message;
            }
        }

        # Ensure we set the owner of the directory and all sub-items correctly
        # Set-Acl cannot do this for the SYSTEM user and ProgramData folders
        # properly, so we need to use icacls for this task
        $Result = & icacls $Directory /setowner $Owner /T /C | Out-Null;

        if ($LASTEXITCODE -ne 0) {
            Write-IcingaConsoleError -Message 'Failed to set owner "{0}" for directory {1} and its sub-items using icacls. Output: {2}' -Objects $Owner, $Directory, $Result;
        }

        $StringBuilder = New-Object System.Text.StringBuilder;
        $StringBuilder.Append('Permissions for directory "').Append($Directory).Append('" successfully configured for owner "').Append($Owner).Append('"') | Out-Null;
        $StringBuilder.Append(' and full access users (').Append(($IcingaUser -join ', ')).Append(')') | Out-Null;

        $StringBuilder.Append(' and groups (Administrators') | Out-Null;

        if ($AddDomainAdmins) {
            $StringBuilder.Append(', ').Append(([string]::Format('{0}\Domain Admins)', $DomainName))) | Out-Null;
        } else {
            $StringBuilder.Append(')') | Out-Null;
        };

        Write-IcingaConsoleNotice -Message $StringBuilder.ToString();
    } catch {
        Write-IcingaConsoleError -Message 'Failed to Update ACL for directory {0}: {1}' -Objects $Directory, $_.Exception.Message;
    }
}