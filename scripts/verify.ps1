#requires -Version 5.1

<#
.SYNOPSIS
Validates the codex-skills-zh repository without modifying it.

.DESCRIPTION
Checks skill metadata, invocation policies, relative Markdown links, test cases,
repository manifests, PowerShell syntax, and common sensitive-data patterns.
With -CheckInstallation, it also verifies every installed skill link. The script
exits with code 0 only when every requested check passes.

.PARAMETER CheckInstallation
Also checks that every manifested skill is linked to this repository clone.

.PARAMETER DestinationRoot
Overrides the installation root used by -CheckInstallation.
#>

[CmdletBinding()]
param(
    [switch]$CheckInstallation,
    [string]$DestinationRoot
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$repositorySkillsRoot = Join-Path $repositoryRoot 'skills'
$skillManifestPath = Join-Path $repositoryRoot 'config\skills.json'
$referenceTermsPath = Join-Path $repositoryRoot 'config\reference-terms.json'
$invocationCasesPath = Join-Path $repositoryRoot 'tests\invocation-cases.json'
$translationContractsPath = Join-Path `
    $repositoryRoot `
    'tests\translation-contracts.json'
$readmePath = Join-Path $repositoryRoot 'README.md'
# Shared helpers resolve categorized repository paths and flat installation links.
Import-Module (Join-Path $PSScriptRoot 'SkillLinks.psm1') -Force
$validationErrors = [System.Collections.Generic.List[string]]::new()
$validationWarnings = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $validationErrors.Add($Message)
}

function Add-ValidationWarning {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $validationWarnings.Add($Message)
}

function Read-JsonFile {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-ValidationError "$Label is missing: $Path"
        return $null
    }

    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 |
            ConvertFrom-Json
    } catch {
        Add-ValidationError "$Label is not valid JSON: $Path ($($_.Exception.Message))"
        return $null
    }
}

function Read-SkillFrontmatter {
    param(
        [Parameter(Mandatory)]
        [string]$SkillPath
    )

    $skillText = [System.IO.File]::ReadAllText(
        $SkillPath,
        [System.Text.UTF8Encoding]::new($false)
    )
    $frontmatterMatch = [regex]::Match(
        $skillText,
        '(?s)\A---\s*\r?\n(.*?)\r?\n---'
    )

    if (-not $frontmatterMatch.Success) {
        Add-ValidationError "SKILL.md has no valid YAML frontmatter: $SkillPath"
        return $null
    }

    $frontmatter = $frontmatterMatch.Groups[1].Value
    $nameMatch = [regex]::Match(
        $frontmatter,
        '(?m)^name:\s*["'']?([a-z0-9-]+)["'']?\s*$'
    )
    $descriptionMatch = [regex]::Match(
        $frontmatter,
        '(?m)^description:\s*(.+?)\s*$'
    )

    if (-not $nameMatch.Success) {
        Add-ValidationError "SKILL.md is missing a valid name: $SkillPath"
    }
    if (-not $descriptionMatch.Success) {
        Add-ValidationError "SKILL.md is missing a description: $SkillPath"
    }

    $unsupportedFields = [regex]::Matches(
        $frontmatter,
        '(?m)^([a-zA-Z0-9_-]+):'
    ) |
        ForEach-Object { $_.Groups[1].Value } |
        Where-Object { $_ -notin @('name', 'description') }

    foreach ($unsupportedField in $unsupportedFields) {
        Add-ValidationError (
            "SKILL.md contains unsupported frontmatter field " +
            "'$unsupportedField': $SkillPath"
        )
    }

    return [pscustomobject]@{
        Name = if ($nameMatch.Success) {
            $nameMatch.Groups[1].Value
        } else {
            ''
        }
        Description = if ($descriptionMatch.Success) {
            $descriptionMatch.Groups[1].Value.Trim().Trim('"')
        } else {
            ''
        }
        Text = $skillText
    }
}

function Get-SkillInstructionBody {
    param(
        [Parameter(Mandatory)]
        [string]$SkillText
    )

    $bodyMatch = [regex]::Match(
        $SkillText,
        '(?s)\A---\s*\r?\n.*?\r?\n---\s*\r?\n(.*)\z'
    )
    if (-not $bodyMatch.Success) {
        return ''
    }
    return $bodyMatch.Groups[1].Value
}

function Get-TextSha256 {
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
        return ([System.BitConverter]::ToString(
            $sha256.ComputeHash($bytes)
        ) -replace '-', '').ToLowerInvariant()
    } finally {
        $sha256.Dispose()
    }
}

