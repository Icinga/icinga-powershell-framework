# Upgrading Icinga PowerShell Framework

Upgrading Icinga PowerShell Framework is usually quite straightforward. 

Specific version upgrades are described below. Please note that version updates are incremental.

## Upgrading to v1.8.0 (2022-02-08)

### Service Binary

With Icinga for Windows v1.8.0 we changed on where the application will write EventLog data to. If you are using the `Icinga for Windows Service`, it is **mandatory** to upgrade to version `v1.2.0` of the service binary, **before** upgrading to Icinga for Windows v1.8.0.

Otherwise the service will not start and crash! You can either download the service binary manually from [icinga-powershell-service](https://github.com/Icinga/icinga-powershell-service/releases) or use the Icinga repository for updating:

```powershell
Update-Icinga -Name 'service';
```

After upgrading to Icinga for Windows v1.8.0, you will require to open a new Icinga shell by calling `icinga` or by using `Use-Icinga` once, to run the new migration process.

**NOTE:** In some cases the changes for the EventLog will only apply, **after** the system has been rebooted. Afterwards every Icinga for Windows EventLog entry is written in a newly created `Icinga for Windows` log.

### Custom Daemon Handling

With Icinga for Windows v1.8.0 we removed the entire list of currently available `$Global` variables:

* `$Global:IcingaThreads`
* `$Global:IcingaThreadContent`
* `$Global:IcingaThreadPool`
* `$Global:IcingaTimers`
* `$Global:IcingaDaemonData`

All of these have been centralized inside one, new variable called `$Global:Icinga`. You can read more about the structure of this `hashtable` object on the [Developer Guide](../900-Developer-Guide/00-General.md/#Data-Management).

The important change is, that in case you created custom daemons or API endpoints using on of the above globals, you will have to migrate your code to properly make use of `$Global:Icinga`, otherwise your daemons will not work anymore once you upgrade to Icinga for Windows v1.8.0.

The benefit of this change is that you no longer require to take care of synchronising global data between newly created threads, as Icinga for Windows will make the public part of `$Global:Icinga.Public` shared for every single instance automatically.

Please [contact us](https://icinga.com/company/contact/) in case you require assistance with migrating your current code to Icinga for Windows v1.8.0.

## Upgrading to v1.7.0 (2021-11-09)

### REST-Api and Api-Checks

With Icinga for Windows v1.7.0, the previously separate available components REST-Api [icinga-powershell-restapi](https://icinga.com/docs/icinga-for-windows/latest/restapi/doc/01-Introduction/) and API-Checks [icinga-powershell-apichecks](https://icinga.com/docs/icinga-for-windows/latest/apichecks/doc/01-Introduction/) are now directly baked into the Icinga PowerShell Framework. You will no longer require to install these components in addition.

**Upgrading**: If you previously installed these components, you should remove them from the system before actively using Icinga for Windows v1.7.0, as additional changes were made in this case.

```powershell
Uninstall-IcingaComponent -Name 'restapi';
Uninstall-IcingaComponent -Name 'apichecks';
```

## Upgrading to v1.5.0 (2021-06-02)

### `SecureString` and Icinga Director Baskets

We have updated the configuration baskets generator to set arguments defined as `SecureString` (for passwords) to `hidden` within the Icinga Director. This will prevent users from simply gaining access to a password while having access to the Director.

Please update manually all your CustomFields under `Icinga Director` -> `Define Data Fields` -> Search for `*_Securestring_*` -> Field `Visibility` to `Hidden` before importing new configuration baskets. Otherwise you will have two data fields stored within your Icinga Director and have to enter all passwords again for your service checks.

## Upgrading to v1.4.0 (2021-03-02)

The pre-compiled configurations for each module and the result of `Get-IcingaCheckCommandConfig` have been changed. In order to use the new CheckCommand definitions for Icinga 2 you will **require** to update your entire environment to Icinga for Windows v1.4.0 **before** using the new configuration files!

## Upgrading to v1.3.0 (2020-12-01)

### Breaking Changes

#### Components

* Please have a look on the changes made on the [Icinga PowerShell Plugins](https://icinga.com/docs/windows/latest/plugins/doc/30-Upgrading-Plugins/) for a smooth upgrade process

#### Icinga PowerShell Kickstart

* In order to be able to use the [Icinga PowerShell Kickstart Script](https://github.com/Icinga/icinga-powershell-kickstart) with v1.3.0 of the Icinga PowerShell Framework, you will have to upgrade the kickstart script to [v1.2.0](https://github.com/Icinga/icinga-powershell-kickstart/releases)

## Upgrading to v1.2.0 (2020-08-28)

### Behavior changes

#### Changes on check command execution

**Breaking Change/Important Note:** Check Command configuration generated by Icinga for Windows 1.2.0 require Icinga for Windows 1.2.0 or later deployed on all systems, otherwise you will run into issues with an unknown command `Exit-IcingaPluginNotInstalled` error.

As mentioned in [#95](https://github.com/Icinga/icinga-powershell-framework/issues/95) we should make sure that in case the Framework itself is not installed on a system or plugins are missing the user is informed about this. We do how ever not intend to print huge stack traces of PowerShell errors into the console, but inform in a minimalistic way about this.

For this reason we will cover with a Try-Catch statement if the `Use-Icinga` command is executed and return a proper message and error code on failures. In addition we will now check of a plugin is installed before the execution of it, ensuring that in case it is not present on the system we receive an `Unknown` message that a certain plugin is not installed or present.

To apply this new behaviour you will have to generate a new check command basket file for the Icinga Director by using `Get-IcingaCheckCommandConfig` and import the new version. Once imported and deployed, the new handling will be in effect.

## Upgrading to v1.1.0 (2020-06-02)

### Behavior changes

#### Changes on -AcceptConnections

The behaviour on how the `-AcceptConnections` argument of the setup wizard is working has been fixed. Prior to version v1.1.0 the opposite effect took place.

Previous behaviour:

Setting `-AcceptConnections 1` would continue with having to configure endpoint configurations while `-AcceptConnections 0` would open the Windows Firewall for incoming connections

New behavior:

Setting `-AcceptConnections 1` will only configure the Agent to wait for parent node(s) and open the Windows firewall for incoming traffic.
Using `-AcceptConnections 0` is now working properly by letting the Agent establish the connection to the parent node(s)

#### New wizard argument -ConvertEndpointIPConfig

With v1.1.0 a new argument is added to the wizard which will prompt a question if hostnames or FQDN for connection data from the Agent to the parent node(s) shall be converted to IP addresses. If you are unsure of the result, you can manually add `-ConvertEndpointIPConfig 0` to your finished configuration string or scripts or answer the question with `no` to keep the current behavour.

By using `-ConvertEndpointIPConfig 1` or answering the wizard question with `yes`, all endpoint configuration data for your parent node(s) are resolved from hostname/FQDN to IP Addresses if possible

#### Renames 'latest' Agent version

The value `latest` for the Icinga Agent version argument has been deprecated and replaced by `release`. For now the value is changed for you, following with a deprecation warning. Please update all your Icinga Director and script configuration.
