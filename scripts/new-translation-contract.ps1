#requires -Version 5.1

<#
.SYNOPSIS
Captures behavior-sensitive Markdown structure before translating skill bodies.

.DESCRIPTION
Records hashes and protected Markdown elements for manifested skills whose
translation_contract flag is true. The resulting contract lets verify.ps1
detect accidental changes to code blocks, inline code, link targets, heading
levels, list markers, and HTML comments. Run this only against a staged,
reviewed source-language baseline assembled from the registered sources.

.PARAMETER SourceSkillsRoot
Overrides the skills directory used as the source-language baseline.

.PARAMETER OutputPath
Overrides the generated JSON contract path.

.PARAMETER Skill
Updates only the named manifested skill or skills and preserves every other
existing contract entry. This lets a newly imported skill be staged separately
instead of requiring source-language copies of the whole collection.

.PARAMETER Force
Allows replacement of an existing contract after an intentional baseline review.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [string]$SourceSkillsRoot,
    [string]$OutputPath,
    [string[]]$Skill,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $repositoryRoot 'config\skills.json'

if ([string]::IsNullOrWhiteSpace($SourceSkillsRoot)) {
    $SourceSkillsRoot = Join-Path $repositoryRoot 'skills'
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repositoryRoot 'tests\translation-contracts.json'
}