function ConvertTo-ComparableJson {
    param(
        [AllowNull()]
        [object]$Value
    )

    return ConvertTo-Json -InputObject @($Value) -Compress -Depth 10
}

function Get-TranslationContractElements {
    param(
        [Parameter(Mandatory)]
        [string]$Body
    )

    # Git may check out text as CRLF on Windows runners; contracts are LF-based.
    $Body = $Body -replace "`r`n", "`n"

    $fencedMatches = [regex]::Matches(
        $Body,
        '(?ms)^[ \t]{0,3}```[^\r\n]*\r?\n.*?^[ \t]{0,3}```[ \t]*$'
    )
    $withoutFences = [regex]::Replace(
        $Body,
        '(?ms)^[ \t]{0,3}```[^\r\n]*\r?\n.*?^[ \t]{0,3}```[ \t]*$',
        ''
    )

    return [ordered]@{
        fenced_code_sha256 = @(
            $fencedMatches |
                ForEach-Object { Get-TextSha256 -Text $_.Value }
        )
        inline_code = @(
            [regex]::Matches(
                $withoutFences,
                '(?<!`)`([^`\r\n]+)`(?!`)'
            ) |
                ForEach-Object { $_.Groups[1].Value }
        )
        skill_invocations = @(
            [regex]::Matches(
                $withoutFences,
                '(?<![A-Za-z0-9:/])/[a-z][a-z0-9-]+'
            ) |
                ForEach-Object { $_.Value }
        )
        link_targets = @(
            [regex]::Matches(
                $withoutFences,
                '\[[^\]\r\n]+\]\(([^)\r\n]+)\)'
            ) |
                ForEach-Object { $_.Groups[1].Value }
        )
        heading_levels = @(
            [regex]::Matches($withoutFences, '(?m)^(#{1,6})\s+') |
                ForEach-Object { $_.Groups[1].Value.Length }
        )
        list_markers = @(
            [regex]::Matches(
                $withoutFences,
                '(?m)^([ \t]*(?:[-*+]|\d+\.))[ \t]+'
            ) |
                ForEach-Object { $_.Groups[1].Value }
        )
        html_comments = @(
            [regex]::Matches($withoutFences, '(?s)<!--.*?-->') |
                ForEach-Object { $_.Value }
        )
        html_tags = @(
            [regex]::Matches($withoutFences, '<[^>\r\n]+>') |
                ForEach-Object { $_.Value }
        )
        strong_marker_count = [regex]::Matches(
            $withoutFences,
            '\*\*'
        ).Count
        italic_marker_count = [regex]::Matches(
            $withoutFences,
            '(?<!_)_[^_\r\n]+_(?!_)'
        ).Count
        italic_asterisk_count = [regex]::Matches(
            $withoutFences,
            '(?<!\*)\*[^*\r\n]+\*(?!\*)'
        ).Count
    }
}

function Test-TranslationContract {
    param(
        [Parameter(Mandatory)]
        [string]$SkillName,
        [Parameter(Mandatory)]
        [string]$Body,
        [Parameter(Mandatory)]
        [object]$Contract,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$RequiredEnglishTerms,
        [switch]$RequireEnglishTerms
    )

    $bodyWithoutProtectedCode = [regex]::Replace(
        $Body,
        '(?ms)^[ \t]{0,3}```[^\r\n]*\r?\n.*?^[ \t]{0,3}```[ \t]*$',
        ''
    )
    $bodyWithoutProtectedCode = [regex]::Replace(
        $bodyWithoutProtectedCode,
        '(?<!`)`[^`\r\n]+`(?!`)',
        ''
    )
    if (-not [regex]::IsMatch(
        $bodyWithoutProtectedCode,
        '[\p{IsCJKUnifiedIdeographs}]'
    )) {
        Add-ValidationError "SKILL.md body is not translated to Chinese: $SkillName"
    }

    $currentBodySha256 = Get-TextSha256 -Text $Body
    if ($currentBodySha256 -eq [string]$Contract.source_body_sha256) {
        Add-ValidationError (
            "SKILL.md body still matches the English source baseline: " +
            $SkillName
        )
    }

    if ($RequireEnglishTerms -and $RequiredEnglishTerms.Count -lt 1) {
        Add-ValidationError (
            "Skill has no required English behavior-anchor terms: $SkillName"
        )
    }
    foreach ($requiredEnglishTerm in $RequiredEnglishTerms) {
        if ([string]::IsNullOrWhiteSpace($requiredEnglishTerm)) {
            Add-ValidationError (
                "Skill has an empty required English term: $SkillName"
            )
            continue
        }
        if ($Body.IndexOf(
            $requiredEnglishTerm,
            [System.StringComparison]::Ordinal
        ) -lt 0) {
            Add-ValidationError (
                "Translated body is missing required English term " +
                "'$requiredEnglishTerm': $SkillName"
            )
        }
    }

    $actualElements = Get-TranslationContractElements -Body $Body
    $protectedProperties = @(
        'fenced_code_sha256',
        'inline_code',
        'skill_invocations',
        'link_targets',
        'heading_levels',
        'list_markers',
        'html_comments',
        'html_tags',
        'strong_marker_count',
        'italic_marker_count',
        'italic_asterisk_count'
    )
    foreach ($propertyName in $protectedProperties) {
        $expectedJson = ConvertTo-ComparableJson -Value $Contract.$propertyName
        $actualJson = ConvertTo-ComparableJson -Value $actualElements.$propertyName
        if ($expectedJson -cne $actualJson) {
            Add-ValidationError (
                "Translation changed protected '$propertyName' content: " +
                $SkillName
            )
        }
    }
}

