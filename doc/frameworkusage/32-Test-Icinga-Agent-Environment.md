# Test Icinga Agent Environment

The Icinga PowerShell Framework is shipping wish a bunch of Cmdlets to manage the Icinga Agent in a very easy way. This includes a test for the entire configuration and state of the Icinga Agent on the machine.

**Note:** Before using any of the commands below you will have to initialize the Icinga PowerShell Framework inside a new PowerShell instance with `Use-Icinga`. Starting with version `1.2.0` of the Framework you can also simply type `icinga` into the command line.

## Testing for errors

A very important part of an Agent is to ensure that it is running properly and no configuration error is present. In addition it is important that required directories are accessable by the service user the Icinga Agent is running with. For this you can use the Cmdlet `Test-IcingaAgent`:

```powershell
Test-IcingaAgent;`
```

Once executed you will receive a status of tests which are performed:

```text
[Passed]: Icinga Agent service is installed
[Passed]: The specified user "NT AUTHORITY\NetworkService" is allowed to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Directory "C:\ProgramData\icinga2\var" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Directory "C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework\cache" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Icinga Agent configuration is valid
[Passed]: Icinga Agent debug log is disabled
```

In order to make the Icinga Agent and the Icinga PowerShell Framework work properly, all above mentioned tests have to be in the state `Passed`. An exception is the `debug log` which will simply print a warning in case it is activated as this should be for short term tests only and not for production environments:

```text
[Passed]: Icinga Agent service is installed
[Passed]: The specified user "NT AUTHORITY\NetworkService" is allowed to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Directory "C:\ProgramData\icinga2\var" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Directory "C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework\cache" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Icinga Agent configuration is valid
[Warning]: The debug log of the Icinga Agent is enabled. Please keep in mind to disable it once testing is done, as a huge amount of data is generated
```

## Handling of errors

In addition for testing, the Icinga PowerShell Framework will suggest methods to fix certain issues. One example is the missing permission for service users to access required directories. In case the service user is not granted permissions, chances are high that the Icinga Agent service will not start:

```text
[Passed]: Icinga Agent service is installed
[Passed]: The specified user "NT AUTHORITY\NetworkService" is allowed to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Failed]: Directory "C:\ProgramData\icinga2\var" is not accessible by the Icinga Service User "NT AUTHORITY\NetworkService"
\_ Please run the following command to fix this issue: Set-IcingaAcl -Directory 'C:\ProgramData\icinga2\var'
[Passed]: Directory "C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework\cache" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Icinga Agent configuration is valid
[Passed]: Icinga Agent debug log is disabled
```

As you can see, the mandatory directory `C:\ProgramData\icinga2\var` is not accessable by our `NT AUTHORITY\NetworkService` user. To resolve this, the Framework provides the Cmdlet `Set-IcingaAcl`. It will automatically set the correct permissions for a specific directory for the service user the Icinga Agent is running with:

```powershell
Set-IcingaAcl -Directory 'C:\ProgramData\icinga2\var';
```

```text
[Passed]: Directory "C:\ProgramData\icinga2\var" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
```

Now if we run the test again, the issue is resolved:

```text
[Passed]: Icinga Agent service is installed
[Passed]: The specified user "NT AUTHORITY\NetworkService" is allowed to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Directory "C:\ProgramData\icinga2\var" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Directory "C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework\cache" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Icinga Agent configuration is valid
[Passed]: Icinga Agent debug log is disabled
```

## Handling of configuration errors

Once in a while it might happen that your Icinga Agent configuration throws an error. By using  `Test-IcingaAgent` you will be notified about this issue:

```powershell
Test-IcingaAgent;`
```

```text
[Passed]: Icinga Agent service is installed
[Passed]: The specified user "NT AUTHORITY\NetworkService" is allowed to run as service
[Passed]: Directory "C:\ProgramData\icinga2\etc" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Directory "C:\ProgramData\icinga2\var" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Passed]: Directory "C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework\cache" is accessible and writeable by the Icinga Service User "NT AUTHORITY\NetworkService"
[Failed]: Icinga Agent configuration contains errors. Run this command for getting a detailed error report: "Test-IcingaAgentConfig -WriteStackTrace | Out-Null"
[Passed]: Icinga Agent debug log is disabled
```

As our configuration is for some reason broken we have to resolve this. The Icinga PowerShell Framework is not able to do this automatically, but it provides the toolset to easily address the source of the issue with the Cmdlet `Test-IcingaAgentConfig`:

```powershell
Test-IcingaAgentConfig -WriteStackTrace | Out-Null;
```

By using the argument `-WriteStackTrace` we will print the actual error ouptut from the Icinga Agent binary to our console for troubleshooting:

```text
[2020-08-12 16:54:26 +0200] information/cli: Icinga application loader (version: v2.12.0)
[2020-08-12 16:54:26 +0200] information/cli: Loading configuration file(s).
[2020-08-12 16:54:26 +0200] critical/config: Error: syntax error, unexpected T_IDENTIFIER
Location: in C:\ProgramData\icinga2\etc\icinga2/icinga2.conf: 20:6-20:11
C:\ProgramData\icinga2\etc\icinga2/icinga2.conf(18):  */
C:\ProgramData\icinga2\etc\icinga2/icinga2.conf(19): include "zones.conf"
C:\ProgramData\icinga2\etc\icinga2/icinga2.conf(20): this config is broken!
                                                          ^^^^^^
C:\ProgramData\icinga2\etc\icinga2/icinga2.conf(21): /**
C:\ProgramData\icinga2\etc\icinga2/icinga2.conf(22):  * The Icinga Template Library (ITL) provides a number of useful templates


[2020-08-12 16:54:26 +0200] critical/cli: Config validation failed. Re-run with 'icinga2 daemon -C' after fixing the config.
```

As we are now having the path to our configuration error, we can start to resolve it.
