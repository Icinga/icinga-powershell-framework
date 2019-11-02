@{

# Script module or binary module file associated with this manifest.
ModuleToProcess = 'icinga-powershell-framework.psm1'

# Module version number
ModuleVersion = '0.0.1'

# ID for this module
GUID = 'fcd7a805-a41b-49f9-afee-9d17a2b76d42'

# Autor of this Moduls
Author = 'Lord Hepipud'

# Company
CompanyName = ''

# Copyright
Copyright = '(c) 2018 Lord Hepipud. Alle Rechte vorbehalten.'

# Description of this module
Description = 'Icinga 2 Windows Agent Module, which allows to entirely monitor the Windows Host system.'

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
PowerShellVersion = '3.0'

# Aus diesem Modul zu exportierende Funktionen. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Funktionen vorhanden sind.
FunctionsToExport = @( 'Use-Icinga', 'Import-IcingaLib', 'Publish-IcingaModuleManifests', 'Get-IcingaPluginDir', 'Get-IcingaCustomPluginDir', 'Get-IcingaCacheDir', 'Get-IcingaPowerShellConfigDir', 'Get-IcingaFrameworkRootPath', 'Get-IcingaPowerShellModuleFile' )

# Aus diesem Modul zu exportierende Cmdlets. Um optimale Leistung zu erzielen, verwenden Sie keine Plat'zhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Cmdlets vorhanden sind.
CmdletsToExport = @()

# Die aus diesem Modul zu exportierenden Variablen
VariablesToExport = '*'

# Aus diesem Modul zu exportierende Aliase. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Aliase vorhanden sind.
AliasesToExport = @()

# Aus diesem Modul zu exportierende DSC-Ressourcen
# DscResourcesToExport = @()

# Liste aller Module in diesem Modulpaket
# ModuleList = @()

# Liste aller Dateien in diesem Modulpaket
# FileList = @()

# Die privaten Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen. Diese können auch eine PSData-Hashtabelle mit zusätzlichen von PowerShell verwendeten Modulmetadaten enthalten.
PrivateData = @{

    PSData = @{

        # 'Tags' wurde auf das Modul angewendet und unterstützt die Modulermittlung in Onlinekatalogen.
        # Tags = @()

        # Eine URL zur Lizenz für dieses Modul.
        # LicenseUri = ''

        # Eine URL zur Hauptwebsite für dieses Projekt.
        # ProjectUri = ''

        # Eine URL zu einem Symbol, das das Modul darstellt.
        # IconUri = ''

        # 'ReleaseNotes' des Moduls
        # ReleaseNotes = ''

    } # Ende der PSData-Hashtabelle

} # Ende der PrivateData-Hashtabelle

# HelpInfo-URI dieses Moduls
# HelpInfoURI = ''

# Standardpräfix für Befehle, die aus diesem Modul exportiert werden. Das Standardpräfix kann mit "Import-Module -Prefix" überschrieben werden.
# DefaultCommandPrefix = ''

}