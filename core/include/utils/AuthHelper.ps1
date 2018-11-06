Add-Type -AssemblyName System.DirectoryServices.AccountManagement;

$AuthHelper = New-Object -TypeName PSObject;

<#
 # This function will allow us to authenticate against either a
 # Domain Controller or the local machine the module runs on.
 # For security reasons, Username and Password have to be
 # stored within a SecureString. If no Domain is specified,
 # a login will always be attempted to the local machine
 #>
$AuthHelper | Add-Member -membertype ScriptMethod -name 'Login' -value {
    param([SecureString]$UserName, [SecureString]$Password, [String]$Domain);

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
        $Icinga2.Log.Write($Icinga2.Enums.LogState.Exception, $_.Exception.Message);
        return 0;
    }

    # In case we couldn't setup the Account Service, always return false
    if ($AccountService -eq $null) {
        return 0;
    }

    try {
        # Try to authenticate and either return true or false as integer
        [int]$AuthResult = [int]($AccountService.ValidateCredentials(
            $Icinga2.Utils.SecureString.ConvertFrom($UserName),
            $Icinga2.Utils.SecureString.ConvertFrom($Password)
        ));

        return $AuthResult;
    } catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Debug,
            [string]::Format(
                'Failed to authenticate with the provided user credentials. Error: {0}',
                $_.Exception.Message
            )
        );
    }

    return 0;
}

return $AuthHelper;