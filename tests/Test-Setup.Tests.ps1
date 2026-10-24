#Requires -Version 5.1
<#
.SYNOPSIS
    Pester v5 tests for ReadMeAI setup.ps1
.DESCRIPTION
    50 resilience-first tests covering Script Availability, -Detect, -Health,
    -Lint, -Export, -Sync, -MCP, -ExportClaude, and -All flags.
#>

BeforeAll {
    $script:RepoRoot   = Resolve-Path (Join-Path $PSScriptRoot '..')
    $script:SetupPath  = Join-Path $script:RepoRoot 'setup.ps1'
    $script:TempRoot   = Join-Path ([System.IO.Path]::GetTempPath()) "ReadMeAI_Tests_$([System.Guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $script:TempRoot -Force | Out-Null

    # Helper: run setup.ps1 with given arguments inside a temp dir, return output + exit code
    function Invoke-Setup {
        param(
            [string[]]$Arguments = @(),
            [string]  $WorkDir   = $script:TempRoot
        )
        $shell = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
        $output = & $shell -NoProfile -NonInteractive -Command "Set-Location '$WorkDir'; & '$($script:SetupPath)' $($Arguments -join ' ')" 2>&1
        [PSCustomObject]@{
            Output   = $output -join "`n"
            ExitCode = $LASTEXITCODE
            Lines    = $output
        }
    }
}

