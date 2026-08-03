#requires -Version 5.1

<#
.SYNOPSIS
Checks whether externally sourced SKILL.md files differ from local baselines.

.DESCRIPTION
Resolves each skill through the source registry in config/skills.json,
downloads supported remote SKILL.md files, and compares their SHA-256 values
with reviewed baselines. Self-authored local skills are reported but skipped.
The script never modifies repository skills or recorded baselines.

.PARAMETER FailOnUpdate
Returns exit code 2 when at least one external source differs from its baseline.

.PARAMETER Source
Checks only one source id. Omit it to check every registered source.

.PARAMETER Detailed
Displays full baseline hashes, remote hashes, and resolved URLs. This is useful
when registering a new source whose reviewed baseline has not been recorded yet.

.EXAMPLE
.\scripts\check-sources.ps1

.EXAMPLE
.\scripts\check-sources.ps1 -Source example-source
#>

[CmdletBinding()]
param(
    [switch]$FailOnUpdate,
    [string]$Source,
    [switch]$Detailed
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SkillLinks.psm1') -Force

$repositoryContext = Get-SkillRepositoryContext -ScriptsRoot $PSScriptRoot
$manifestSources = @($repositoryContext.Manifest.sources)
$sourceIndex = @{}
foreach ($manifestSource in $manifestSources) {
    $sourceIndex[[string]$manifestSource.id] = $manifestSource
}

if (
    -not [string]::IsNullOrWhiteSpace($Source) -and
    -not $sourceIndex.ContainsKey($Source)
) {
    throw "Unknown source id: $Source"
}

$webClient = [System.Net.WebClient]::new()
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$results = [System.Collections.Generic.List[object]]::new()

try {
    foreach ($manifestSkill in @($repositoryContext.Manifest.skills)) {
        $skillName = [string]$manifestSkill.name
        $sourceId = [string]$manifestSkill.source_id
        if (
            -not [string]::IsNullOrWhiteSpace($Source) -and
            $sourceId -ne $Source
        ) {
            continue
        }
        if (-not $sourceIndex.ContainsKey($sourceId)) {
            $results.Add([pscustomobject]@{
                Skill = $skillName
                Source = $sourceId
                Status = 'error'
                BaselineSha256 = ''
                RemoteSha256 = ''
                Url = ''
            })
            Write-Warning "Skill '$skillName' uses unknown source '$sourceId'."
            continue
        }

        $sourceDefinition = $sourceIndex[$sourceId]
        $sourceKind = [string]$sourceDefinition.kind
        if ($sourceKind -eq 'local') {
            $results.Add([pscustomobject]@{
                Skill = $skillName
                Source = $sourceId
                Status = 'local'
                BaselineSha256 = ''
                RemoteSha256 = ''
                Url = ''
            })
            continue
        }
        if ($sourceKind -eq 'manual') {
            $results.Add([pscustomobject]@{
                Skill = $skillName
                Source = $sourceId
                Status = 'manual-review'
                BaselineSha256 = [string]$manifestSkill.baseline_skill_sha256
                RemoteSha256 = ''
                Url = [string]$sourceDefinition.url
            })
            continue
        }
        if ($sourceKind -ne 'github') {
            $results.Add([pscustomobject]@{
                Skill = $skillName
                Source = $sourceId
                Status = 'unsupported-source'
                BaselineSha256 = [string]$manifestSkill.baseline_skill_sha256
                RemoteSha256 = ''
                Url = ''
            })
            continue
        }

        # GitHub sources share one definition while each skill retains its path.
        $sourceRepository = [string]$sourceDefinition.repository
        $sourceRef = [string]$sourceDefinition.default_ref
        $sourcePath = [string]$manifestSkill.source_path
        $sourceUrl = (
            "https://raw.githubusercontent.com/$sourceRepository/" +
            "$sourceRef/$sourcePath/SKILL.md"
        )
        try {
            # Hash the exact downloaded bytes so line endings remain significant.
            $sourceBytes = $webClient.DownloadData($sourceUrl)
            $sourceHashBytes = $sha256.ComputeHash($sourceBytes)
            $sourceHash = (
                [System.BitConverter]::ToString($sourceHashBytes)
            ).Replace('-', '').ToLowerInvariant()
            $baselineHash = [string]$manifestSkill.baseline_skill_sha256
            $status = if ($baselineHash -notmatch '^[a-f0-9]{64}$') {
                'baseline-missing'
            } elseif ($sourceHash -eq $baselineHash) {
                'unchanged'
            } else {
                'update-available'
            }

            $results.Add([pscustomobject]@{
                Skill = $skillName
                Source = $sourceId
                Status = $status
                BaselineSha256 = $baselineHash
                RemoteSha256 = $sourceHash
                Url = $sourceUrl
            })
        } catch {
            $results.Add([pscustomobject]@{
                Skill = $skillName
                Source = $sourceId
                Status = 'error'
                BaselineSha256 = [string]$manifestSkill.baseline_skill_sha256
                RemoteSha256 = ''
                Url = $sourceUrl
            })
            Write-Warning (
                "Could not check '$skillName': $($_.Exception.Message)"
            )
        }
    }
} finally {
    $sha256.Dispose()
    $webClient.Dispose()
}

if ($Detailed) {
    $results |
        Select-Object `
            Skill, `
            Source, `
            Status, `
            BaselineSha256, `
            RemoteSha256, `
            Url |
        Format-List
} else {
    $results |
        Select-Object Skill, Source, Status, RemoteSha256 |
        Format-Table -AutoSize
}

$errorCount = @($results | Where-Object Status -eq 'error').Count
$baselineMissingCount = @(
    $results | Where-Object Status -eq 'baseline-missing'
).Count
$unsupportedCount = @(
    $results | Where-Object Status -eq 'unsupported-source'
).Count
$updateCount = @(
    $results | Where-Object Status -eq 'update-available'
).Count
$localCount = @($results | Where-Object Status -eq 'local').Count
$manualCount = @($results | Where-Object Status -eq 'manual-review').Count
$unchangedCount = @($results | Where-Object Status -eq 'unchanged').Count
Write-Host (
    "Source summary: unchanged=$unchangedCount, updates=$updateCount, " +
    "local=$localCount, manual=$manualCount, " +
    "missing_baselines=$baselineMissingCount, " +
    "unsupported=$unsupportedCount, errors=$errorCount."
)

if (
    $errorCount -gt 0 -or
    $baselineMissingCount -gt 0 -or
    $unsupportedCount -gt 0
) {
    exit 1
}
if ($FailOnUpdate -and $updateCount -gt 0) {
    exit 2
}
exit 0
