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
        'PSUseDeclaredVarsMoreThanAssigments',
        'PSAvoidTrailingWhitespace',
        'PSAvoidUsingDeprecatedManifestFields',
        'PSUseToExportFieldsInManifest',
        'PSAvoidUsingWriteHost',
        'PSUseProcessBlockForPipelineCommand',
        'PSUseConsistentIndentation',
        'PSUseCompatibleCmdlets',
        'PSUseConsistentWhitespace',
        'PSAlignAssignmentStatement',
        'PSUseCorrectCasing'
    );
    ExcludeRules = @(
        'PSAvoidGlobalVars',
        'PSUseSingularNouns'
    )
    Rules        = @{
        PSUseCompatibleCmdlets     = @{
            Compatibility = @("4.0")
        };
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        };
        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $true
        };
        PSUseConsistentIndentation = @{
            Enable              = $true
            Kind                = 'space'
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        };
        PSUseConsistentWhitespace  = @{
            Enable         = $true
            CheckOpenBrace = $true
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
