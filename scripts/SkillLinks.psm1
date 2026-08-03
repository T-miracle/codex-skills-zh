#requires -Version 5.1

<#
.SYNOPSIS
Shared path and manifest helpers for the repository's Windows scripts.

.DESCRIPTION
Keeps link inspection and repository discovery consistent across install,
verify, and uninstall operations. The module does not create or remove files.
#>

function Get-NormalizedSkillPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $expandedPath = [Environment]::ExpandEnvironmentVariables($Path)
    if ($expandedPath.StartsWith('\\?\')) {
        $expandedPath = $expandedPath.Substring(4)
    }

    return [System.IO.Path]::GetFullPath($expandedPath).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
}

function Get-SkillLinkTarget {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$Item
    )

    if ($Item.LinkType -notin @('Junction', 'SymbolicLink')) {
        return $null
    }

    $rawTarget = [string](@($Item.Target)[0])
    if ([string]::IsNullOrWhiteSpace($rawTarget)) {
        return $null
    }
    if (-not [System.IO.Path]::IsPathRooted($rawTarget)) {
        $rawTarget = Join-Path $Item.Parent.FullName $rawTarget
    }

    return Get-NormalizedSkillPath -Path $rawTarget
}

function Remove-SkillDirectoryLink {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$Item
    )

    if ($Item.LinkType -notin @('Junction', 'SymbolicLink')) {
        throw "Refusing to remove a non-link path: $($Item.FullName)"
    }

    # Directory.Delete removes the reparse point itself and does not traverse its target.
    [System.IO.Directory]::Delete($Item.FullName)
}

function Get-SkillRepositoryContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ScriptsRoot
    )

    $repositoryRoot = Get-NormalizedSkillPath -Path (
        Split-Path -Parent $ScriptsRoot
    )
    $manifestPath = Join-Path $repositoryRoot 'config\skills.json'
    $skillsRoot = Join-Path $repositoryRoot 'skills'

    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw "Skill manifest is missing: $manifestPath"
    }
    if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
        throw "Repository skills directory is missing: $skillsRoot"
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 |
        ConvertFrom-Json

    return [pscustomobject]@{
        RepositoryRoot = $repositoryRoot
        SkillsRoot = Get-NormalizedSkillPath -Path $skillsRoot
        ManifestPath = $manifestPath
        Manifest = $manifest
    }
}

function Get-DefaultSkillDestination {
    [CmdletBinding()]
    param()

    if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        throw 'USERPROFILE is unavailable; pass -DestinationRoot explicitly.'
    }

    return Join-Path $env:USERPROFILE '.agents\skills'
}

Export-ModuleMember -Function @(
    'Get-NormalizedSkillPath',
    'Get-SkillLinkTarget',
    'Remove-SkillDirectoryLink',
    'Get-SkillRepositoryContext',
    'Get-DefaultSkillDestination'
)
