<#
.SYNOPSIS
  Installs the Software Engineering Blueprint into a target project directory.

.DESCRIPTION
  Copies the directories named in the install allowlist (blueprint/, templates/,
  standards/ and, when present, .opencode/agents/ and .opencode/skills/) into the
  destination directory, and writes .blueprint-install.json recording the version
  that was installed.

  The allowlist is deliberate: copying a directory wholesale ships whatever
  happens to be in the maintainer's working copy, and a consumer that receives
  someone else's package.json is a consumer with a bug they did not write.
  See ADR-011.

  Separately, and outside the allowlist, it distributes the two licences:
  LICENSE (documentation, CC BY 4.0) and LICENSE-CODE (code, Apache-2.0). The
  documentation licence conditions reuse on attribution, so a consumer that
  receives the content has to receive the terms with it. A destination that
  already has a LICENSE is left untouched. See ADR-012.

  Does not overwrite existing content without warning.

.EXAMPLE
  .\scripts\blueprint-init.ps1 C:\proyectos\mi-app
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Destination
)

$ErrorActionPreference = 'Stop'

# Progress and warnings go to stdout, errors to stderr.
#
# Write-Output, not Write-Host and not [Console]::Out. Write-Host writes to the
# information stream and [Console]::Out writes around PowerShell entirely; neither
# reaches the success stream, so a caller cannot capture them:
#   $out = & .\blueprint-init.ps1 C:\x        # $out would be empty
# That makes the installer untestable and unusable from another script, and it
# would behave differently from blueprint-init.sh, which writes to stdout.
# Verified: Write-Host is only reachable via 6>&1, Write-Output via plain capture.
# See ADR-011.
function Write-Info {
    Write-Output "[blueprint-init] $($args -join ' ')"
}
function Write-Warn {
    Write-Output "[blueprint-init] WARNING: $($args -join ' ')"
}
function Write-Err {
    # Real stderr, so it lands on fd 2 when the script is run as a child process.
    [Console]::Error.WriteLine("[blueprint-init] ERROR: $($args -join ' ')")
}

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

# The install allowlist. Adding an entry here is a distribution decision and
# needs an ADR; nothing else is copied, ever.
$allowlist = @('blueprint', 'templates', 'standards', '.opencode/agents', '.opencode/skills')

$installed = @()
$skipped = @()
$failed = $false

foreach ($entry in $allowlist) {
    $src = Join-Path $blueprintRoot $entry
    $dstItem = Join-Path $dest $entry

    # The OpenCode adapter is optional; a copy of the blueprint without it is a
    # valid install, because the adapter is not a dependency (ADR-002).
    $isOptional = $entry.StartsWith('.opencode/')
    if (-not (Test-Path -LiteralPath $src -PathType Container)) {
        if ($isOptional) {
            Write-Info "skip       $entry/ (not present in source)"
            continue
        }
        Write-Err "required source directory missing: $src"
        $failed = $true
        continue
    }

    if (Test-Path -LiteralPath $dstItem) {
        Write-Warn "'$entry' already exists in destination. Skipping to avoid overwriting existing content."
        $skipped += $entry
        continue
    }

    $parent = Split-Path -Parent $dstItem
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        try {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        } catch {
            Write-Err "cannot create '$parent'."
            $failed = $true
            continue
        }
    }

    try {
        Copy-Item -LiteralPath $src -Destination $dstItem -Recurse
        $installed += $entry
        Write-Info "installed  $entry/"
    } catch {
        Write-Err "failed to copy '$entry': $($_.Exception.Message)"
        $failed = $true
    }
}

# Licence distribution. Deliberately NOT the allowlist. The allowlist names the
# content directories that make up the blueprint, and a licence is not content of
# the process; this is a separate distribution decision, recorded in ADR-012,
# with its own evidence in the manifest below.
#
# The documentation is CC BY 4.0 and the code is Apache-2.0. CC BY 4.0
# conditions reuse on attribution, so a consumer handed the content without the
# terms has a permission whose condition it cannot satisfy.
#
# A destination that already has a LICENSE is left alone. The licence in a
# project's root is that project's, and overwriting it is a defect rather than a
# courtesy. See ADR-012.
$docLicence   = 'CC-BY-4.0'
$codeLicence  = 'Apache-2.0'
$licenceFiles = @()