function Test-MarkdownRelativeLinks {
    param(
        [Parameter(Mandatory)]
        [string]$MarkdownPath,
        [Parameter(Mandatory)]
        [string]$MarkdownText
    )

    $markdownDirectory = Split-Path -Parent $MarkdownPath
    $linkMatches = [regex]::Matches(
        $MarkdownText,
        '\[[^\]]+\]\((?!https?://|mailto:|#)([^)\s]+)(?:\s+"[^"]*")?\)'
    )

    foreach ($linkMatch in $linkMatches) {
        $relativeTarget = [System.Uri]::UnescapeDataString(
            $linkMatch.Groups[1].Value
        )
        $targetWithoutAnchor = $relativeTarget.Split('#')[0]
        # The wayfinder template uses "(link)" as a user-filled URL placeholder.
        if ($targetWithoutAnchor -eq 'link') {
            continue
        }
        if ([string]::IsNullOrWhiteSpace($targetWithoutAnchor)) {
            continue
        }

        $resolvedTarget = Join-Path $markdownDirectory $targetWithoutAnchor
        if (-not (Test-Path -LiteralPath $resolvedTarget)) {
            Add-ValidationError (
                "Broken relative Markdown link '$relativeTarget' in " +
                "$MarkdownPath"
            )
        }
    }
}

function Test-OpenAiPolicy {
    param(
        [Parameter(Mandatory)]
        [string]$SkillDirectory,
        [Parameter(Mandatory)]
        [string]$SkillName,
        [Parameter(Mandatory)]
        [bool]$AllowImplicitInvocation
    )

    $openAiYamlPath = Join-Path $SkillDirectory 'agents\openai.yaml'
    if (-not (Test-Path -LiteralPath $openAiYamlPath -PathType Leaf)) {
        Add-ValidationError "agents/openai.yaml is missing: $SkillDirectory"
        return
    }

    $openAiYamlText = [System.IO.File]::ReadAllText(
        $openAiYamlPath,
        [System.Text.UTF8Encoding]::new($false)
    )
    $displayNameMatch = [regex]::Match(
        $openAiYamlText,
        '(?m)^\s{2}display_name:\s*"([^"]+)"\s*$'
    )
    $shortDescriptionMatch = [regex]::Match(
        $openAiYamlText,
        '(?m)^\s{2}short_description:\s*"([^"]+)"\s*$'
    )
    $defaultPromptMatch = [regex]::Match(
        $openAiYamlText,
        '(?m)^\s{2}default_prompt:\s*"([^"]+)"\s*$'
    )

    if (-not $displayNameMatch.Success) {
        Add-ValidationError "openai.yaml has no display_name: $SkillDirectory"
    }
    if (-not $shortDescriptionMatch.Success) {
        Add-ValidationError (
            "openai.yaml has no quoted short_description: $SkillDirectory"
        )
    } elseif (
        $shortDescriptionMatch.Groups[1].Value.Length -lt 25 -or
        $shortDescriptionMatch.Groups[1].Value.Length -gt 64
    ) {
        Add-ValidationError (
            "openai.yaml short_description must be 25-64 characters: " +
            $SkillDirectory
        )
    }
    if (-not $defaultPromptMatch.Success) {
        Add-ValidationError "openai.yaml has no default_prompt: $SkillDirectory"
    } elseif ($defaultPromptMatch.Groups[1].Value -notmatch (
        '\$' + [regex]::Escape($SkillName) + '\b'
    )) {
        Add-ValidationError (
            "openai.yaml default_prompt must mention '`$$SkillName': " +
            $SkillDirectory
        )
    }

    $expectedValue = if ($AllowImplicitInvocation) {
        'true'
    } else {
        'false'
    }
    $policyPattern = (
        '(?ms)^policy:\s*\r?\n(?:[ \t].*\r?\n)*?' +
        '[ \t]+allow_implicit_invocation:\s*' +
        $expectedValue +
        '\s*$'
    )

    if (-not [regex]::IsMatch($openAiYamlText, $policyPattern)) {
        Add-ValidationError (
            "agents/openai.yaml does not declare " +
            "allow_implicit_invocation: $expectedValue in $SkillDirectory"
        )
    }
}

