#requires -Version 5.1

<#
.SYNOPSIS
Removes only junctions managed by the current repository clone.

.DESCRIPTION
Inspects each manifested skill and removes the installation link only when it
points to the matching skill in this repository. Ordinary directories and
foreign links are reported as conflicts and remain untouched.

.PARAMETER DestinationRoot
Overrides the installation root. Primarily useful for testing or custom setups.

.EXAMPLE
.\scripts\uninstall.ps1 -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [string]$DestinationRoot
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SkillLinks.psm1') -Force

$repositoryContext = Get-SkillRepositoryContext -ScriptsRoot $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    $DestinationRoot = Get-DefaultSkillDestination
}
$normalizedDestinationRoot = Get-NormalizedSkillPath -Path $DestinationRoot
$removedCount = 0
$missingCount = 0
$conflicts = [System.Collections.Generic.List[string]]::new()

foreach ($manifestSkill in @($repositoryContext.Manifest.skills)) {
    $skillName = [string]$manifestSkill.name
    $expectedTarget = Get-NormalizedSkillPath -Path (
        Join-Path $repositoryContext.SkillsRoot $skillName
    )
    $installedSkillPath = Join-Path $normalizedDestinationRoot $skillName
    $existingItem = Get-Item `
        -LiteralPath $installedSkillPath `
        -Force `
        -ErrorAction SilentlyContinue

    if ($null -eq $existingItem) {
        $missingCount++
        continue
    }

    $existingTarget = Get-SkillLinkTarget -Item $existingItem
    if ($null -eq $existingTarget) {
        $conflicts.Add(
            "Existing path is not a managed link: $installedSkillPath"
        )
        continue
    }
    if ($existingTarget -ne $expectedTarget) {
        $conflicts.Add(
            "Foreign link was not removed: $installedSkillPath -> " +
            $existingTarget
        )
        continue
    }

    if ($PSCmdlet.ShouldProcess(
        $installedSkillPath,
        "Remove junction to '$expectedTarget'"
    )) {
        # The target was verified; remove only the link, never the source tree.
        Remove-SkillDirectoryLink -Item $existingItem
        $removedCount++
    }
}

Write-Host (
    "Uninstall summary: removed=$removedCount, missing=$missingCount, " +
    "conflicts=$($conflicts.Count)."
)

foreach ($conflict in $conflicts) {
    Write-Host "Conflict: $conflict" -ForegroundColor Red
}

if ($conflicts.Count -gt 0) {
    exit 1
}
exit 0