if (Test-Path -LiteralPath (Join-Path $dest 'LICENSE')) {
    Write-Info "NOTICE    destination already has a LICENSE; leaving it untouched and not adding ours"
} else {
    foreach ($l in @('LICENSE', 'LICENSE-CODE')) {
        $srcL = Join-Path $blueprintRoot $l
        if (-not (Test-Path -LiteralPath $srcL -PathType Leaf)) {
            Write-Err "required licence file missing: $srcL"
            $failed = $true
            break
        }
        try {
            Copy-Item -LiteralPath $srcL -Destination (Join-Path $dest $l)
            $licenceFiles += $l
            Write-Info "installed  $l"
        } catch {
            Write-Err "failed to copy '$l': $($_.Exception.Message)"
            $failed = $true
            break
        }
    }
}

# Record what was installed, so a consumer can tell which blueprint it has and
# whether it has been modified since. The version is the identifier; there is no
# content hash because computing one would need a tool this installer does not
# promise to have. See ADR-011.
$versionFile = Join-Path $blueprintRoot 'VERSION'
if (Test-Path -LiteralPath $versionFile) {
    $blueprintVersion = (Get-Content -LiteralPath $versionFile -TotalCount 1).Trim()
} else {
    $blueprintVersion = 'unknown'
}

$manifestPath = Join-Path $dest '.blueprint-install.json'
if (Test-Path -LiteralPath $manifestPath) {
    Write-Warn "'.blueprint-install.json' already exists. Leaving it untouched."
} else {
    # The entries recorded are the ones this run actually applied, not the
    # allowlist. An entry skipped as already-present was not applied, and a
    # manifest that claims otherwise misreports the destination. See ADR-011.
    $entries = ($installed | ForEach-Object { '        "{0}"' -f $_ }) -join ",`n"
    # The licence files are recorded as delivered, not as intended. A destination
    # that brought its own LICENSE received none of ours, and a manifest listing
    # them anyway is the same false report commit 679dbb4 removed from entries.
    $licenceEntries = ($licenceFiles | ForEach-Object { '      "{0}"' -f $_ }) -join ",`n"
    $manifest = @"
{
  "blueprint": "software-engineering-blueprint",
  "version": "$blueprintVersion",
  "installedAt": "$([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))",
  "installer": "scripts/blueprint-init.ps1",
  "licenses": {
    "documentation": "$docLicence",
    "code": "$codeLicence",
    "files": [
$licenceEntries
    ]
  },
  "entries": [
$entries
  ]
}
"@
    try {
        # No BOM: the manifest is read by tools other than PowerShell. An
        # explicit UTF8Encoding is the only way to get that from WriteAllText;
        # Set-Content -Encoding utf8 emits one in Windows PowerShell.
        $utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false
        [System.IO.File]::WriteAllText($manifestPath, $manifest, $utf8NoBom)
        Write-Info "wrote      .blueprint-install.json (version $blueprintVersion)"
    } catch {
        Write-Err "failed to write .blueprint-install.json: $($_.Exception.Message)"
        $failed = $true
    }
}

Write-Info ""
Write-Info "Installed: $($installed.Count) item(s)"
foreach ($d in $installed) {
    Write-Info "  - $d"
}
Write-Info "Skipped (already present): $($skipped.Count)"
foreach ($d in $skipped) {
    Write-Info "  - $d"
}
# Unconditional, because the terms matter most in the case where they were not
# copied: a destination that kept its own LICENSE still needs to know what the
# content it just received is under.
Write-Info "Licence: documentation $docLicence, code $codeLicence (see ADR-012)"

if ($failed) {
    Write-Err "Installation FAILED."
    exit 1
}

Write-Info "Installation complete."
exit 0
