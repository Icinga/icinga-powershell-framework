# Install JEA

## Preparations

Before we can use JEA profiles, we require to prepare our Windows machine for this. JEA profiles require a configured and running `WinRM` service, allowing PowerShell remove executions.

The simple and easiest way, is to enable it with `Enable-PSRemoting`.

**NOTE:** Please check your local security profiles and configurations before applying these changes. This installation step is not focussing on how to secure `WinRM` in your environment and just gives an example on how you can get started. You are responsible for yourself to properly secure `WinRM`, depending on your environment.

Once `WinRM` is enabled and properly configured on your system, you can move on with installing the Icinga for Windows JEA profile

## Install Icinga for Windows JEA profile

We provide two ways on how Icinga for Windows is configured and JEA profiles are build. The easiest and most straight forward solution, is creating an own user which is managed by `Icinga for Windows` on the local system. The other option is to manually assign a user and create the profile this one.

### JEA with Icinga for Windows managed User

To fully automate the entire process and to ensure Icinga for Windows is executed with a dedicated user we run our JEA profile with, we can simply use the command `Install-IcingaSecurity`.

This command will

* install a user called `icinga` on the system
* create a JEA profile for this user

You can modify the name of the user with the `-IcingaUser` argument, to create a managed user with a different name.

```powershell
Install-IcingaSecurity -IcingaUser 'MyOwnIcingaUser';
```

The user created by this command is not added to any user group and is only permitted to be used as service user. Local logins or RDP sessions are not forbidden.

The user is created with a random, 60 digits password to ensure security. Each time the service is being modified with the user, the password is randomly re-created to ensure a valid login of the service user. The password is not stored anywhere on the Icinga for Windows context, besides the PowerShell session which is executed. However, once all actions the password is required for are completed, the variable is flushed from the memory.

If present, both services `icinga2` and `icingapowershell` are updated to use the newly created user and being restarted afterwards.

Once completed, Icinga for Windows will compile the JEA profile with the name `IcingaForWindows`.

### JEA with non-managed user

If you already use a monitoring user and create a user automatically, you can simply use `Install-IcingaJEAProfile`, by providing the user the profile is created for. The default user is set to `IcingaForWindows`, but can be overwritten.

```powershell
Install-IcingaJEAProfile -IcingaUser 'MyOwnIcingaUser';
```

This will create the JEA profile files and register them, but not modify any services or user data.

## Additional Management

There are additional arguments available for `Install-IcingaJEAProfile`, which can be used to change the behaviour a little.

| Argument | Type | Description |
| ---      | ---  | ---         |
| IcingaUser | String | The name of the user the JEA profile is created for |
| ConstrainedLanguage | Switch | Will create the JEA profile with language mode `ConstrainedLanguage` instead of `FullLanguage`, for increased security. Please note that the `Icinga for Windows service` will not work with this configuration |
| TestEnv  | Switch | By enabling this flag, a second JEA test profile is created for the current using running the PowerShell for testing purpose. The profile is called `IcingaForWindowsTest` |

## Creating Test Environment with existing Profile

If you already created a profile with `Install-IcingaJEAProfile`, you can simply register a test environment for the current user, not requiring a full-rebuild of the JEA profile.

```powershell
Register-IcingaJEAProfile -TestEnv
```

`Register-IcingaJEAProfile` supports the same arguments as listed above for `Install-IcingaJEAProfile`.

## Update JEA Profiles

To update your JEA profiles after you updated components or made modifications for yourself, you can rebuild the profile by using `Install-IcingaJEAProfile` with any of the above mentioned arguments or use the alias `Update-IcingaJEAProfile`, which does the same and is just named differently.

```powershell
Update-IcingaJEAProfile -IcingaUser 'MyOwnIcingaUser';
```

## Use JEA profile

### Use test environment JEA

If you used `TestEnv` to create a test environment for JEA for the current user, you can simply enter the PowerShell JEA session with this command:

```powershell
powershell.exe -NoProfile -ConfigurationName 'IcingaForWindowsTest';
```

This will open a new `remote` PowerShell session over `WinRM` on the local machine with the provided JEA profile 'IcingaForWindowsTest'.
