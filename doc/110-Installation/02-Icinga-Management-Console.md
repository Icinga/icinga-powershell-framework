# Icinga Management Console (IMC) - Overview

As we now have deployed our Icinga PowerShell Framework on our Windows machine, we can continue the installation by using the IMC (Icinga Management Console).

**Note:** You can always open the IMC by running the following command:

```powershell
icinga -Manage;
```

## Navigating the IMC

To navigate through the IMC, you have to use numbers and letters confirmed by pressing on `Enter`.

| Input | Name     | Description |
| ---   | ---      | ---         |
| 0-x   | Numeric  | Numeric values are used on list views to select a specific index of an entry, to either enter a sub-menu or to select it. |
| a     | Advanced | Will only occur on several forms and will show advanced options for additional configuration settings (toogle) |
| c     | Continue | Will mostly be used as default and allows you to continue. Might not always be present |
| d     | Delete   | Allows you to delete values for forms on which you have to enter data to continue |
| h     | Help     | Will either print the help for each entry and menu section or disables it (toogle) |
| l     | Command  | Will print the command being executed by the IMC for an entry (toogle) |
| m     | Main     | Allows you to jump back to the main menu |
| p     | Previous | Allows you to jump to the previous menu, in case you are not inside the root of another element |
| x     | Exit     | Will close the Management Console |

## Multi-Value Input

Some forms allow you to enter values, like your Icinga parent zone or your endpoint configuration for the Icinga Agent.

Input forms are always designed by having a (x/x) at the bottom right if your input form. The number of entries defined in the right side defines the maximum allowed entried, while the left side defines how many are currently added.

**Example:**

```text
Input (Default c) (0/1):
```

This means that we currently have `0` entries added out of a maximum of `1`.

To remove entries, we can use the `d` input and re-add our arguments. We can simply type our input as we would with the input commands:

```text
Input (Default c) (0/1): master
```

In this case, `master` would be our value we want to add and can confirm this by pressing `Enter`. If everything is successful, the result will look like this:

```text
*******************************************
** Icinga for Windows Management Console **
** Copyright (c) 2021 Icinga GmbH | MIT  **
**   User environment ws-icinga\icinga   **
**  Icinga PowerShell Framework v1.6.0   **
*******************************************

Please enter your parent Icinga zone:

 "master"

[x] Exit [c] Continue [d] Delete [h] Help [l] Commands [m] Main [p] Previous

Input (Default c) (1/1):
```
