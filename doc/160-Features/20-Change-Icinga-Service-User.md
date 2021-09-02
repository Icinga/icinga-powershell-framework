# Run Icinga Agent as other Service User

The Icinga PowerShell Framework is shipping wish a bunch of Cmdlets to manage the Icinga Agent in a very easy way. This includes changing the current assigned Service User of the Icinga Agent to another one.

**Note:** Before using any of the commands below you will have to initialize the Icinga PowerShell Framework inside a new PowerShell instance with `Use-Icinga`. Starting with version `1.2.0` of the Framework you can also simply type `icinga` into the command line.

## Getting started

There are many reasons to run the Icinga Agent as a different user than the `NT AUTHORITY\NetworkService` user. One could be additional permissions required, another could be to run the Icinga Agent as own independent user which is entirely managed by your Active Directory or locally available.

For easier integration the Icinga PowerShell Framework is providing the Cmdlet `Set-IcingaAgentServiceUser`.

This Cmdlet ships with 4 arguments which not all of them are mandatory:

| Argument      | Mandatory | Type         | Description |
| ---           | ---       | ---          | ---         |
| User          | *         | String       | The name of the user the Icinga Agent should run with. Example: `NT AUTHORITY\NetworkService`, `mydomain\icinga`, `icinga` |
| Password      |           | SecureString | If the defined user is requiring a password authentication, you define it as SecureString. This is not required for system users like `NT AUTHORITY\NetworkService` or `NT AUTHORITY\SYSTEM` |
| Service       |           | String       | The name of the service you want to modify. By default it is already set to `icinga2` |
| SetPermission |           | Switch       | If the argument is set required permissions will be set. This includes directory permissions and the permissions for users to be allowed to run as service |

## Changing the Service User

Now as we are aware on how our Cmdlet `Set-IcingaAgentServiceUser` is working, we can use it to modify our service user.

### Example 1: Change Service User to LocalSystem

Our first example will simply change the service user from `NT AUTHORITY\NetworkService` to `NT AUTHORITY\SYSTEM`:

```powershell
Set-IcingaAgentServiceUser -User 'NT AUTHORITY\SYSTEM' -SetPermission;
```

```text
[Notice]: The Icinga Service User already has permission to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writable by the Icinga Service User "NT AUTHORITY\SYSTEM"
[Passed]: Directory "C:\ProgramData\icinga2\var" is accessible and writable by the Icinga Service User "NT AUTHORITY\SYSTEM"
[Passed]: Directory "C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework\cache" is accessible and writable by the Icinga Service User "NT AUTHORITY\SYSTEM"
[Notice]: Service User successfully updated
```

As we have set the argument `-SetPermission`, all directory and service permissions have been granted. As you can see the user already had permission to run as service which means no modification was done there.

### Example 2: Change Service User to local user with password

The most common requirement will be to set the Icinga Agent Service User to either a local or domain user. This will how ever require the usage of the `-Password` argument, which is a SecureString which can not simply be parsed.

Of course the Framework provides the Cmdlet `ConvertTo-IcingaSecureString` which will properly secure a regular String into a SecureString, might how ever not be secure enough for most environments. It will depend on how you apply the configuration.

To make things easier and we only require it locally and have not many machines to deploy, we can use the Windows `Get-Credential` Cmdlet to assist us. This will pop up a promt on where we can enter the `UserName` and `Password`:

```powershell
$cred = Get-Credential -Message 'User credentials for icinga2 service:';
Set-IcingaAgentServiceUser -User $cred.UserName -Password $cred.Password;
```

In case we leave the `-SetPermission` argument aside, we simply get the update notification:

```text
[Notice]: Service User successfully updated
```

If we how ever run our Cmdlet `Test-IcingaAgent` (which is described [here](06-Test-Icinga-Installation.md)), we will receive some errors:

```text
[Failed]: The specified user "icinga" is not allowed to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writable by the Icinga Service User "icinga"
[Failed]: Directory "C:\ProgramData\icinga2\var" is not accessible by the Icinga Service User "icinga"
\_ Please run the following command to fix this issue: Set-IcingaAcl -Directory 'C:\ProgramData\icinga2\var'
```

To simply resolve this, we can run the command from above again but this time with the `-SetPermission` argument:

```powershell
$cred = Get-Credential -Message 'User credentials for icinga2 service:';
Set-IcingaAgentServiceUser -User $cred.UserName -Password $cred.Password -SetPermission;
```

```text
[Passed]: The specified user "icinga" is allowed to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writable by the Icinga Service User "icinga"
[Passed]: Directory "C:\ProgramData\icinga2\var" is accessible and writable by the Icinga Service User "icinga"
[Passed]: Directory "C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework\cache" is accessible and writable by the Icinga Service User "icinga"
[Notice]: Service User successfully updated
```

The same procedure applies to domain specific users. All you have to do is to provide the domain before the `Username`:

```text
mydomain\Username
```
