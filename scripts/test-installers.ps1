# Functional test for the PowerShell installer, run against a real temporary
# destination. The bash installer is covered by test-installers.sh, which also
# invokes this file where pwsh is available.
#
# Run: pwsh -NoProfile -File scripts/test-installers.ps1
#   (or: powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-installers.ps1)
$ErrorActionPreference = 'Continue'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo      = Split-Path -Parent $scriptDir
$work      = Join-Path $env:TEMP ("bp-ps-test-" + [Guid]::NewGuid().ToString('N').Substring(0,8))
$dest      = Join-Path $work 'ps-target'
$pass      = 0
$fail      = 0

function Check($name, [bool]$condition) {
    if ($condition) { Write-Host "  PASS  $name"; $script:pass++ }
    else            { Write-Host "  ****  $name"; $script:fail++ }
}

New-Item -ItemType Directory -Path $work -Force | Out-Null

# Poison the source exactly as the bash test does.
$poison = @(
    "$repo\.opencode\package.json",
    "$repo\.opencode\package-lock.json",
    "$repo\.opencode\bun.lock",
    "$repo\.opencode\STRAY-LOCAL-FILE.md"
)
foreach ($p in $poison) { Set-Content -LiteralPath $p -Value 'poison' -Encoding utf8 }

try {
    Write-Host "== PowerShell installer =="
    $out = & "$repo\scripts\blueprint-init.ps1" $dest 2>&1 | Out-String
    Check "exit code is 0" ($LASTEXITCODE -eq 0)

    Check "blueprint/ installed"        (Test-Path -LiteralPath "$dest\blueprint")
    Check "templates/ installed"       (Test-Path -LiteralPath "$dest\templates")
    Check "standards/ installed"       (Test-Path -LiteralPath "$dest\standards")
    Check ".opencode/skills installed" (Test-Path -LiteralPath "$dest\.opencode\skills")
    Check ".opencode/agents installed" (Test-Path -LiteralPath "$dest\.opencode\agents")

    Check "manifest written"           (Test-Path -LiteralPath "$dest\.blueprint-install.json")
    $manifestPath = "$dest\.blueprint-install.json"
    if (Test-Path -LiteralPath $manifestPath) {
        # Check the BYTES. ReadAllText decodes and silently strips a UTF-8 BOM, and
        # String.StartsWith([char]0xFEFF) mis-binds its overload in Windows
        # PowerShell, so neither is a valid way to assert the absence of a BOM.
        $bytes = [System.IO.File]::ReadAllBytes($manifestPath)
        $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        Check "manifest has no BOM" (-not $hasBom)
        Check "manifest starts with '{'" ($bytes[0] -eq 0x7B)
        $raw = [System.Text.Encoding]::UTF8.GetString($bytes)
        $parsed = $null
        $valid  = $true
        try { $parsed = $raw | ConvertFrom-Json } catch { $valid = $false }
        Check "manifest is valid JSON" $valid
        if ($valid) {
            $expected = (Get-Content -LiteralPath "$repo\VERSION" -TotalCount 1).Trim()
            Check "manifest version matches VERSION" ($parsed.version -eq $expected)
            Check "manifest lists 5 entries" ($parsed.entries.Count -eq 5)
            Check "manifest names the installer" ($parsed.installer -eq 'scripts/blueprint-init.ps1')
        }
    }

    Write-Host "  --- the allowlist must not leak anything ---"
    Check "no .opencode/package.json shipped" (-not (Test-Path -LiteralPath "$dest\.opencode\package.json"))
    Check "no package-lock.json shipped"      (-not (Test-Path -LiteralPath "$dest\.opencode\package-lock.json"))
    Check "no bun.lock shipped"               (-not (Test-Path -LiteralPath "$dest\.opencode\bun.lock"))
    Check "no node_modules shipped"           (-not (Test-Path -LiteralPath "$dest\.opencode\node_modules"))
    Check "stray file in .opencode/ not shipped" (-not (Test-Path -LiteralPath "$dest\.opencode\STRAY-LOCAL-FILE.md"))
    Check "no .git shipped"                   (-not (Test-Path -LiteralPath "$dest\.git"))
    Check "no .github shipped"                (-not (Test-Path -LiteralPath "$dest\.github"))
    Check "no scripts/ shipped"               (-not (Test-Path -LiteralPath "$dest\scripts"))
    Check "no README.md shipped"              (-not (Test-Path -LiteralPath "$dest\README.md"))

    Write-Host "  --- installed content matches the bash installer's result ---"
    $phases = @(Get-ChildItem -Path "$dest\blueprint" -Filter '??-*.md')
    Check "all 15 phase docs copied" ($phases.Count -eq 15)
    $skills = @(Get-ChildItem -Path "$dest\.opencode\skills" -Directory)
    Check "5 skills copied" ($skills.Count -eq 5)
    $noInfoItems = @()
    foreach ($p in $phases) {
        if ($p.Name -like '00-*') { continue }
        if (-not (Select-String -LiteralPath $p.FullName -Pattern '^## Information items' -Quiet)) {
            $noInfoItems += $p.Name
        }
    }
    Check "every phase declares information items" ($noInfoItems.Count -eq 0)

    Write-Host "  --- re-running is safe and does not clobber the manifest ---"
    Set-Content -LiteralPath $manifestPath -Value 'hand-edited' -Encoding utf8
    $out2 = & "$repo\scripts\blueprint-init.ps1" $dest 2>&1 | Out-String
    Check "second run exits 0" ($LASTEXITCODE -eq 0)
    Check "existing manifest preserved" ((Get-Content -LiteralPath $manifestPath -Raw) -match 'hand-edited')
    Check "second run warns about manifest" ($out2 -match 'already exists')
    Check "stdout is capturable (not Write-Host)" ($out2 -match 'Installation complete')
    Check "warnings are capturable too" ($out2 -match 'WARNING')

    Write-Host "  --- missing argument is a clean non-zero exit, not a silent success ---"
    # Run as a real child process: an in-process call throws a parameter binding
    # error that never reaches the script body, so it cannot assert an exit code.
    $bad = & powershell -NoProfile -ExecutionPolicy Bypass -File "$scriptDir\blueprint-init.ps1" 2>&1 | Out-String
    Check "no-arg run exits non-zero" ($LASTEXITCODE -ne 0)
    # The parameter name is not localized; the surrounding error text is.
    Check "no-arg error names the missing parameter" ($bad -match 'Destination')
}
finally {
    foreach ($p in $poison) { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "PowerShell installer tests: $pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
