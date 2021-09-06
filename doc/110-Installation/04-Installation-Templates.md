# Installation Templates - Quickstarter

In case you are in a hurry, here are some command examples you can use for installing your Icinga for Windows environment.

## How to use below examples

The installation commands and answer files are simple JSON strings, containing required information for the IMC to work with. If you use these examples as `-InstallCommand`, you will have to wrap them inside single quotes `''`:

```powershell
'{"IfW-DirectorSelfServiceKey":{"Values":["651f889ca5f364e89ed709eabde6237fb02050ff"]},"IfW-DirectorUrl":{"Values":["https://icinga.example.com/icingaweb2/director"]}}'
```

If you want to use them as answer files, you can simply copy them as mentioned below inside a simple text file without modifications. This is required if you are using the `-AnswerFile` argument.

### Usage Examples

Using the `-InstallCommand` argument for `Install-Icinga`:

```powershell
Install-Icinga -InstallCommand '{"IfW-DirectorSelfServiceKey":{"Values":["651f889ca5f364e89ed709eabde6237fb02050ff"]},"IfW-DirectorUrl":{"Values":["https://icinga.example.com/icingaweb2/director"]}}';
```

Using the `-AnswerFile` argument for `Install-Icinga`:

```powershell
Install-Icinga -AnswerFile 'C:\Users\Public\icinga_installation.json';
```

**Note:** You can use the same arguments on the `IcingaForWindows.ps1` as described in the [Getting Started](01-Getting-Started.md) page, for a full automation without user interaction.

**Note 2:** The file type must not be `.json`, it just helps representing the content properly.

## Icinga Director Self-Service API

Use the Icinga Director Self-Service API without any custom modifications and install Icinga for Windows as defined inside the Icinga Director

```powershell
{"IfW-DirectorSelfServiceKey":{"Values":["651f889ca5f364e89ed709eabde6237fb02050ff"]},"IfW-DirectorUrl":{"Values":["https://icinga.example.com/icingaweb2/director"]}}
```
