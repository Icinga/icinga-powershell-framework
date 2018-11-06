Introduction
==============

This PowerShell Module will provide a basic framework to retreive data from Windows Hosts. The module will work with the current common Windows Versions, starting from Windows 7 / 2008 R2. Older versions might also work, are however not official supported.

The module will execute local PowerShell scripts (modules) and return the result as formatted JSON. This result can later be parsed by any software to either do inventory or monitoring tasks.

The module provides three ways to fetch data:

* An active Rest-Api
* A passive Checker component
* PowerShell Cmdlets

The following requirements have to be fullfilled:

* Windows 7 / Windows 2008 R2 or later
* PowerShell Version 3.x or higher

If you are ready to get started, take a look on the [installation guide](02-Installation.md).