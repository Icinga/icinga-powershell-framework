# Icinga PowerShell Framework CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](https://icinga.com/docs/windows/latest/doc/30-upgrading-framework)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-framework/milestones?state=closed).

## 1.4.0 (pending)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/11?closed=1)

### Enhancements

* [#193](https://github.com/Icinga/icinga-powershell-framework/pull/193) Adds optional support for adding milliseconds to `Get-IcingaUnixTime` with the `-Milliseconds` argument for more detailed time comparison
* [#198](https://github.com/Icinga/icinga-powershell-framework/pull/198) Adds support to flush the content of the Icinga Agent API directory with a single Cmdlet `Clear-IcingaAgentApiDirectory`

### Bugfixes

* [#186](https://github.com/Icinga/icinga-powershell-framework/issues/186) Fixes path handling for custom local/web path sources for service binary installation
* [#188](https://github.com/Icinga/icinga-powershell-framework/pull/188) Removes hardcoded zones `director-global` and `global-zones` which were always set regardless of user specification. This fix will ensure the user has the option to add or not add these zones
* [#189](https://github.com/Icinga/icinga-powershell-framework/pull/189) Fixes wrong documented user group for accessing Performance Counter objects which should be `Performance Monitor Users`
* [#195](https://github.com/Icinga/icinga-powershell-framework/pull/195) Fix Agent installer crash on package lookup with different files in directory
* [#197](https://github.com/Icinga/icinga-powershell-framework/pull/197) Fixes progress bar appearance on check outputs for certain plugins, by disabling the entire PowerShell progress bar during the usage of Icinga for Windows

## 1.3.0 (2020-12-01)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/10?closed=1)

### Enhancements

* [#19](https://github.com/Icinga/icinga-powershell-framework/issues/19) Add support for proxy servers for web calls and re-arranges content from lib/web to lib/webserver and uses lib/web for new proxy/web calls
* [#121](https://github.com/Icinga/icinga-powershell-framework/issues/121) Adds feature allowing sharing of local variables with Icinga Shell, by using `-ArgumentList`. They can then be accessed by using `$IcingaShellArgs` with the correct array index id, following the order of items added to `-ArgumentList`
* [#134](https://github.com/Icinga/icinga-powershell-framework/pull/134) Adds Cmdlet `Test-IcingaWindowsInformation` to check if a WMI class exist and if we can fetch data from it. In addition we add support for binary value comparison with the new Cmdlet `Test-IcingaBinaryOperator`
* [#136](https://github.com/Icinga/icinga-powershell-framework/pull/136) Adds support to ignore empty check packages and return `Ok` instead of `Unknown` if `-IgnoreEmptyPackage` is set on `New-IcingaCheckPackage`
* [#137](https://github.com/Icinga/icinga-powershell-framework/issues/137) Adds Cmdlet to compare a DateTime object with the current DateTime and return the offset as Integer in seconds
* [#139](https://github.com/Icinga/icinga-powershell-framework/pull/139) Add Cmdlet `Start-IcingaShellAsUser` to open an Icinga Shell as different user for testing
* [#141](https://github.com/Icinga/icinga-powershell-framework/pull/141) Adds Cmdlet `Convert-IcingaPluginThresholds` as generic approach to convert Icinga Thresholds with units to the lowest unit of this type.
* [#142](https://github.com/Icinga/icinga-powershell-framework/pull/142) **Experimental:** Adds feature to cache the Framework code into a single file to speed up the entire loading process, mitigating the impact on performance on systems with few CPU cores. You enable disables this feature by using `Enable-IcingaFrameworkCodeCache` and `Disable-IcingaFrameworkCodeCache`. Updating the cache is done with `Write-IcingaFrameworkCodeCache`
* [#149](https://github.com/Icinga/icinga-powershell-framework/pull/149) Adds support to add Wmi permissions for a specific user and namespace with `Add-IcingaWmiPermissions`. In addition you can remove users from Wmi namespaces by using `Remove-IcingaWmiPermissions`
* [#153](https://github.com/Icinga/icinga-powershell-framework/pull/153) Adds support to add a knowledge base id to `Exit-IcingaThrowException` for easier referencing. This should mostly be used for custom messages, as we should track the main knowledge base id's inside the messages directly. Native messages should be split in a hashtable with a `Message` and `IWKB` key
* [#155](https://github.com/Icinga/icinga-powershell-framework/pull/155) Adds support to write all objects collected by `Get-IcingaWindowsInformation` into the Windows EventLog in case the debug output for the Icinga PowerShell Framework is enabled.
* [#162](https://github.com/Icinga/icinga-powershell-framework/pull/162) Adds feature to test the length of plugin custom variables during config generation and throws error in case the total length is bigger than 64 digits, as imports into the Icinga Director by using baskets is not possible otherwise
* [#163](https://github.com/Icinga/icinga-powershell-framework/pull/163) Adds native support for writing Icinga 2 configuration for plugins and allows to easy publish new configurations for modules with the new Cmdlet `Publish-IcingaPluginConfiguration`
* [#164](https://github.com/Icinga/icinga-powershell-framework/pull/164) Adds `exit` after calling `icinga` on Windows Terminal integration to ensure the shell will close in case the Icinga shell is closed
* [#168](https://github.com/Icinga/icinga-powershell-framework/pull/168) Adds support for new Icinga Director SelfService config arguments which will now ensure the wizard will run without asking questions by using the Icinga Director configuration (requires Icinga Director 1.8 or later)

### Bugfixes

* [#059](https://github.com/Icinga/icinga-powershell-framework/issues/059), [#060](https://github.com/Icinga/icinga-powershell-framework/pull/060) Fixes interface handling for multiple interfaces and returns only the main interface by fallback to routing table and adds support for Windows 2008 R2
* [#114](https://github.com/Icinga/icinga-powershell-framework/issues/114)[#146](https://github.com/Icinga/icinga-powershell-framework/pull/146) Fixes Icinga Agent API being wrongly disabled after successful certificate configuration and installation
* [#127](https://github.com/Icinga/icinga-powershell-framework/issues/127) Fixes wrong error message on failed MSSQL connection due to database not reachable by using `-IntegratedSecurity`
* [#128](https://github.com/Icinga/icinga-powershell-framework/issues/128) Fixes unhandled output from loading `System.Reflection.Assembly` which can cause weird side effects for plugin outputs
* [#130](https://github.com/Icinga/icinga-powershell-framework/issues/130) Fix crash while running services as background task to collect metrics over time by missing Performance Counter cache initialisation
* [#133](https://github.com/Icinga/icinga-powershell-framework/issues/133), [#147](https://github.com/Icinga/icinga-powershell-framework/pull/147) Fixes an issue while changing the hostname between upper/lower case which might cause unwanted exceptions on one hand but also required manual signing of requests on the CA master as the signing process was not completed
* [#138](https://github.com/Icinga/icinga-powershell-framework/issues/138) Fixes possible value overflow on `Convert-Bytes` while converting from anything larger than MB to Bytes
* [#140](https://github.com/Icinga/icinga-powershell-framework/issues/140) Fixes version fetching for not loaded modules during upgrades/plugin calls with `Get-IcingaPowerShellModuleVersion`
* [#143](https://github.com/Icinga/icinga-powershell-framework/issues/143) Fixes the annoying hint from the analyzer to check space before open brace
* [#152](https://github.com/Icinga/icinga-powershell-framework/issues/152) Fixes incorrect rendering for empty arrays which used `$null` incorrectly instead of `@()` and fixed ValidateSet which now also supports arrays as data type
* [#159](https://github.com/Icinga/icinga-powershell-framework/pull/159) Fixes crash during update of the Icinga Framework, caused by the newly introduced experimental feature for code caching
* [#165](https://github.com/Icinga/icinga-powershell-framework/pull/165) Fixes fetching for Icinga Agent certificate for REST-Api daemon on upper/lower case hostname mismatch
* [#166](https://github.com/Icinga/icinga-powershell-framework/pull/166) Fixes fetching of Icinga Agent MSI packages by correctly comparing versions to ensure we always use the latest version and fixes `release` usage for local/network drive sources
* [#167](https://github.com/Icinga/icinga-powershell-framework/pull/167) Fixes error while writing EventLog entries with too large message size
* [#177](https://github.com/Icinga/icinga-powershell-framework/pull/177) Fixes Wmi permissions to allow domain accounts while not being locally known on the system

## 1.2.0 (2020-08-28)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/7?closed=1)

### Upgrading Notes

#### Breaking change with non-equal versions

Check Command configuration generated by Icinga for Windows 1.2.0 require Icinga for Windows 1.2.0 or later deployed on all systems, otherwise you will run into issues with an unknown command `Exit-IcingaPluginNotInstalled` error.

* To properly catch errors on check execution you will have to import check commands as Director basket again by using `Get-IcingaCheckCommandConfig`. Further details can be found in the [upgrading docs](30-upgrading-framework.md)

### Notes

* Improved documentation for plenty of Cmdlets and functionality
* We have updated the handling for plugin outputs which will now only print `non Ok` values by using verbosity 0 on check plugin configuration and include `Ok` checks for packages with `non Ok` checks on verbosity 1. Additional details can be found on issue [#99](https://github.com/Icinga/icinga-powershell-framework/issues/99)
* [#80](https://github.com/Icinga/icinga-powershell-framework/issues/80) Adds wrapper function `Get-IcingaWindowsInformation` for WMI and CIM calls to properly handle config/permission errors
* [#93](https://github.com/Icinga/icinga-powershell-framework/issues/93) Adds PSScriptAnalyzer for improved and identical code quality

### Enhancements

* Adds configuration for [Windows Terminal integration](icingaintegration/50-Windows-Terminal.md)
* Adds new Cmdlet `Show-IcingaPerformanceCounterInstances` to display all available instances for Performance Counters
* [#76](https://github.com/Icinga/icinga-powershell-framework/issues/76) Adds support to test for required .NET Framework Version 4.6.0 or above before trying to install the Icinga Agent
* [#87](https://github.com/Icinga/icinga-powershell-framework/issues/87) Adds wrapper command to test new code or functionality of Framework and/or plugins
* [#88](https://github.com/Icinga/icinga-powershell-framework/issues/88) Adds Start/Stop timer functionality for performance analysis
* [#94](https://github.com/Icinga/icinga-powershell-framework/issues/94) Adds `Namespace` argument for Get-IcingaWindowsInformation for additional filtering
* [#95](https://github.com/Icinga/icinga-powershell-framework/issues/95) Improves error handling for issues by using `Use-Icinga` initialising or by calling plugins which are not installed
* [#98](https://github.com/Icinga/icinga-powershell-framework/issues/98) Adds support for SecureString as password argument on config generation
* [#99](https://github.com/Icinga/icinga-powershell-framework/issues/99) Improves plugin output with different verbosity settings
* [#100](https://github.com/Icinga/icinga-powershell-framework/issues/100), [#107](https://github.com/Icinga/icinga-powershell-framework/issues/107) Adds help for each Performance Counter Cmdlet, separates Cmdlets into single files, adds `Filter` option for `Show-IcingaPerformanceCounterCategories` and adds `Test-IcingaPerformanceCounterCategory` to test if a category exists on a system
* [#108](https://github.com/Icinga/icinga-powershell-framework/issues/108) Adds function `Show-IcingaPerformanceCounterHelp` to fetch the help of a specific Performance Counter
* [#111](https://github.com/Icinga/icinga-powershell-framework/issues/111) Improves error message on permission problems while accessing CIM/WMI objects including details on how to resolve them

### Bugfixes

* [#78](https://github.com/Icinga/icinga-powershell-framework/issues/78) Fix Icinga Agent package fetching for x86 architecture
* [#79](https://github.com/Icinga/icinga-powershell-framework/issues/79) Fix ConvertTo-Seconds to output valid numeric data with multiple digits
* [#81](https://github.com/Icinga/icinga-powershell-framework/issues/81), [#82](https://github.com/Icinga/icinga-powershell-framework/issues/82) Fix error on EventLog initialising in case `Icinga for Windows` application is not registered on new machines and throws proper error message on plugin execution on how to resolve it
* [#83](https://github.com/Icinga/icinga-powershell-framework/issues/83) Fix error on Icinga Config basket renderer for illegal ValidateSet while $null values were allowed values
* [#84](https://github.com/Icinga/icinga-powershell-framework/issues/84) Fix conversion of `ConvertTo-Seconds` and `ConvertTo-SecondsFromIcingaThresholds` while the input value is `$null`
* [#85](https://github.com/Icinga/icinga-powershell-framework/issues/85) Fix incorrect handling to empty service user password which was configured as empty `String` instead of `$null` `SecureString` object
* [#89](https://github.com/Icinga/icinga-powershell-framework/issues/89) Fix file type question during `Get-IcingaCheckCommandConfig` generation in Windows 2012 R2 and older
* [#90](https://github.com/Icinga/icinga-powershell-framework/issues/90) Fix file type question during Icinga Agent installation on Windows 2012 R2 while using a custom installation target
* [#91](https://github.com/Icinga/icinga-powershell-framework/issues/91) Fix wrong default values being set for installer arguments by using the Icinga Director Self-Service API
* [#92](https://github.com/Icinga/icinga-powershell-framework/issues/92) Fix `Set-IcingaAcl` which fails on older Windows systems with a security id error and not at all/not properly setting required permissions for directories
* [#96](https://github.com/Icinga/icinga-powershell-framework/issues/96) Re-Implements caching for Performance Counters and fixes an issue with counters sometimes returning value 0 instead of the correct value
* [#97](https://github.com/Icinga/icinga-powershell-framework/issues/97), [#101](https://github.com/Icinga/icinga-powershell-framework/issues/101), [#104](https://github.com/Icinga/icinga-powershell-framework/issues/104) Fix value digit count for Performance Counters

## 1.1.2 (2020-07-01)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/9?closed=1)

### Bugfixes

* [#74](https://github.com/Icinga/icinga-powershell-framework/issues/74) Disabling Agent features for last list item is not possible
* [#75](https://github.com/Icinga/icinga-powershell-framework/issues/75) 'notification' feature is not disabled during installation

## 1.1.1 (2020-06-18)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/8?closed=1)

### Bugfixes

* [#70](https://github.com/Icinga/icinga-powershell-framework/issues/70) Fixes zones configuration for multiple parent endpoints
* [#72](https://github.com/Icinga/icinga-powershell-framework/issues/72) Fixes installation target directory not used properly while directory exist already

## 1.1.0 (2020-06-02)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/4?closed=1)

### Notes

* [#62](https://github.com/Icinga/icinga-powershell-framework/issues/62) Deprecates `--key` argument for certificate generation for Icinga 2.12.0 and later

### Deprecations

* The value `latest` for the installation wizard argument `AgentVersion` is deprecated and has been replaced by `release`

### Breaking changes

* The `-AcceptConnections` argument for the install wizard had the opposite effect in the previous versions. Please review your configuration on a test setup before proceeding with a mass-rollout to ensure the Agent behaves as expected
* The wizard now ships with a new argument `-ConvertEndpointIPConfig` which will convert hostnames or FQDN entries for connection information to IP addresses. If you are having a CLI string available and neither want to be asked this question or change current behaviour, set the argument to 0: `-ConvertEndpointIPConfig 0`

### Enhancements

* [#48](https://github.com/Icinga/icinga-powershell-framework/issues/48) Adds support to check if a check package contains any checks or check packages
* [#64](https://github.com/Icinga/icinga-powershell-framework/issues/64) Icinga Agent RC versions are no longer used by using `latest` as version
* [#67](https://github.com/Icinga/icinga-powershell-framework/issues/67) Adds support to flush entire Icinga 2 ProgamData directory on uninstallation
* [#68](https://github.com/Icinga/icinga-powershell-framework/issues/68) Improves the setup wizard by providing better understandable prompts including examples and various smaller bugfixes
* Console prints are now containing a severity message to better keep an eye on possible warnings/errors
* [#69](https://github.com/Icinga/icinga-powershell-framework/issues/69) Improves stability of installation/uninstallation of the Agent by using different PowerShell instances for service and installation/uninstallation handling

### Bugfixes

* [#61](https://github.com/Icinga/icinga-powershell-framework/issues/61) Fixes duplicate command line entries after wizard completion and escaping of values
* [#63](https://github.com/Icinga/icinga-powershell-framework/issues/63) Adds missing port argument for certificate generation requests
* [#65](https://github.com/Icinga/icinga-powershell-framework/issues/65) Fixes icinga2.conf file while upgrading from the old PowerShell module to the new framework
* [#66](https://github.com/Icinga/icinga-powershell-framework/issues/66) Fixes boolean performance metrics from check plugins by converting them to integer

## 1.0.2 (2020-04-16)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/6?closed=1)

### Bugfixes

* Fixes crash on fetching the `latest` Icinga 2 Agent MSI installer package by ignoring RC versions

## 1.0.1 (2020-03-18)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/5?closed=1)

### Bugfixes

* Fixes crash during update of components while no update is available on stable branch
* Fixes handling of `LocalSystem` service user to prevent the framework from crashing
* Fixes an issue while trying to modify the service user with password on older Windows versions
* Fixes persistent Director Self-Service Key prompt while using unattended installation on a new system
* Fixes service user fetching by using NETBIOS name for non-domain hosts instead of full hostname

## 1.0.0 (2020-02-19)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/2?closed=1)

### Breaking changes

* If you installed the previous RC versions of the Framework, you will have to generate the Icinga Director Basket configuration again and re-import the newly generated JSON file. Please be aware that because of possible changes your old custom variables containing arguments and thresholds might not apply due to new custom variable naming and handling. Please ensure to have a backup of your Icinga Director before applying any changes

### Enhancements

* New Cmdlets for managing the Agent have been added
* Improved the install wizard to handle errors more intelligent

### Bugfixes

* General bugfixes to increase reliability, stability and performance
* Some fixes for configuration rendering for Icinga Director Baskets

## 1.0.0 RC3 (2019-12-17)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/3?closed=1)

### Bugfixes

* Fixed wrong URL for stable plugin repository (refered to Framework instead of Plugins)

## 1.0.0 RC2 (2019-12-13)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/1?closed=1)

### Enhancements

* Added Cmdlets for managing Self-Service keys
* Added fetching for interface for host address in Icinga Director
* Improved wizard to re-ask on errors

### Bugfixes

* Fixed memory leak for background daemon
* Fixed crash on Plugin Repo / Framework update
* Fixed missing NodeName configuration in Icinga Agent config

## 1.0.0 RC1 (2019-11-04)

### Notes

* Removed legacy framework code
* New release for final framework version