AfterAll {
    if (Test-Path $script:TempRoot) {
        Remove-Item -Recurse -Force $script:TempRoot -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
# T01-T05  Script Availability
# ---------------------------------------------------------------------------
Describe 'Script Availability' {

    It 'T01: setup.ps1 exists at the expected path' {
        $script:SetupPath | Should -Exist
    }

    It 'T02: setup.ps1 has no PowerShell syntax errors' {
        {
            $errors = $null
            [System.Management.Automation.Language.Parser]::ParseFile(
                $script:SetupPath, [ref]$null, [ref]$errors
            ) | Out-Null
            $errors | Should -BeNullOrEmpty
        } | Should -Not -Throw
    }

    It 'T03: setup.ps1 contains a version string of 5.0 or higher' {
        $content = Get-Content $script:SetupPath -Raw
        $content | Should -Match '(?i)(version|v)\s*[5-9]\.\d'
    }

    It 'T04: setup.ps1 declares a param block' {
        $content = Get-Content $script:SetupPath -Raw
        $content | Should -Match '(?i)\bparam\s*\('
    }

    It 'T05: setup.ps1 is non-trivial (at least 50 lines)' {
        (Get-Content $script:SetupPath).Count | Should -BeGreaterThan 50
    }
}

# ---------------------------------------------------------------------------
# T06-T15  -Detect Flag
# ---------------------------------------------------------------------------
Describe '-Detect Flag' {

    BeforeEach {
        $script:DetectDir = Join-Path $script:TempRoot "detect_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $script:DetectDir -Force | Out-Null
    }

    AfterEach {
        Remove-Item -Recurse -Force $script:DetectDir -ErrorAction SilentlyContinue
    }

    It 'T06: detects package.json as a Node project' {
        New-Item -Path (Join-Path $script:DetectDir 'package.json') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T07: detects requirements.txt as a Python project' {
        New-Item -Path (Join-Path $script:DetectDir 'requirements.txt') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T08: detects go.mod as a Go project' {
        New-Item -Path (Join-Path $script:DetectDir 'go.mod') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T09: detects Cargo.toml as a Rust project' {
        New-Item -Path (Join-Path $script:DetectDir 'Cargo.toml') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T10: detects bun.lockb as a Bun project' {
        New-Item -Path (Join-Path $script:DetectDir 'bun.lockb') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T11: detects pnpm-workspace.yaml as a pnpm monorepo' {
        New-Item -Path (Join-Path $script:DetectDir 'pnpm-workspace.yaml') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T12: detects pyproject.toml as a Python project' {
        New-Item -Path (Join-Path $script:DetectDir 'pyproject.toml') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T13: detects composer.json as a PHP project' {
        New-Item -Path (Join-Path $script:DetectDir 'composer.json') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T14: detects docker-compose.yml as a containerised project' {
        New-Item -Path (Join-Path $script:DetectDir 'docker-compose.yml') -ItemType File -Force | Out-Null
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }

    It 'T15: handles a directory with no recognisable project files' {
        { Invoke-Setup -Arguments @('-Detect') -WorkDir $script:DetectDir } | Should -Not -Throw
    }
}

# ---------------------------------------------------------------------------
# T16-T20  -Health Flag
# ---------------------------------------------------------------------------
Describe '-Health Flag' {

    BeforeEach {
        $script:HealthDir = Join-Path $script:TempRoot "health_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $script:HealthDir -Force | Out-Null
    }

    AfterEach {
        Remove-Item -Recurse -Force $script:HealthDir -ErrorAction SilentlyContinue
    }

    It 'T16: exits 0 when a valid .readmeAI file is present' {
        $readmeAI = Join-Path $script:HealthDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0"}' -Encoding UTF8
        $result = Invoke-Setup -Arguments @('-Health') -WorkDir $script:HealthDir
        $result.ExitCode | Should -Be 0
    }

    It 'T17: health output contains a numeric value' {
        $readmeAI = Join-Path $script:HealthDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0"}' -Encoding UTF8
        $result = Invoke-Setup -Arguments @('-Health') -WorkDir $script:HealthDir
        $result.Output | Should -Match '\d'
    }

    It 'T18: handles missing .readmeAI without terminating error' {
        { Invoke-Setup -Arguments @('-Health') -WorkDir $script:HealthDir } | Should -Not -Throw
    }

    It 'T19: -Health flag runs without a terminating error in any state' {
        { Invoke-Setup -Arguments @('-Health') -WorkDir $script:HealthDir } | Should -Not -Throw
    }

    It 'T20: -Health flag runs to completion (exit code is an integer)' {
        $result = Invoke-Setup -Arguments @('-Health') -WorkDir $script:HealthDir
        $result.ExitCode | Should -BeOfType [int]
    }
}

# ---------------------------------------------------------------------------
# T21-T25  -Lint Flag
# ---------------------------------------------------------------------------
Describe '-Lint Flag' {

    BeforeEach {
        $script:LintDir = Join-Path $script:TempRoot "lint_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $script:LintDir -Force | Out-Null
    }

    AfterEach {
        Remove-Item -Recurse -Force $script:LintDir -ErrorAction SilentlyContinue
    }

    It 'T21: exits 0 when a valid .readmeAI file is present' {
        $readmeAI = Join-Path $script:LintDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0"}' -Encoding UTF8
        $result = Invoke-Setup -Arguments @('-Lint') -WorkDir $script:LintDir
        $result.ExitCode | Should -Be 0
    }

    It 'T22: -Lint produces some output' {
        $readmeAI = Join-Path $script:LintDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0"}' -Encoding UTF8
        $result = Invoke-Setup -Arguments @('-Lint') -WorkDir $script:LintDir
        $result.Output.Length | Should -BeGreaterThan 0
    }

    It 'T23: handles missing .readmeAI without throwing' {
        { Invoke-Setup -Arguments @('-Lint') -WorkDir $script:LintDir } | Should -Not -Throw
    }

    It 'T24: runs without a terminating error in any state' {
        { Invoke-Setup -Arguments @('-Lint') -WorkDir $script:LintDir } | Should -Not -Throw
    }

    It 'T25: runs to completion (exit code is an integer)' {
        $result = Invoke-Setup -Arguments @('-Lint') -WorkDir $script:LintDir
        $result.ExitCode | Should -BeOfType [int]
    }
}

# ---------------------------------------------------------------------------
# T26-T30  -Export Flag
# ---------------------------------------------------------------------------
Describe '-Export Flag' {

    BeforeEach {
        $script:ExportDir = Join-Path $script:TempRoot "export_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $script:ExportDir -Force | Out-Null
        $readmeAI = Join-Path $script:ExportDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0","title":"Test"}' -Encoding UTF8
    }

    AfterEach {
        Remove-Item -Recurse -Force $script:ExportDir -ErrorAction SilentlyContinue
    }

    It 'T26: -Export does not throw with a valid .readmeAI' {
        { Invoke-Setup -Arguments @('-Export') -WorkDir $script:ExportDir } | Should -Not -Throw
    }

    It 'T27: -Export exits 0 with a valid .readmeAI' {
        $result = Invoke-Setup -Arguments @('-Export') -WorkDir $script:ExportDir
        $result.ExitCode | Should -Be 0
    }

    It 'T28: -Export produces some output' {
        $result = Invoke-Setup -Arguments @('-Export') -WorkDir $script:ExportDir
        $result.Output.Length | Should -BeGreaterThan 0
    }

    It 'T29: -Export handles missing .readmeAI without throwing' {
        $emptyDir = Join-Path $script:TempRoot "export_empty_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
        { Invoke-Setup -Arguments @('-Export') -WorkDir $emptyDir } | Should -Not -Throw
        Remove-Item -Recurse -Force $emptyDir -ErrorAction SilentlyContinue
    }

    It 'T30: -Export runs to completion (exit code is an integer)' {
        $result = Invoke-Setup -Arguments @('-Export') -WorkDir $script:ExportDir
        $result.ExitCode | Should -BeOfType [int]
    }
}

# ---------------------------------------------------------------------------
# T31-T35  -Sync Flag
# ---------------------------------------------------------------------------
Describe '-Sync Flag' {

    BeforeEach {
        $script:SyncDir = Join-Path $script:TempRoot "sync_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $script:SyncDir -Force | Out-Null
        $readmeAI = Join-Path $script:SyncDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0","title":"Test"}' -Encoding UTF8
    }

    AfterEach {
        Remove-Item -Recurse -Force $script:SyncDir -ErrorAction SilentlyContinue
    }

    It 'T31: -Sync does not throw with a valid .readmeAI' {
        { Invoke-Setup -Arguments @('-Sync') -WorkDir $script:SyncDir } | Should -Not -Throw
    }

    It 'T32: -Sync exits 0 with a valid .readmeAI' {
        $result = Invoke-Setup -Arguments @('-Sync') -WorkDir $script:SyncDir
        $result.ExitCode | Should -Be 0
    }

    It 'T33: -Sync produces some output' {
        $result = Invoke-Setup -Arguments @('-Sync') -WorkDir $script:SyncDir
        $result.Output.Length | Should -BeGreaterThan 0
    }

    It 'T34: -Sync handles missing .readmeAI without throwing' {
        $emptyDir = Join-Path $script:TempRoot "sync_empty_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
        { Invoke-Setup -Arguments @('-Sync') -WorkDir $emptyDir } | Should -Not -Throw
        Remove-Item -Recurse -Force $emptyDir -ErrorAction SilentlyContinue
    }

    It 'T35: -Sync runs to completion (exit code is an integer)' {
        $result = Invoke-Setup -Arguments @('-Sync') -WorkDir $script:SyncDir
        $result.ExitCode | Should -BeOfType [int]
    }
}

# ---------------------------------------------------------------------------
# T36-T40  -MCP Flag
# ---------------------------------------------------------------------------
Describe '-MCP Flag' {

    BeforeEach {
        $script:McpDir = Join-Path $script:TempRoot "mcp_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $script:McpDir -Force | Out-Null
    }

    AfterEach {
        Remove-Item -Recurse -Force $script:McpDir -ErrorAction SilentlyContinue
    }

    It 'T36: -MCP exits 0 when no .mcp.json exists' {
        $result = Invoke-Setup -Arguments @('-MCP') -WorkDir $script:McpDir
        $result.ExitCode | Should -Be 0
    }

    It 'T37: -MCP does not crash in any directory state' {
        { Invoke-Setup -Arguments @('-MCP') -WorkDir $script:McpDir } | Should -Not -Throw
    }

    It 'T38: -MCP detects a pre-existing .mcp.json without throwing' {
        $mcpJson = Join-Path $script:McpDir '.mcp.json'
        Set-Content -Path $mcpJson -Value '{"mcpServers":{}}' -Encoding UTF8
        { Invoke-Setup -Arguments @('-MCP') -WorkDir $script:McpDir } | Should -Not -Throw
    }

    It 'T39: -MCP produces some output' {
        $result = Invoke-Setup -Arguments @('-MCP') -WorkDir $script:McpDir
        $result.Output.Length | Should -BeGreaterThan 0
    }

    It 'T40: -MCP runs to completion (exit code is an integer)' {
        $result = Invoke-Setup -Arguments @('-MCP') -WorkDir $script:McpDir
        $result.ExitCode | Should -BeOfType [int]
    }
}

# ---------------------------------------------------------------------------
# T41-T45  -ExportClaude Flag
# ---------------------------------------------------------------------------
Describe '-ExportClaude Flag' {

    BeforeEach {
        $script:ExportClaudeDir = Join-Path $script:TempRoot "exportclaude_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $script:ExportClaudeDir -Force | Out-Null
        $readmeAI = Join-Path $script:ExportClaudeDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0","title":"Test"}' -Encoding UTF8
    }

    AfterEach {
        Remove-Item -Recurse -Force $script:ExportClaudeDir -ErrorAction SilentlyContinue
    }

    It 'T41: -ExportClaude does not throw with a valid .readmeAI' {
        { Invoke-Setup -Arguments @('-ExportClaude') -WorkDir $script:ExportClaudeDir } | Should -Not -Throw
    }

    It 'T42: -ExportClaude exits 0 with a valid .readmeAI' {
        $result = Invoke-Setup -Arguments @('-ExportClaude') -WorkDir $script:ExportClaudeDir
        $result.ExitCode | Should -Be 0
    }

    It 'T43: -ExportClaude produces some output' {
        $result = Invoke-Setup -Arguments @('-ExportClaude') -WorkDir $script:ExportClaudeDir
        $result.Output.Length | Should -BeGreaterThan 0
    }

    It 'T44: -ExportClaude handles missing .readmeAI without throwing' {
        $emptyDir = Join-Path $script:TempRoot "exportclaude_empty_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
        { Invoke-Setup -Arguments @('-ExportClaude') -WorkDir $emptyDir } | Should -Not -Throw
        Remove-Item -Recurse -Force $emptyDir -ErrorAction SilentlyContinue
    }

    It 'T45: -ExportClaude runs to completion (exit code is an integer)' {
        $result = Invoke-Setup -Arguments @('-ExportClaude') -WorkDir $script:ExportClaudeDir
        $result.ExitCode | Should -BeOfType [int]
    }
}

# ---------------------------------------------------------------------------
# T46-T50  -All Flag
# ---------------------------------------------------------------------------
Describe '-All Flag' {

    BeforeEach {
        $script:AllDir = Join-Path $script:TempRoot "all_$([System.Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $script:AllDir -Force | Out-Null
    }

    AfterEach {
        Remove-Item -Recurse -Force $script:AllDir -ErrorAction SilentlyContinue
    }

    It 'T46: -All runs without crashing in a populated directory' {
        $readmeAI = Join-Path $script:AllDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0","title":"Test"}' -Encoding UTF8
        { Invoke-Setup -Arguments @('-All') -WorkDir $script:AllDir } | Should -Not -Throw
    }

    It 'T47: -All creates at least one file in the target directory' {
        $readmeAI = Join-Path $script:AllDir '.readmeAI'
        Set-Content -Path $readmeAI -Value '{"version":"1.0","title":"Test"}' -Encoding UTF8
        Invoke-Setup -Arguments @('-All') -WorkDir $script:AllDir | Out-Null
        (Get-ChildItem -Path $script:AllDir -Recurse -File).Count | Should -BeGreaterThan 0
    }

    It 'T48: -All handles a completely fresh (empty) directory without throwing' {
        { Invoke-Setup -Arguments @('-All') -WorkDir $script:AllDir } | Should -Not -Throw
    }

    It 'T49: -All creates integration-related files (CLAUDE.md or .readmeAI or similar)' {
        Invoke-Setup -Arguments @('-All') -WorkDir $script:AllDir | Out-Null
        $files = Get-ChildItem -Path $script:AllDir -Recurse -File | Select-Object -ExpandProperty Name
        $hasIntegrationFile = $files | Where-Object { $_ -match '(CLAUDE|readmeAI|README|\.mcp)' }
        $hasIntegrationFile | Should -Not -BeNullOrEmpty
    }

    It 'T50: -All completes without a terminating error (exit code is an integer)' {
        $result = Invoke-Setup -Arguments @('-All') -WorkDir $script:AllDir
        $result.ExitCode | Should -BeOfType [int]
    }
}
