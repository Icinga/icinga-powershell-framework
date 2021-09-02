# Icinga Management Console (IMC) - Installation

We can now use the Icinga Management Console to configure our local Windows system and install every required component, or use the defined configuration as template for deployment on different hosts.

If we are not already inside the IMC, we can open it with

```powershell
icinga -Manage;
```

## Installation menu

By pressing `0` on the `main menu`, we can start the entire `Installation`:

```text
*******************************************
** Icinga for Windows Management Console **
** Copyright (c) 2021 Icinga GmbH | MIT  **
**   User environment ws-icinga\icinga   **
**  Icinga PowerShell Framework v1.6.0   **
*******************************************

What do you want to do?

[0] Installation
[1] Install components
[2] Update components
[3] Remove components
[4] Manage environment
[5] List environment

[x] Exit [c] Continue [h] Help [l] Commands [m] Main

Input (Default 0 and c): 0
```

### Optional Menu - Reconfigure/Continue

In case you already deployed a configuration before or aborted your previous attempt, you will be greeted with this menu:

```text
*******************************************
** Icinga for Windows Management Console **
** Copyright (c) 2021 Icinga GmbH | MIT  **
**   User environment ws-icinga\icinga   **
**  Icinga PowerShell Framework v1.6.0   **
*******************************************

Choose the configuration type:

[0] New configuration
[1] Continue configuration
[2] Reconfigure environment

[x] Exit [c] Continue [h] Help [l] Commands [m] Main [p] Previous

Input (Default 0 and c):
```

Here you can choose if you want to reconfigure your current setup, continue on a previous attempt or start a new configuration. In case you start a new configuration, please note that `Reconfigure environment` will only be overwritten if you actually install this configuration.

You can use `New configuration` or `Continue configuration` and even `Reconfigure environment` to modify certain setthings to have them available for automated deployment on different machines.

### Continue installation

Depending on your infrastructure, required configurations and setup type, you can now navigiate through the entire process of the installation menu and configure the environment as you want. In case you are unsure about certain menu entries, you can use `h` to show the help including an explanation of required values.