$sourceRoot = [System.IO.Path]::GetFullPath($SourceSkillsRoot)
$contractPath = [System.IO.Path]::GetFullPath($OutputPath)
if ((Test-Path -LiteralPath $contractPath) -and -not $Force) {
    throw "Translation contract already exists; use -Force only after review: $contractPath"
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

function Get-SkillBody {
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    $bodyMatch = [regex]::Match(
        $Text,
        '(?s)\A---\s*\r?\n.*?\r?\n---\s*\r?\n(.*)\z'
    )
    if (-not $bodyMatch.Success) {
        throw 'SKILL.md has no valid frontmatter/body boundary.'
    }
    return $bodyMatch.Groups[1].Value
}

function Get-ContractElements {
    param(
        [Parameter(Mandatory)]
        [string]$Body
    )

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

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 |
    ConvertFrom-Json
$allTranslatedManifestSkills = @(
    $manifest.skills |
        Where-Object { [bool]$_.translation_contract }
)
$requestedSkillNames = @(
    $Skill |
        Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
        ForEach-Object { [string]$_ } |
        Select-Object -Unique
)
$isIncrementalUpdate = $requestedSkillNames.Count -gt 0
$translatedManifestSkills = @(
    if ($isIncrementalUpdate) {
        foreach ($requestedSkillName in $requestedSkillNames) {
            $matchingManifestSkills = @(
                $allTranslatedManifestSkills |
                    Where-Object {
                        [string]$_.name -eq $requestedSkillName
                    }
            )
            if ($matchingManifestSkills.Count -ne 1) {
                throw (
                    "Requested skill must exist and set " +
                    "translation_contract=true: $requestedSkillName"
                )
            }
            $matchingManifestSkills[0]
        }
    } else {
        $allTranslatedManifestSkills
    }
)

$capturedContractSkills = @(
    foreach ($manifestSkill in $translatedManifestSkills) {
        $skillName = [string]$manifestSkill.name
        $skillPath = Join-Path $sourceRoot "$skillName\SKILL.md"
        if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
            throw "Source SKILL.md is missing: $skillPath"
        }

        $skillText = [System.IO.File]::ReadAllText(
            $skillPath,
            [System.Text.UTF8Encoding]::new($false)
        )
        $body = Get-SkillBody -Text $skillText
        $elements = Get-ContractElements -Body $body

        [ordered]@{
            name = $skillName
            source_body_sha256 = Get-TextSha256 -Text $body
            fenced_code_sha256 = $elements.fenced_code_sha256
            inline_code = $elements.inline_code
            skill_invocations = $elements.skill_invocations
            link_targets = $elements.link_targets
            heading_levels = $elements.heading_levels
            list_markers = $elements.list_markers
            html_comments = $elements.html_comments
            html_tags = $elements.html_tags
            strong_marker_count = $elements.strong_marker_count
            italic_marker_count = $elements.italic_marker_count
            italic_asterisk_count = $elements.italic_asterisk_count
        }
    }
)
# Capture every disclosed Markdown file under each skill with the same safeguards
# as SKILL.md so translating reference material cannot alter executable content.
$capturedReferenceFiles = @(
    foreach ($manifestSkill in $translatedManifestSkills) {
        $skillName = [string]$manifestSkill.name
        $sourceSkillRoot = Join-Path $sourceRoot $skillName
        $referenceFiles = @(
            Get-ChildItem `
                -LiteralPath $sourceSkillRoot `
                -Recurse `
                -File `
                -Filter '*.md' |
                Where-Object { $_.Name -ne 'SKILL.md' } |
                Sort-Object FullName
        )

        foreach ($referenceFile in $referenceFiles) {
            $relativeWithinSkill = $referenceFile.FullName.Substring(
                $sourceSkillRoot.Length
            ).TrimStart(
                [System.IO.Path]::DirectorySeparatorChar,
                [System.IO.Path]::AltDirectorySeparatorChar
            ).Replace(
                [System.IO.Path]::DirectorySeparatorChar,
                '/'
            )
            $repositoryRelativePath = "$skillName/$relativeWithinSkill"
            $referenceText = [System.IO.File]::ReadAllText(
                $referenceFile.FullName,
                [System.Text.UTF8Encoding]::new($false)
            )
            $elements = Get-ContractElements -Body $referenceText

            [ordered]@{
                path = $repositoryRelativePath
                source_body_sha256 = Get-TextSha256 -Text $referenceText
                fenced_code_sha256 = $elements.fenced_code_sha256
                inline_code = $elements.inline_code
                skill_invocations = $elements.skill_invocations
                link_targets = $elements.link_targets
                heading_levels = $elements.heading_levels
                list_markers = $elements.list_markers
                html_comments = $elements.html_comments
                html_tags = $elements.html_tags
                strong_marker_count = $elements.strong_marker_count
                italic_marker_count = $elements.italic_marker_count
                italic_asterisk_count = $elements.italic_asterisk_count
            }
        }
    }
)

$contractSkills = $capturedContractSkills
$contractReferenceFiles = $capturedReferenceFiles
if ($isIncrementalUpdate) {
    if (-not (Test-Path -LiteralPath $contractPath -PathType Leaf)) {
        throw (
            'Incremental update requires an existing translation contract: ' +
            $contractPath
        )
    }
    $existingContract = Get-Content `
        -LiteralPath $contractPath `
        -Raw `
        -Encoding UTF8 |
        ConvertFrom-Json

    # Preserve unselected entries while ordering skill contracts by the manifest.
    $contractSkills = @(
        foreach ($manifestSkill in $allTranslatedManifestSkills) {
            $manifestSkillName = [string]$manifestSkill.name
            $candidateContracts = @(
                if ($manifestSkillName -in $requestedSkillNames) {
                    $capturedContractSkills |
                        Where-Object {
                            [string]$_.name -eq $manifestSkillName
                        }
                } else {
                    $existingContract.skills |
                        Where-Object {
                            [string]$_.name -eq $manifestSkillName
                        }
                }
            )
            if ($candidateContracts.Count -ne 1) {
                throw (
                    "Could not preserve exactly one translation contract for " +
                    "skill: $manifestSkillName"
                )
            }
            $candidateContracts[0]
        }
    )

    # Replacing every reference entry under a selected skill also records deletions.
    $preservedReferenceFiles = @(
        $existingContract.reference_files |
            Where-Object {
                ([string]$_.path).Split('/')[0] -notin $requestedSkillNames
            }
    )
    $contractReferenceFiles = @(
        $preservedReferenceFiles
        $capturedReferenceFiles
    ) | Sort-Object { [string]$_.path }
}

$contract = [ordered]@{
    schema_version = 1
    purpose = 'Protect behavior-sensitive Markdown while translating skill instructions and reference files.'
    source_language = 'en'
    target_language = 'zh-CN'
    skills = $contractSkills
    reference_files = $contractReferenceFiles
}
$contractJson = $contract | ConvertTo-Json -Depth 10

$contractWritten = $false
if ($PSCmdlet.ShouldProcess(
    $contractPath,
    (
        "Capture $($translatedManifestSkills.Count) reviewed skill(s); " +
        "write $($contractSkills.Count) total contract entries"
    )
)) {
    $contractDirectory = Split-Path -Parent $contractPath
    if (-not (Test-Path -LiteralPath $contractDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $contractDirectory -Force |
            Out-Null
    }
    [System.IO.File]::WriteAllText(
        $contractPath,
        $contractJson + [Environment]::NewLine,
        [System.Text.UTF8Encoding]::new($false)
    )
    $contractWritten = $true
}

$contractResult = if ($contractWritten) {
    'captured'
} elseif ($WhatIfPreference) {
    'previewed'
} else {
    'not written'
}
Write-Host (
    "Translation contract $contractResult`: " +
    "updated=$($translatedManifestSkills.Count), " +
    "skills=$($contractSkills.Count), " +
    "reference_files=$($contractReferenceFiles.Count), " +
    "path=$contractPath"
) -ForegroundColor Green