function Test-InvocationCases {
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$InvocationCases,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$ExpectedSkillNames
    )

    if ($null -eq $InvocationCases) {
        return
    }

    $caseNames = @($InvocationCases.skills | ForEach-Object { $_.name })
    foreach ($skillName in $ExpectedSkillNames) {
        if ($skillName -notin $caseNames) {
            Add-ValidationError "Invocation cases are missing skill: $skillName"
        }
    }
    foreach ($caseName in $caseNames) {
        if ($caseName -notin $ExpectedSkillNames) {
            Add-ValidationError "Invocation cases contain unknown skill: $caseName"
        }
    }

    foreach ($skillCase in @($InvocationCases.skills)) {
        $requiredCollections = @(
            'positive_zh',
            'positive_en',
            'positive_mixed',
            'negative',
            'explicit'
        )
        foreach ($collectionName in $requiredCollections) {
            $collection = @($skillCase.$collectionName)
            if ($collection.Count -lt 1) {
                Add-ValidationError (
                    "Invocation case '$($skillCase.name)' needs at least " +
                    "one '$collectionName' prompt"
                )
            }
            foreach ($prompt in $collection) {
                if ([string]::IsNullOrWhiteSpace([string]$prompt)) {
                    Add-ValidationError (
                        "Invocation case '$($skillCase.name)' contains an " +
                        "empty '$collectionName' prompt"
                    )
                }
            }
        }

        foreach ($explicitPrompt in @($skillCase.explicit)) {
            if ([string]$explicitPrompt -notmatch (
                '\$' + [regex]::Escape([string]$skillCase.name) + '\b'
            )) {
                Add-ValidationError (
                    "Explicit invocation prompt does not mention " +
                    "'`$$($skillCase.name)': $explicitPrompt"
                )
            }
        }
    }
}

function Test-PowerShellSyntax {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptsRoot
    )

    if (-not (Test-Path -LiteralPath $ScriptsRoot -PathType Container)) {
        Add-ValidationError "Scripts directory is missing: $ScriptsRoot"
        return
    }

    $scriptFiles = Get-ChildItem -LiteralPath $ScriptsRoot -File |
        Where-Object Extension -in @('.ps1', '.psm1')
    foreach ($scriptFile in $scriptFiles) {
        $parseTokens = $null
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile(
            $scriptFile.FullName,
            [ref]$parseTokens,
            [ref]$parseErrors
        ) | Out-Null

        foreach ($parseError in @($parseErrors)) {
            Add-ValidationError (
                "PowerShell syntax error in $($scriptFile.FullName): " +
                $parseError.Message
            )
        }
    }
}

function Test-SensitiveContent {
    param(
        [Parameter(Mandatory)]
        [string]$RepositoryRoot
    )

    $sensitivePatterns = [ordered]@{
        'Windows user path' = 'C:\\Users\\[^\\\s]+'
        'Private IPv4 address' = (
            '\b(?:10\.\d{1,3}\.\d{1,3}\.\d{1,3}|' +
            '192\.168\.\d{1,3}\.\d{1,3}|' +
            '172\.(?:1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3})\b'
        )
        'Private key marker' = 'BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY'
        'Credential assignment' = (
            '(?i)\b(?:api[_-]?key|access[_-]?token|password|passwd|secret)' +
            '\s*[:=]\s*["''][^"'']{8,}["'']'
        )
    }
    $textExtensions = @(
        '.md',
        '.json',
        '.yaml',
        '.yml',
        '.ps1',
        '.sh',
        '.txt'
    )

    $candidateFiles = Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -Force -File |
        Where-Object {
            $_.FullName -notmatch '[\\/]\.git[\\/]' -and
            $_.Extension -in $textExtensions
        }

    foreach ($candidateFile in $candidateFiles) {
        $candidateText = [System.IO.File]::ReadAllText(
            $candidateFile.FullName,
            [System.Text.UTF8Encoding]::new($false)
        )
        foreach ($sensitivePattern in $sensitivePatterns.GetEnumerator()) {
            if ([regex]::IsMatch($candidateText, $sensitivePattern.Value)) {
                Add-ValidationError (
                    "Possible $($sensitivePattern.Key) in " +
                    $candidateFile.FullName
                )
            }
        }
    }
}

