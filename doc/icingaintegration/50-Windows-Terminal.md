# Windows Terminal Integration

The new [Windows Terminal](https://www.microsoft.com/en-US/p/windows-terminal/9n0dx20hk701?activetab=pivot:overviewtab) provided by Microsoft offers a huge flexibility when it comes to working with different kind of shells. Not only does it finally support tabs and to split the current view into separate shells, it also allows the integration of pre-defined commands to execute for loading shells or environments.

In addition we can fully customize the apperance for our needs.

## Install the Icinga Shell Configuration

To install the Icinga Shell as native shell in your Windows Terminal dropdown, simply paste the following JSON under `profiles` -> `list`

```json
{
    "fontFace" : "Consolas",
    "fontSize" : 12,
    "useAcrylic" : true,

    "guid": "{fcd7a805-a41b-49f9-afee-9d17a2b76d42}",
    "name": "Icinga",
    "commandline" : "powershell.exe -noe -c \"&{ icinga }\"",
    "hidden": false,
    "icon" : "ms-appdata:///roaming/icingawhite.png",

    "acrylicOpacity" : 0.85,
    "backgroundImage" : "ms-appdata:///roaming/icingawhite.png",
    "backgroundImageOpacity" : 0.50,
    "backgroundImageStretchMode" : "none",
    "backgroundImageAlignment" : "topRight",
    "tabTitle": "Icinga for Windows - Loading",
    "colorScheme": "Icinga-Default"
}
```

As we are using the the custom theme `Icinga-Default` we will have to add this as well directly under the `schemes` section:

```json
{
    "name" : "Icinga-Default",
    "cursorColor": "#FFFFFF",
    "selectionBackground": "#61C2FF",
    "background": "#04062A",
    "foreground" : "#EED7AA",
    // Arguments
    "black" : "#CC88DD",
    "brightBlack" : "#CC88DD",
    // Debug messages
    "blue" : "#A6A6A6",
    "brightBlue" : "#A6A6A6",
    // Strings
    "cyan" : "#39B5C6",
    "brightCyan" : "#39B5C6",
    "green" : "#31BB6C",
    "brightGreen" : "#31BB6C",
    "purple" : "#00607A",
    "brightPurple" : "#00607A",
    "red" : "#FF6B7A",
    "brightRed" : "#FF6B7A",
    // Commands
    "white" : "#FFFFFF",
    "brightWhite" : "#FFFFFF",
    // Commands/Console Input
    "yellow" : "#FFAA44",
    "brightYellow" : "#FFFFFF"
}
```

Last but not least we can setup our logo to appear on the top-right corner and as terminal icon. You can get the logo [here](https://icinga.com/docs/windows/latest/doc/images/03_windows_terminal/icingawhite.png).

To install it, copy it directly into the following path:

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState
```

Now restart your Windows Terminal and enjoy the new look and the Icinga Shell integration!

![Windows Terminal](https://icinga.com/docs/windows/latest/doc/images/03_windows_terminal/icinga_shell.png)
