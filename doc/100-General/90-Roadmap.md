# Icinga for Windows Roadmap

## Overview

This document outlines our roadmap for the Icinga for Windows solution. It does not only cover the Icinga PowerShell Framework itself, but also plugins and other related modules.

## Milestones

The project is continuously developed and delivered as set of 3-month milestones. New features and functionality are provided within the [Icinga PowerShell Framework master branch](https://github.com/Icinga/icinga-powershell-framework) as well as other related repositories. Changes ahead on the master are always provided within the [changelog](https://github.com/Icinga/icinga-powershell-framework/blob/master/doc/31-Changelog.md) of each project.

## Icinga for Windows Roadmap / Timeline

Below is a schedule of milestones for new releases and components. The dates are rough estimates and are subject to change.

| Milestone End Date | Milestone Name | GitHub Release |
| ------------------ | -------------- | ------------------------- |
| 2020-02-19 | [1.0.0-framework] in Icinga for Windows<br>[1.0.0-plugins] in Icinga PowerShell Plugins | [Icinga for Windows 1.0.0 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.0.0) |
| 2020-03-18 | [1.0.1-framework] in Icinga for Windows | [Icinga for Windows 1.0.1 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.0.1) |
| 2020-04-16 | [1.0.2-framework] in Icinga for Windows | |
| 2020-06-02 | [1.1.0-framework] in Icinga for Windows<br>[1.1.0-plugins] in Icinga PowerShell Plugins<br>[1.0.0-restapi] in Icinga PowerShell REST-Api<br>[1.0.0-inventory] in Icinga PowerShell Inventory | [Icinga for Windows 1.1.0 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.1.0) |
| 2020-06-18 | [1.1.1-framework] in Icinga for Windows | |
| 2020-06-26 | [1.1.2-framework] in Icinga for Windows | |
| 2020-08-31 | [1.2.0-framework] in Icinga for Windows<br>[1.2.0-plugins] in Icinga PowerShell Plugins | [Icinga for Windows 1.2.0 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.2.0) |
| 2020-10-13 | [1.0.0-mssql] in Icinga PowerShell MSSQL | [Icinga PowerShell MSSQL v1.0.0 Release](https://github.com/Icinga/icinga-powershell-mssql/releases/tag/v1.0.0)
| 2020-12-01 | [1.3.0-framework] in Icinga for Windows<br>[1.3.0-plugins] in Icinga PowerShell Plugins<br>[1.2.0-kickstart] in Icinga PowerShell Kickstart | [Icinga for Windows v1.3.0](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.3.0) |
| 2021-02-04 | [1.3.1-plugins] in Icinga PowerShell Plugins | |
| 2021-06-10 | [1.0.0-hyperv] in Icinga PowerShell Hyper-V<br>[1.0.0-cluster] in Icinga PowerShell Cluster | [Icinga PowerShell Hyper-V 1.0.0 Release](https://github.com/Icinga/icinga-powershell-hyperv/releases/tag/v1.0.0)<br>[Icinga PowerShell MSSQL 1.0.0 Release](https://github.com/Icinga/icinga-powershell-mssql/releases/tag/v1.0.0) |
| 2021-03-02 | [1.4.0-framework] in Icinga for Windows<br>[1.4.0-plugins] in Icinga PowerShell Plugins | [Icinga for Windows v1.4.0 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.4.0) |
| 2021-03-10 | [1.4.1-framework] in Icinga for Windows | [Icinga for Windows v1.4.1 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.4.1) |
| 2021-06-02 | [1.5.0-framework] in Icinga for Windows<br>[1.5.0-plugins] in Icinga PowerShell Plugins | [Icinga for Windows v1.5.0 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.5.0) |
| 2021-07-07 | [1.5.1-framework] in Icinga for Windows<br>[1.5.1-plugins] in Icinga PowerShell Plugins | [Icinga for Windows v1.5.1 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.5.1) |
| 2021-07-09 | [1.3.2-framework] in Icinga for Windows<br>[1.4.2-framework] in Icinga for Windows<br>[1.5.2-framework] in Icinga for Windows | [Icinga for Windows Security Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.5.1) |
| 2021-09-07 | [1.6.0-framework] in Icinga for Windows<br>[1.6.0-plugins] in Icinga PowerShell Plugins | [Icinga for Windows v1.6.0 Release](https://icinga.com/blog/2021/09/07/releasing-icinga-for-windows-v1-6-0-easier-and-more-secure/) |
| 2021-09-15 | [1.6.1-framework] in Icinga for Windows | [Icinga for Windows v1.6.1 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.6.0) |
| 2021-11-09 | [1.7.0-framework] in Icinga for Windows<br>[1.7.0-plugins] in Icinga PowerShell Plugins | [Icinga for Windows v1.7.0 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.7.0) |
| 2021-11-12 | [1.7.1-framework] in Icinga for Windows | [Icinga for Windows v1.7.1 Release](https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.7.1) |
| 2022-02-08 | [1.8.0-framework] in Icinga for Windows | tbd |
| 2022-05-03 | [1.9.0-framework] in Icinga for Windows | tbd |

## Issue Triage & Prioritization

Opened issues, tasks and features are scheduled several times a week, labeled, and assigned to a milestone depending on the priority:

* Crash/Security: (crashes, unusable behavior, security issues, ...) issues are dealt with shortly including possible bugfix releases
* Bug/Enhancement: issues, features or tasks are assigned to the current or future milestone

## Feature List

The following list contains a bunch of features we are planning to implement into the Icinga for Windows solution

> 📌 Note: We will update this list frequently in case new milestones and/or features are available and update this list accordingly

| Priority\* | Scenario | Description/Notes |
| ---------- | -------- | ----------------- |
| 1 | Performance Improvement | Reduce the impact of loading the entire Framework to a minimum.<br><br>Issue: [#106] |
| 2 | Icinga API Integration | An easy way to communicate directly with the Icinga 2 API over Cmdlets for easier access. Authorization should be handled by certificates or user/password auth.<br><br>Issue: [#105] |
| 2 | IMC Improvement | Move most of the current features available on CLI directly into the IMC for easier management and navigation |
| 2 | Improve module caching | While running the Icinga for Windows solution as background daemon we should make sure that recurring tasks/events are properly cached. For this we will need to cache objects recursively, including arrays and hashtables<br><br>Issue: [#5]
| 2 | Improve Performance Counter Cache | We should improve the Performance Counter cache to be able to recognize if certain counter/instances are no longer present or have been added. This will resolve an issue while using the background daemon for regular tasks<br><br>Issue: [#11]
| 2 | Plugin Re-Write | We should rewrite some of current implemented plugins to use new Framework features and improve usability |
| 2 | Windows Credential Manager | Add support to read and write credential information directly from the Windows Credential Manager, allowing access to third party systems including Icinga API without having to manually specify a password for certain tasks |
| 2 | Daemon Configuration with IMC | Extend the current daemon and other registration tasks to allow to overwrite certain arguments directly over IMC and to ensure that background checks for example are directly configurable over the IMC |
| 3 | Icinga Service Recovery | By default the Icinga Agent installer is not shipping with a service recovery solution in case the service crashes. We should allow the user to configure a custom rule set on what happens if Icinga crashes and how often a restart attempt is done for example<br><br>Issue: [#40]
| 4 | Windows Update Installation | The idea behind this is for smaller customer environments to allow the installation of certain Windows updates by using Icinga for Windows. This was an initial requests and should be taken into consideration when nothing else is to do<br><br>Issue: [#7]
| 4 | Exchange Server Monitoring | Add plugins for Exchange Server monitoring in an own separate module to cover this platform |
| 4 | Active Directory Monitoring | Add plugins for Active Directory Server monitoring in an own separate module to cover this platform |

Feature Notes:

\* Feature Priorities:

1. Mandatory <br/>
2. Beneficial <br/>
3. Optional <br/>
4. Requires Sponsoring <br/>

[1.0.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/2
[1.0.0-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestones/1/
[1.0.0-restapi]: https://github.com/Icinga/icinga-powershell-restapi/releases/tag/v1.0.0
[1.0.0-inventory]: https://github.com/Icinga/icinga-powershell-inventory/releases/tag/v1.0.0
[1.0.0-mssql]: https://github.com/Icinga/icinga-powershell-mssql/milestone/1
[1.0.1-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/5
[1.0.2-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/6
[1.1.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/4
[1.1.0-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestones/2/
[1.1.1-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/8
[1.1.2-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/9
[1.2.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/7
[1.2.0-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestone/3
[1.2.0-kickstart]: https://github.com/Icinga/icinga-powershell-kickstart/milestone/1
[1.3.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/10
[1.3.2-framework]: https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.3.2
[1.3.0-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestone/4
[1.3.1-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestone/6
[1.4.0-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestone/5
[1.5.0-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestone/7
[1.5.1-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestone/9
[1.6.0-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestone/8
[1.7.0-plugins]: https://github.com/Icinga/icinga-powershell-plugins/milestone/10
[1.4.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/11
[1.4.1-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/14
[1.4.2-framework]: https://github.com/Icinga/icinga-powershell-framework/releases/tag/v1.4.2
[1.5.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/13
[1.5.1-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/17
[1.5.2-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/18
[1.6.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/15
[1.6.1-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/21
[1.7.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/16
[1.7.1-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/22
[1.8.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/19
[1.9.0-framework]: https://github.com/Icinga/icinga-powershell-framework/milestone/20
[1.0.0-hyperv]: https://github.com/Icinga/icinga-powershell-hyperv/milestone/1
[1.1.0-hyperv]: https://github.com/Icinga/icinga-powershell-hyperv/milestone/2
[1.0.0-cluster]: https://github.com/Icinga/icinga-powershell-cluster/milestone/1
[1.1.0-cluster]: https://github.com/Icinga/icinga-powershell-cluster/milestone/2
[#5]: https://github.com/Icinga/icinga-powershell-framework/issues/5
[#7]: https://github.com/Icinga/icinga-powershell-framework/issues/7
[#11]: https://github.com/Icinga/icinga-powershell-framework/issues/11
[#19]: https://github.com/Icinga/icinga-powershell-framework/issues/19
[#40]: https://github.com/Icinga/icinga-powershell-framework/issues/40
[#100]: https://github.com/Icinga/icinga-powershell-framework/issues/100
[#105]: https://github.com/Icinga/icinga-powershell-framework/issues/105
[#106]: https://github.com/Icinga/icinga-powershell-framework/issues/106
