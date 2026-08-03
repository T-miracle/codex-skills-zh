#requires -Version 5.1

<#
.SYNOPSIS
Installs repository skills as per-skill NTFS junctions.

.DESCRIPTION
Creates one junction per manifested skill under the current user's official
.agents/skills directory. Existing ordinary directories are never overwritten.
Use -Repair to replace only junctions or symbolic links that point elsewhere.

.PARAMETER DestinationRoot
Overrides the installation root. Primarily useful for testing or custom setups.

.PARAMETER Repair
Allows an existing wrong-target junction or symbolic link to be replaced.

.EXAMPLE
.\scripts\install.ps1 -WhatIf

.EXAMPLE
.\scripts\install.ps1 -Repair
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [string]$DestinationRoot,
    [switch]$Repair
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SkillLinks.psm1') -Force

$repositoryContext = Get-SkillRepositoryContext -ScriptsRoot $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    $DestinationRoot = Get-DefaultSkillDestination
}
$normalizedDestinationRoot = Get-NormalizedSkillPath -Path $DestinationRoot
$createdCount = 0
$unchangedCount = 0
$repairedCount = 0
$conflicts = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path -LiteralPath $normalizedDestinationRoot -PathType Container)) {
    if ($PSCmdlet.ShouldProcess(
        $normalizedDestinationRoot,
        'Create skill installation directory'
    )) {
        New-Item `
            -ItemType Directory `
            -Path $normalizedDestinationRoot `
            -Force |
            Out-Null
    }
}

foreach ($manifestSkill in @($repositoryContext.Manifest.skills)) {
    $skillName = [string]$manifestSkill.name
    $sourceSkillPath = Get-NormalizedSkillPath -Path (
        Join-Path $repositoryContext.SkillsRoot $skillName
    )
    $installedSkillPath = Join-Path $normalizedDestinationRoot $skillName

    if (-not (Test-Path -LiteralPath (
        Join-Path $sourceSkillPath 'SKILL.md'
    ) -PathType Leaf)) {
        $conflicts.Add("Repository skill is incomplete: $sourceSkillPath")
        continue
    }

    $existingItem = Get-Item `
        -LiteralPath $installedSkillPath `
        -Force `
        -ErrorAction SilentlyContinue

    if ($null -ne $existingItem) {
        $existingTarget = Get-SkillLinkTarget -Item $existingItem
        if ($null -eq $existingTarget) {
            $conflicts.Add(
                "Existing path is not a managed link: $installedSkillPath"
            )
            continue
        }
        if ($existingTarget -eq $sourceSkillPath) {
            $unchangedCount++
            continue
        }
        if (-not $Repair) {
            $conflicts.Add(
                "Link points elsewhere; rerun with -Repair after review: " +
                "$installedSkillPath -> $existingTarget"
            )
            continue
        }

        if ($PSCmdlet.ShouldProcess(
            $installedSkillPath,
            "Replace link target '$existingTarget' with '$sourceSkillPath'"
        )) {
            # LinkType was verified, so removing this item cannot delete source contents.
            Remove-SkillDirectoryLink -Item $existingItem
            New-Item `
                -ItemType Junction `
                -Path $installedSkillPath `
                -Target $sourceSkillPath |
                Out-Null
            $repairedCount++
        }
        continue
    }

    if ($PSCmdlet.ShouldProcess(
        $installedSkillPath,
        "Create junction to '$sourceSkillPath'"
    )) {
        New-Item `
            -ItemType Junction `
            -Path $installedSkillPath `
            -Target $sourceSkillPath |
            Out-Null
        $createdCount++
    }
}

Write-Host (
    "Install summary: created=$createdCount, repaired=$repairedCount, " +
    "unchanged=$unchangedCount, conflicts=$($conflicts.Count)."
)

foreach ($conflict in $conflicts) {
    Write-Host "Conflict: $conflict" -ForegroundColor Red
}

if ($conflicts.Count -gt 0) {
    exit 1
}
exit 0
