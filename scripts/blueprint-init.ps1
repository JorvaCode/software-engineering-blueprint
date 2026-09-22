<#
.SYNOPSIS
  Installs the Software Engineering Blueprint into a target project directory.

.DESCRIPTION
  Copies the blueprint/, templates/ and standards/ directories (and .opencode/
  if present in the blueprint repository) into the destination directory.
  Does not overwrite existing files without warning.

  Tool- and IDE-agnostic: requires no Node, no Python and no external
  dependencies.

.EXAMPLE
  .\scripts\blueprint-init.ps1 C:\proyectos\mi-app
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'

function Write-Info    { Write-Host "[blueprint-init] $($args -join ' ')" }
function Write-Warn    { Write-Host "[blueprint-init] WARNING: $($args -join ' ')" -ForegroundColor Yellow }
function Write-Err     { Write-Host "[blueprint-init] ERROR: $($args -join ' ')" -ForegroundColor Red }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$blueprintRoot = Split-Path -Parent $scriptDir

if ([string]::IsNullOrWhiteSpace($Destination)) {
    Write-Err "destination argument is required."
    exit 1
}

$dest = [System.IO.Path]::GetFullPath($Destination)

Write-Info "Installing Software Engineering Blueprint into: $dest"
Write-Info "Source: $blueprintRoot"

if (-not (Test-Path -LiteralPath $blueprintRoot)) {
    Write-Err "source directory not found: $blueprintRoot"
    exit 1
}

if (-not (Test-Path -LiteralPath $dest)) {
    Write-Info "Destination does not exist. Creating directory: $dest"
    try {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    } catch {
        Write-Err "cannot create destination directory: $dest"
        exit 1
    }
    if (-not (Test-Path -LiteralPath $dest -PathType Container)) {
        Write-Err "destination directory could not be created: $dest"
        exit 1
    }
}

$requiredDirs = @('blueprint', 'templates', 'standards')
$optionalDirs = @()
if (Test-Path -LiteralPath (Join-Path $blueprintRoot '.opencode')) {
    $optionalDirs = @('.opencode')
}

$installed = @()
$skipped = @()
$failed = $false

foreach ($dir in ($requiredDirs + $optionalDirs)) {
    $src = Join-Path $blueprintRoot $dir
    $dstItem = Join-Path $dest $dir

    if (-not (Test-Path -LiteralPath $src)) {
        Write-Err "required source directory missing: $src"
        $failed = $true
        continue
    }

    if (Test-Path -LiteralPath $dstItem) {
        Write-Warn "'$dir' already exists in destination. Skipping to avoid overwriting existing content."
        $skipped += $dir
        continue
    }

    try {
        Copy-Item -LiteralPath $src -Destination $dstItem -Recurse

        # Do not ship dependency/build artifacts if the local source has them
        # (they are gitignored and are not part of the blueprint content).
        $nodeModules = Join-Path $dstItem 'node_modules'
        if (Test-Path -LiteralPath $nodeModules) {
            Remove-Item -LiteralPath $nodeModules -Recurse -Force
        }

        $installed += $dir
        Write-Host "[blueprint-init] installed  $dir"
    } catch {
        Write-Err "failed to copy '$dir': $($_.Exception.Message)"
        $failed = $true
    }
}

Write-Info ""
Write-Info "Installed: $($installed.Count) directory/directories"
foreach ($d in $installed) {
    Write-Host "  - $d"
}
Write-Info "Skipped (already present): $($skipped.Count)"
foreach ($d in $skipped) {
    Write-Host "  - $d"
}

if ($failed) {
    Write-Err "Installation FAILED."
    exit 1
}

Write-Info "Installation complete."
exit 0