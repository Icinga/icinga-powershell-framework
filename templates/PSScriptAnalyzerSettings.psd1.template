@{
    Severity     = @(
        'Error',
        'Warning',
        'Information'
    );
    IncludeRules = @(
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingInternalURLs',
        'PSAvoidUninitializedVariable',
        'PSUseApprovedVerbs',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingPlainTextForPassword',
        'PSMissingModuleManifestField',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSAvoidTrailingWhitespace',
        'PSAvoidUsingDeprecatedManifestFields',
        'PSUseToExportFieldsInManifest',
        'PSUseProcessBlockForPipelineCommand',
        'PSUseConsistentIndentation',
        'PSUseCompatibleCmdlets',
        'PSUseConsistentWhitespace',
        'PSAlignAssignmentStatement',
        'PSUseCorrectCasing'
    );
    ExcludeRules = @(
        'PSAvoidGlobalVars',
        'PSUseSingularNouns',
        'PSAvoidUsingWriteHost',
        'PSUseToExportFieldsInManifest'
    )
    Rules        = @{
        PSUseCompatibleCmdlets     = @{
            Compatibility = @("4.0")
        };
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $false
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        };
        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $true
        };
        # Disabled for the moment, as the indentation handling is not properly
        # handling multi-line arrays and hashtables
        PSUseConsistentIndentation = @{
            Enable              = $false
            Kind                = 'space'
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
        };
        PSUseConsistentWhitespace  = @{
            Enable         = $true
            CheckOpenBrace = $false
            CheckOpenParen = $true
            CheckOperator  = $false
            CheckSeparator = $true
        };
        PSAlignAssignmentStatement = @{
            Enable = $true
        };
        PSUseCorrectCasing         = @{
            Enable = $true
        };
    }
}
