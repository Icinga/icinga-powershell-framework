# Icinga PowerShell Framework CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](https://icinga.com/docs/windows/latest/doc/30-upgrading-framework.md/)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-framework/milestones?state=closed).

## 1.1.0 (pending)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-framework/milestone/4?closed=1)

### Notes

* [#62](https://github.com/Icinga/icinga-powershell-framework/issues/62) Deprecates `--key` argument for certificate generation for Icinga 2.12.0 and later

### Breaking changes

* The `-AcceptConnections` argument for the install wizard had the opposite effect in the previous versions. Please review your configuration on a test setup before proceeding with a mass-rollout to ensure the Agent behaves as expected

### Enhancements

* [#48](https://github.com/Icinga/icinga-powershell-framework/issues/48) Adds support to check if a check package contains any checks or check packages
* [#64](https://github.com/Icinga/icinga-powershell-framework/issues/64) Icinga Agent RC versions are no longer used by using `latest` as version
* [#67](https://github.com/Icinga/icinga-powershell-framework/issues/67) Adds support to flush entire Icinga 2 ProgamData directory on uninstallation
* [#68](https://github.com/Icinga/icinga-powershell-framework/issues/68) Improves the setup wizard by providing better understandable prompts including examples and various smaller bugfixes
* Console prints are now containing a severity message to better keep an eye on possible warnings/errors

### Bugfixes

* [#61](https://github.com/Icinga/icinga-powershell-framework/issues/61) Fixes duplicate command line entries after wizard comletion and escaping of values
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
