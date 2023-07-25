# JEA Profiles

Starting with Icinga for Windows v1.6.0, we are supporting JEA profiles and provide all required tools to build a profile based on installed Icinga for Windows components.

JEA stands for "Just Enough Administration" and you can read more about it on the [Microsoft Docs](https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/jea/overview).

In short, JEA allows you to limit the access to certain Cmdlets, Functions and Binaries on the system. In addition, you can grant additional privileges to users to perform tasks, which are permitted to Administrators only in general.

With JEA profiles, you can for example grant permission to certain users or group to restart a specific service, after starting a PowerShell with a specific JEA profile. You can limit the access only to this command to be executed in this elevated environment, while all other commands or services are still not manageable.

## Requirements

In order to use JEA profiles, you will require the following system requirements:

* PowerShell 5.0 or later
* WinRM service configured

## Why use JEA for Icinga for Windows

Using JEA profiles will increase security in a certain way, while also ensuring that you no longer have to manage certain permissions for the monitoring user account. Instead of granting permissions to certain services, WMI objects or anything related, each command is executed within the `System` context. By defining profiles, you can ensure that fetching of these information is possible, but not modifying the system itself.

For monitoring for example, certain `Scheduled Tasks` or even `Services` are not accessible by some users. To fetch the `vmms` service for Hyper-V for example, you need either to execute the checks in the context of `Hyper-V Administrators` or `LocalSystem`. Both are then unrestricted on how they can interact with Hyper-V, causing a possible security gap.

## What can Icinga for Windows JEA and what can't it do

Icinga for Windows provides `Cmdlets`, to automatically build a JEA profile based on your installed Icinga for Windows components. Each single used `Cmdlet` is being analyzed and checked for commands being executed, to ensure plugins have access to all required tools to properly execute them and return the plugin information.

### No hundred percent security

By default, Icinga for Windows JEA profiles are created with the PowerShell language mode `FullLanguage`. This in general allows the execution of `ScriptBlocks` and other non-blocked Cmdlets, while `ConstrainedLanguage` is more restrictive on which commands can be executed by default, prohibiting `ScriptBlocks` and modifying `global variables` later on.

If Icinga for Windows is used with the Icinga for Windows service, the `ConstrainedLanguage` flag will cause the the service to not work, as the service relies within the started PowerShell session to modify `global variables`, which is impossible in this mode. During development, we started to get rid of `ScriptBlocks` and user other methods for creating the internal threads.

### No ScriptBlocks allowed

Starting a JEA session with `FullLanguage`, will ensure that you can only execute commands you are permitted for. Any other command is not available and will be blocked. However, this changes once you create a `ScriptBlock`, because these will execute commands even when you should not be permitted to execute them. To mitigate this problem, Icinga for Windows will not add any command or module which ships with `ScriptBlocks` inside.

### Increase Icinga for Windows security

For better security, it is highly recommended to install the `Icinga PowerShell Framework` inside a context, that requires administrative privileges for making changes. By default, this would for example be `C:\Program Files\WindowsPowerShell\Modules\`.

The JEA profile generator will lookup the root folder, in which the `Icinga PowerShell Framework` is installed into and only lookup Icinga for Windows components installed there. Any other Icinga for Windows module installed on the system is not included.

This will ensure that you will require administrative privileges beforehand to modify these files, to later execute them inside the JEA context.

## Getting Started

To get started with the Icinga for Windows JEA profile, have a look on the [installation guide](02-Installation.md).
