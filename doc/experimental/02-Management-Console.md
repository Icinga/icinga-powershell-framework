# Experimental: Management Console

With Icinga for Windows v1.4.0, we added a new experimental feature to easier manage Icinga for Windows and the agent: The `Management Console`

It is directly build into the Framework an can be called from a PowerShell (`administrative`) with

```powershell
icinga -Manage;
```

## First Look

```powershell
***********************************************************************
**               Icinga for Windows Management Console               **
**               Copyright (c) 2021 Icinga GmbH | MIT                **
**                 User environment ws-icinga\icinga                  **
**                Icinga PowerShell Framework v1.5.0                 **
**      This is an experimental feature and might contain bugs       **
**       Please provide us with feedback, issues and input at        **
**   https://github.com/Icinga/icinga-powershell-framework/issues    **
***********************************************************************

What do you want to do?

[0] Installation
[1] Update environment
[2] Manage environment
[3] Remove components

[x] Exit [c] Continue [h] Help [m] Main

Input (Default 0 and c):
```

## Using The Management Console

Navigating inside the Management Console work as with any other console around. On the left side of the menu entries you can find a number, which you have to type in and press enter afterwards to enter this menu.
If you want to `Manage environment`, you will have to type in `2` and press `enter` to switch to the menu.

In addition, there is a bunch of other options below the menu list items, telling you what you can do. Here is a full list you can type in and press enter afterwards:

* `a` (Advanced): Will only occur on several forms and will show advanced options for additional configuration settings
* `c` (Continue): Will mostly be used as default and allows you to continue. Might not always be present
* `d` (Delete): Allows you to delete values for forms on which you have to enter data to continue
* `h` (Help): Will either print the help for each entry and menu section or disables it (toogle)
* `m` (Main): Allows you to jump back to the main menu
* `p` (Previous): Allows you to jump to the previous menu, in case you are not inside the root of another element
* `x` (Exit): Will close the Management Console

## Capabilities

Right now you can do the following tasks:

* Install Icinga Agent, Icinga for Windows and all components
* Use the Icinga Director Self-Service API
* Manage Icinga Agent features
* Remove Icinga Agent or any installed Icinga for Windows component
* Enable Icinga PowerShell Framework Features (including experimental)
* Configure installed background daemons (register/unregister)
* Start/Restart/Stop Icinga Agent and Icinga for Windows service

If you configured your Icinga Agent and Icinga for Windows setup on this machine with the Management Console, you can reconfigure the current active configuration by navigating to `Manage environment` -> `Icinga Agent` -> `Reconfigure Installation`.

Once you did your initial configuration with the new wizard, the configuration is stored within the Frameworks config and can easily and simply be adjusted from this UI or used to export your configuration command or file.

## Automation With The Management Console

To automate your setuo, you can export your configuration either as command or into a file and can use it later on a different system

### Configuration Command

```powershell
Install-Icinga -InstallCommand '{"IfW-ParentAddress":{"Values":{"icinga2":["127.0.0.1"]}},"IfW-CodeCache":{"Selection":"0"},"IfW-Hostname":{"Selection":"3"},"IfW-ParentZone":{"Values":["master"]},"IfW-Connection":{"Selection":"2"},"IfW-ParentNodes":{"Values":["icinga2"]}}';
```

### Configuration File

The configuration file is a simple `JSON` file, identical to the argument value for `-InstallCommand` above, but stored inside a file. You can load this file into the command, for easier management.

```powershell
Install-Icinga -InstallFile 'C:\Icinga2\IfW_answer.json';
```
