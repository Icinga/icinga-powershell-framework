<#
.SYNOPSIS
   Tests provided credentials against either the local machine or a domain controller
.DESCRIPTION
   Tests provided credentials against either the local machine or a domain controller
.FUNCTIONALITY
   Tests provided credentials against either the local machine or a domain controller
.EXAMPLE
   PS>Test-IcingaRESTCredentials $UserName $SecureUser -Password $SecurePassword;
.EXAMPLE
   PS>Test-IcingaRESTCredentials $UserName $SecureUser -Password $SecurePassword -Domain 'Example';
.PARAMETER UserName
   The username to use for login as SecureString
.PARAMETER Password
   The password to use for login as SecureString
.PARAMETER Domain
   The domain to use for login as string
.INPUTS
   System.SecureString
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaRESTCredentials()
{
    param (
        [SecureString]$UserName,
        [SecureString]$Password,
        [String]$Domain
    );

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement;

    # Base handling: We try to authenticate against a local user on the machine
    [string]$AuthMethod = [System.DirectoryServices.AccountManagement.ContextType]::Machine;
    [string]$AuthDomain = $env:COMPUTERNAME;

     # If we specify a domain, we should authenticate against our Domain
    if ([string]::IsNullOrEmpty($Domain) -eq $FALSE) {
        $AuthMethod = [System.DirectoryServices.AccountManagement.ContextType]::Domain;
        $AuthDomain = $Domain;
    }

    try {
        # Create an Account Management object based on the above determined settings
        $AccountService = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
            $AuthMethod,
            $AuthDomain
        );
    } catch {
        # Regardless of the error, print the message and return false to prevent further execution
        Write-IcingaEventMessage -EventId 1560 -Namespace 'Framework' -Objects $_.Exception;
        return $FALSE;
    }

    # In case we couldn't setup the Account Service, always return false
    if ($null -eq $AccountService) {
        return $FALSE;
    }

    try {
        # Try to authenticate and either return true or false as integer
        [bool]$AuthResult = [int]($AccountService.ValidateCredentials(
            (ConvertFrom-IcingaSecureString $UserName),
            (ConvertFrom-IcingaSecureString $Password)
        ));

        return $AuthResult;
    } catch {
        Write-IcingaEventMessage -EventId 1561 -Namespace 'Framework' -Objects $_.Exception;
    }

    return $FALSE;
}