function Test-SkillInstallation {
    param(
        [Parameter(Mandatory)]
        [object[]]$ManifestSkills,
        [string]$RequestedDestinationRoot
    )

    Import-Module (Join-Path $PSScriptRoot 'SkillLinks.psm1') -Force

    $installationRoot = if (
        [string]::IsNullOrWhiteSpace($RequestedDestinationRoot)
    ) {
        Get-DefaultSkillDestination
    } else {
        $RequestedDestinationRoot
    }
    $installationRoot = Get-NormalizedSkillPath -Path $installationRoot

    if (-not (Test-Path -LiteralPath $installationRoot -PathType Container)) {
        Add-ValidationError (
            "Skill installation directory is missing: $installationRoot"
        )
        return
    }

    foreach ($manifestSkill in $ManifestSkills) {
        $skillName = [string]$manifestSkill.name
        # User installations stay flat even though repository skills are categorized.
        $expectedTarget = Get-RepositorySkillPath `
            -ManifestSkill $manifestSkill `
            -SkillsRoot $repositorySkillsRoot
        $installedPath = Join-Path $installationRoot $skillName
        $installedItem = Get-Item `
            -LiteralPath $installedPath `
            -Force `
            -ErrorAction SilentlyContinue

        if ($null -eq $installedItem) {
            Add-ValidationError "Installed skill link is missing: $installedPath"
            continue
        }

        $actualTarget = Get-SkillLinkTarget -Item $installedItem
        if ($null -eq $actualTarget) {
            Add-ValidationError (
                "Installed skill is not a junction or symbolic link: " +
                $installedPath
            )
            continue
        }
        if ($actualTarget -ne $expectedTarget) {
            Add-ValidationError (
                "Installed skill link has the wrong target: $installedPath " +
                "-> $actualTarget (expected $expectedTarget)"
            )
        }
    }
}

$skillManifest = Read-JsonFile `
    -Path $skillManifestPath `
    -Label 'Skill manifest'
$referenceTerms = Read-JsonFile `
    -Path $referenceTermsPath `
    -Label 'Reference behavior-anchor terms'
$invocationCases = Read-JsonFile `
    -Path $invocationCasesPath `
    -Label 'Invocation cases'
$translationContracts = Read-JsonFile `
    -Path $translationContractsPath `
    -Label 'Translation contracts'

if (-not (Test-Path -LiteralPath $repositorySkillsRoot -PathType Container)) {
    Add-ValidationError "Skills directory is missing: $repositorySkillsRoot"
}

$manifestSkills = if ($null -ne $skillManifest) {
    @($skillManifest.skills)
} else {
    @()
}
$manifestSources = if ($null -ne $skillManifest) {
    @($skillManifest.sources)
} else {
    @()
}
$manifestSourceIds = @(
    $manifestSources |
        ForEach-Object { [string]$_.id }
)
$manifestNames = @($manifestSkills | ForEach-Object { [string]$_.name })
$translatedManifestSkills = @(
    $manifestSkills |
        Where-Object { [bool]$_.translation_contract }
)
$translatedManifestNames = @(
    $translatedManifestSkills |
        ForEach-Object { [string]$_.name }
)
$translationContractSkills = if ($null -ne $translationContracts) {
    @($translationContracts.skills)
} else {
    @()
}
$translationContractNames = @(
    $translationContractSkills |
        ForEach-Object { [string]$_.name }
)
# The README is the human-facing projection of the manifest's category metadata.
$readmeCategorySection = if (Test-Path -LiteralPath $readmePath -PathType Leaf) {
    [System.IO.File]::ReadAllText($readmePath)
} else {
    ''
}

if ($null -ne $skillManifest -and [int]$skillManifest.schema_version -ne 3) {
    Add-ValidationError 'Skill manifest schema_version must be 3'
}
if ($manifestNames.Count -lt 1) {
    Add-ValidationError 'Skill manifest must contain at least one skill'
}
if (($manifestNames | Select-Object -Unique).Count -ne $manifestNames.Count) {
    Add-ValidationError 'Skill manifest contains duplicate names'
}
if ($manifestSourceIds.Count -lt 1) {
    Add-ValidationError 'Skill manifest must register at least one source'
}
if (
    ($manifestSourceIds | Select-Object -Unique).Count -ne
    $manifestSourceIds.Count
) {
    Add-ValidationError 'Skill manifest contains duplicate source ids'
}
if ('local' -notin $manifestSourceIds) {
    Add-ValidationError (
        "Skill manifest must define a 'local' source for self-authored skills"
    )
}
foreach ($manifestSource in $manifestSources) {
    $sourceId = [string]$manifestSource.id
    $sourceKind = [string]$manifestSource.kind
    if ([string]::IsNullOrWhiteSpace($sourceId)) {
        Add-ValidationError 'Skill source has an empty id'
    } elseif ($sourceId -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        Add-ValidationError (
            "Skill source id must use lowercase kebab-case: '$sourceId'"
        )
    }
    if ($sourceKind -notin @('local', 'github', 'manual')) {
        Add-ValidationError (
            "Skill source '$sourceId' has unsupported kind '$sourceKind'"
        )
    }
    if ($sourceKind -in @('github', 'manual')) {
        foreach ($requiredSourceField in @(
            'url',
            'license',
            'license_file'
        )) {
            if ([string]::IsNullOrWhiteSpace(
                [string]$manifestSource.$requiredSourceField
            )) {
                Add-ValidationError (
                    "External source '$sourceId' is missing " +
                    "'$requiredSourceField'"
                )
            }
        }
        if ($sourceKind -eq 'github') {
            foreach ($requiredGitHubField in @(
                'repository',
                'default_ref'
            )) {
                if ([string]::IsNullOrWhiteSpace(
                    [string]$manifestSource.$requiredGitHubField
                )) {
                    Add-ValidationError (
                        "GitHub source '$sourceId' is missing " +
                        "'$requiredGitHubField'"
                    )
                }
            }
        }
        $licenseFilePath = Join-Path `
            $repositoryRoot `
            ([string]$manifestSource.license_file)
        # Source metadata must not escape the collection when resolving notices.
        $resolvedLicenseFilePath = [System.IO.Path]::GetFullPath(
            $licenseFilePath
        )
        $resolvedRepositoryRoot = (
            [System.IO.Path]::GetFullPath($repositoryRoot)
        ).TrimEnd(
            [System.IO.Path]::DirectorySeparatorChar,
            [System.IO.Path]::AltDirectorySeparatorChar
        ) + [System.IO.Path]::DirectorySeparatorChar
        if (-not $resolvedLicenseFilePath.StartsWith(
            $resolvedRepositoryRoot,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            Add-ValidationError (
                "Registered source license path escapes repository: " +
                $manifestSource.license_file
            )
        }
        if (-not (Test-Path -LiteralPath $licenseFilePath -PathType Leaf)) {
            Add-ValidationError (
                "Registered source license file is missing: $licenseFilePath"
            )
        }
    }
}
if (
    (ConvertTo-ComparableJson -Value (
        $translatedManifestNames | Sort-Object
    )) -cne
    (ConvertTo-ComparableJson -Value ($translationContractNames | Sort-Object))
) {
    Add-ValidationError (
        'Translation contract skill names do not match translated manifest skills'
    )
}

foreach ($manifestSkill in $manifestSkills) {
    $skillName = [string]$manifestSkill.name
    $category = [string]$manifestSkill.category
    if ($category -notin @(
        'development',
        'planning',
        'quality',
        'knowledge',
        'workflow'
    )) {
        Add-ValidationError (
            "Skill '$skillName' must define a supported category"
        )
    }
    $sourceId = [string]$manifestSkill.source_id
    $sourceDefinition = @(
        $manifestSources |
            Where-Object { [string]$_.id -eq $sourceId }
    )
    if ($sourceDefinition.Count -ne 1) {
        Add-ValidationError (
            "Skill '$skillName' must reference exactly one registered source"
        )
    } elseif ([string]$sourceDefinition[0].kind -ne 'local') {
        if ([string]::IsNullOrWhiteSpace(
            [string]$manifestSkill.source_path
        )) {
            Add-ValidationError (
                "Externally sourced skill '$skillName' has no source_path"
            )
        } elseif (
            [string]$manifestSkill.source_path -match
            '(^[\\/]|(?:^|[\\/])\.\.(?:[\\/]|$)|\\)'
        ) {
            Add-ValidationError (
                "Externally sourced skill '$skillName' has an unsafe " +
                'source_path; use a forward-slash relative path'
            )
        }
        if (
            [string]$manifestSkill.baseline_skill_sha256 -notmatch
            '^[a-f0-9]{64}$'
        ) {
            Add-ValidationError (
                "Externally sourced skill '$skillName' has no valid " +
                'baseline_skill_sha256'
            )
        }
    }
    $skillDirectory = Get-RepositorySkillPath `
        -ManifestSkill $manifestSkill `
        -SkillsRoot $repositorySkillsRoot
    $skillPath = Join-Path $skillDirectory 'SKILL.md'

    if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
        Add-ValidationError "SKILL.md is missing for skill: $skillName"
        continue
    }

    $frontmatter = Read-SkillFrontmatter -SkillPath $skillPath
    if ($null -eq $frontmatter) {
        continue
    }
    if ($frontmatter.Name -ne $skillName) {
        Add-ValidationError (
            "Skill directory/name mismatch: '$skillName' versus " +
            "'$($frontmatter.Name)'"
        )
    }
    if (-not [regex]::IsMatch(
        $frontmatter.Description,
        '[\p{IsCJKUnifiedIdeographs}]'
    )) {
        Add-ValidationError "Description is not Chinese-first: $skillName"
    }
    if (-not [regex]::IsMatch(
        $frontmatter.Description,
        '[A-Za-z]'
    )) {
        Add-ValidationError (
            "Description has no retained English trigger term: $skillName"
        )
    }

    Test-MarkdownRelativeLinks `
        -MarkdownPath $skillPath `
        -MarkdownText $frontmatter.Text
    Test-OpenAiPolicy `
        -SkillDirectory $skillDirectory `
        -SkillName $skillName `
        -AllowImplicitInvocation ([bool]$manifestSkill.allow_implicit_invocation)

    $requiresTranslationContract = [bool]$manifestSkill.translation_contract
    $translationContract = @(
        $translationContractSkills |
            Where-Object { [string]$_.name -eq $skillName }
    )
    if ($requiresTranslationContract -and $translationContract.Count -eq 1) {
        Test-TranslationContract `
            -SkillName $skillName `
            -Body (Get-SkillInstructionBody -SkillText $frontmatter.Text) `
            -Contract $translationContract[0] `
            -RequiredEnglishTerms @(
                $manifestSkill.required_english_terms |
                    ForEach-Object { [string]$_ }
            ) `
            -RequireEnglishTerms
    } elseif ($requiresTranslationContract) {
        Add-ValidationError (
            "Translated skill must have exactly one contract: $skillName"
        )
    } elseif ($translationContract.Count -gt 0) {
        Add-ValidationError (
            "Non-translated skill unexpectedly has a translation contract: " +
            $skillName
        )
    }
}

foreach ($category in @(
    'development',
    'planning',
    'quality',
    'knowledge',
    'workflow'
)) {
    if ($readmeCategorySection -notlike ('*' + $category + '*')) {
        Add-ValidationError "README category index is missing: $category"
    }
}
foreach ($manifestSkill in $manifestSkills) {
    $skillName = [string]$manifestSkill.name
    if ($readmeCategorySection -notlike ('*' + $skillName + '*')) {
        Add-ValidationError (
            "README category index is missing skill: $skillName"
        )
    }
}

if (Test-Path -LiteralPath $repositorySkillsRoot -PathType Container) {
    $manifestRelativeSkillPaths = @(
        $manifestSkills | ForEach-Object {
            "{0}/{1}" -f ([string]$_.category), ([string]$_.name)
        }
    )
    $directoryPaths = @(
        Get-ChildItem -LiteralPath $repositorySkillsRoot -Directory -Recurse |
            Where-Object {
                Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
            } |
            ForEach-Object {
                $_.FullName.Substring($repositorySkillsRoot.Length).TrimStart(
                    [System.IO.Path]::DirectorySeparatorChar,
                    [System.IO.Path]::AltDirectorySeparatorChar
                ).Replace([System.IO.Path]::DirectorySeparatorChar, '/')
            }
    )
    foreach ($directoryPath in $directoryPaths) {
        if ($directoryPath -notin $manifestRelativeSkillPaths) {
            Add-ValidationError "Unmanifested skill directory: $directoryPath"
        }
    }
}

$referenceContracts = if ($null -ne $translationContracts) {
    @($translationContracts.reference_files)
} else {
    @()
}
$referenceContractPaths = @(
    $referenceContracts |
        ForEach-Object { [string]$_.path }
)
# Keep behavior-anchor requirements separate from the immutable source contract
# so reviewed terminology can evolve without recapturing protected structures.
$referenceTermFiles = if ($null -ne $referenceTerms) {
    @($referenceTerms.files)
} else {
    @()
}
$referenceTermPaths = @(
    $referenceTermFiles |
        ForEach-Object { [string]$_.path }
)
$repositoryReferencePaths = @(
    if (Test-Path -LiteralPath $repositorySkillsRoot -PathType Container) {
        foreach ($translatedManifestSkill in $translatedManifestSkills) {
            $translatedSkillDirectory = Get-RepositorySkillPath `
                -ManifestSkill $translatedManifestSkill `
                -SkillsRoot $repositorySkillsRoot
            Get-ChildItem `
                -LiteralPath $translatedSkillDirectory `
                -Recurse `
                -File `
                -Filter '*.md' |
                Where-Object { $_.Name -ne 'SKILL.md' } |
                ForEach-Object {
                    $_.FullName.Substring(
                        $repositorySkillsRoot.Length
                    ).TrimStart(
                        [System.IO.Path]::DirectorySeparatorChar,
                        [System.IO.Path]::AltDirectorySeparatorChar
                    ).Replace(
                        [System.IO.Path]::DirectorySeparatorChar,
                        '/'
                    )
                }
        }
    }
)
if (
    (ConvertTo-ComparableJson -Value (
        $repositoryReferencePaths | Sort-Object
    )) -cne
    (ConvertTo-ComparableJson -Value (
        $referenceContractPaths | Sort-Object
    ))
) {
    Add-ValidationError (
        'Reference translation contract paths do not match repository Markdown'
    )
}
if (
    (ConvertTo-ComparableJson -Value (
        $referenceContractPaths | Sort-Object
    )) -cne
    (ConvertTo-ComparableJson -Value (
        $referenceTermPaths | Sort-Object
    ))
) {
    Add-ValidationError (
        'Reference behavior-anchor term paths do not match translation contracts'
    )
}
foreach ($referenceContract in $referenceContracts) {
    $referencePath = [string]$referenceContract.path
    $referenceFilePath = Join-Path `
        $repositorySkillsRoot `
        ($referencePath.Replace(
            '/',
            [System.IO.Path]::DirectorySeparatorChar
        ))
    if (-not (Test-Path -LiteralPath $referenceFilePath -PathType Leaf)) {
        Add-ValidationError (
            "Translated reference Markdown is missing: $referencePath"
        )
        continue
    }
    $referenceText = [System.IO.File]::ReadAllText(
        $referenceFilePath,
        [System.Text.UTF8Encoding]::new($false)
    )
    # Require exactly one terminology policy for every translated reference file.
    $referenceTermEntry = @(
        $referenceTermFiles |
            Where-Object { [string]$_.path -eq $referencePath }
    )
    if ($referenceTermEntry.Count -ne 1) {
        Add-ValidationError (
            "Reference behavior-anchor term entry count is not one: " +
            $referencePath
        )
        continue
    }
    Test-TranslationContract `
        -SkillName "reference:$referencePath" `
        -Body $referenceText `
        -Contract $referenceContract `
        -RequiredEnglishTerms @(
            $referenceTermEntry[0].required_english_terms |
                ForEach-Object { [string]$_ }
        ) `
        -RequireEnglishTerms
}

# Repository-facing guidance is part of the reusable collection interface.
foreach ($repositoryDocumentName in @(
    'README.md',
    'SOURCES.md',
    'THIRD_PARTY_NOTICES.md'
)) {
    $repositoryDocumentPath = Join-Path `
        $repositoryRoot `
        $repositoryDocumentName
    if (-not (
        Test-Path -LiteralPath $repositoryDocumentPath -PathType Leaf
    )) {
        Add-ValidationError (
            "Repository documentation is missing: $repositoryDocumentPath"
        )
        continue
    }
    Test-MarkdownRelativeLinks `
        -MarkdownPath $repositoryDocumentPath `
        -MarkdownText ([System.IO.File]::ReadAllText(
            $repositoryDocumentPath,
            [System.Text.UTF8Encoding]::new($false)
        ))
}

Test-InvocationCases `
    -InvocationCases $invocationCases `
    -ExpectedSkillNames $manifestNames
Test-PowerShellSyntax -ScriptsRoot $PSScriptRoot
Test-SensitiveContent -RepositoryRoot $repositoryRoot
if ($CheckInstallation) {
    Test-SkillInstallation `
        -ManifestSkills $manifestSkills `
        -RequestedDestinationRoot $DestinationRoot
}

foreach ($validationWarning in $validationWarnings) {
    Write-Warning $validationWarning
}

if ($validationErrors.Count -gt 0) {
    Write-Host ''
    Write-Host "Validation failed with $($validationErrors.Count) error(s):" `
        -ForegroundColor Red
    foreach ($validationError in $validationErrors) {
        Write-Host " - $validationError" -ForegroundColor Red
    }
    exit 1
}

$validationScope = if ($CheckInstallation) {
    'repository and installed links'
} else {
    'repository'
}
Write-Host (
    "Validation passed for $validationScope`: $($manifestNames.Count) skills, " +
    "$($manifestSources.Count) sources, metadata, policies, links, " +
    "invocation cases, and scripts are valid."
) -ForegroundColor Green
exit 0
