# ReadMeAI Tests

## Bash Tests (bats)
Requires bats-core: https://github.com/bats-core/bats-core
Run: bats tests/test_setup.bats

## PowerShell Tests (Pester v5)
Requires: Install-Module Pester -Force -Scope CurrentUser
Run: Invoke-Pester tests/Test-Setup.Tests.ps1 -Output Detailed
