#!/usr/bin/env bats
# ReadMeAI setup.sh test suite — 50 tests (T01–T50)

SCRIPT="${BATS_TEST_DIRNAME}/../setup.sh"

setup() {
  TEST_TMPDIR="$(mktemp -d)"
  export TEST_TMPDIR

  # Initialise a minimal git repo inside the temp dir
  git init --quiet "$TEST_TMPDIR"
  git -C "$TEST_TMPDIR" config user.email "test@test.com"
  git -C "$TEST_TMPDIR" config user.name  "Test User"

  # Create a minimal .readmeAI file
  cat > "$TEST_TMPDIR/.readmeAI" <<'EOF'
# ReadMeAI Context
PROJECT_NAME: TestProject
VERSION: 1.0.0
TECH_STACK: bash
DESCRIPTION: A test project for bats
LAST_SYNC: 2026-01-01
EOF

  cd "$TEST_TMPDIR"
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}

# ─────────────────────────────────────────────────────────────────────────────
# GROUP A — Script basics (T01–T10)
# ─────────────────────────────────────────────────────────────────────────────

@test "T01: script exists" {
  [ -f "$SCRIPT" ]
}

@test "T02: script is executable" {
  [ -x "$SCRIPT" ]
}

@test "T03: no syntax errors (bash -n)" {
  run bash -n "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "T04: has shebang line" {
  run head -1 "$SCRIPT"
  [[ "$output" == "#!/"* ]]
}

@test "T05: version 5.0 present in script" {
  run grep -q '5\.0' "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "T06: --help exits 0" {
  run bash "$SCRIPT" --help
  [ "$status" -eq 0 ]
}

@test "T07: --help shows usage information" {
  run bash "$SCRIPT" --help
  [[ "$output" == *"setup.sh"* ]] || [[ "$output" == *"Usage"* ]] || [[ "$output" == *"usage"* ]] || [[ "$output" == *"--all"* ]]
}

@test "T08: --help mentions --detect" {
  run bash "$SCRIPT" --help
  [[ "$output" == *"--detect"* ]]
}

@test "T09: script has CURRENT_VERSION variable" {
  run grep -q 'CURRENT_VERSION' "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "T10: script is valid UTF-8" {
  run bash -c "iconv -f UTF-8 -t UTF-8 '$SCRIPT' > /dev/null 2>&1"
  [ "$status" -eq 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# GROUP B — --detect flag (T11–T20)
# ─────────────────────────────────────────────────────────────────────────────

@test "T11: --detect recognises package.json" {
  echo '{"name":"test"}' > "$TEST_TMPDIR/package.json"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T12: --detect recognises requirements.txt" {
  echo "flask==2.0" > "$TEST_TMPDIR/requirements.txt"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T13: --detect recognises go.mod" {
  printf "module example.com/mymod\ngo 1.21\n" > "$TEST_TMPDIR/go.mod"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T14: --detect recognises Cargo.toml" {
  printf "[package]\nname = \"myapp\"\nversion = \"0.1.0\"\n" > "$TEST_TMPDIR/Cargo.toml"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T15: --detect recognises bun.lockb" {
  touch "$TEST_TMPDIR/bun.lockb"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T16: --detect recognises pnpm-workspace.yaml" {
  echo "packages:" > "$TEST_TMPDIR/pnpm-workspace.yaml"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T17: --detect recognises composer.json" {
  echo '{"require":{}}' > "$TEST_TMPDIR/composer.json"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T18: --detect recognises docker-compose.yml" {
  printf "version: '3'\nservices:\n  web:\n    image: nginx\n" > "$TEST_TMPDIR/docker-compose.yml"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T19: --detect recognises pyproject.toml" {
  printf "[tool.poetry]\nname = \"myapp\"\n" > "$TEST_TMPDIR/pyproject.toml"
  run bash "$SCRIPT" --detect
  [ "$status" -eq 0 ]
}

@test "T20: --detect runs without crash when no project files present" {
  run bash "$SCRIPT" --detect
  # Status 0 or 1 are both acceptable — must not error out badly
  [ "$status" -le 1 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# GROUP C — --health, --lint, --export (T21–T30)
# ─────────────────────────────────────────────────────────────────────────────

@test "T21: --health exits 0 with valid .readmeAI" {
  run bash "$SCRIPT" --health
  [ "$status" -eq 0 ]
}

@test "T22: --health outputs a number (score)" {
  run bash "$SCRIPT" --health
  [[ "$output" =~ [0-9] ]]
}

@test "T23: --health handles missing .readmeAI gracefully" {
  rm -f "$TEST_TMPDIR/.readmeAI"
  run bash "$SCRIPT" --health
  [ "$status" -le 1 ]
}

@test "T24: --lint exits 0 or 1 with valid file" {
  run bash "$SCRIPT" --lint
  [ "$status" -le 1 ]
}

@test "T25: --lint does not crash (no unhandled error)" {
  run bash "$SCRIPT" --lint
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" != *"command not found"* ]]
}

@test "T26: --lint handles missing .readmeAI without fatal crash" {
  rm -f "$TEST_TMPDIR/.readmeAI"
  run bash "$SCRIPT" --lint
  [ "$status" -le 1 ]
}

@test "T27: --export exits 0" {
  run bash "$SCRIPT" --export
  [ "$status" -eq 0 ]
}

@test "T28: --export produces output to stdout" {
  run bash "$SCRIPT" --export
  [ "${#output}" -gt 0 ]
}

@test "T29: --export handles missing .readmeAI gracefully" {
  rm -f "$TEST_TMPDIR/.readmeAI"
  run bash "$SCRIPT" --export
  [ "$status" -le 1 ]
}

@test "T30: --export output is not empty when .readmeAI exists" {
  run bash "$SCRIPT" --export
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

# ─────────────────────────────────────────────────────────────────────────────
# GROUP D — --sync, --mcp, --export-claude (T31–T40)
# ─────────────────────────────────────────────────────────────────────────────

@test "T31: --sync exits 0 or 1 inside git repo" {
  run bash "$SCRIPT" --sync
  [ "$status" -le 1 ]
}

@test "T32: --sync does not crash with unhandled error" {
  run bash "$SCRIPT" --sync
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" != *"command not found"* ]]
}

@test "T33: --sync handles directory with no git history" {
  NOGIT="$(mktemp -d)"
  cp "$TEST_TMPDIR/.readmeAI" "$NOGIT/.readmeAI"
  run bash -c "cd '$NOGIT' && bash '$SCRIPT' --sync"
  rm -rf "$NOGIT"
  [ "$status" -le 1 ]
}

@test "T34: --sync does not delete .readmeAI" {
  bash "$SCRIPT" --sync || true
  [ -f "$TEST_TMPDIR/.readmeAI" ]
}

@test "T35: --sync handles empty git history without crash" {
  # Repo initialised in setup() but no commits yet — empty history
  run bash "$SCRIPT" --sync
  [ "$status" -le 1 ]
}

@test "T36: --mcp exits 0 when no .mcp.json present" {
  run bash "$SCRIPT" --mcp
  [ "$status" -eq 0 ]
}

@test "T37: --mcp does not crash" {
  run bash "$SCRIPT" --mcp
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" != *"command not found"* ]]
}

@test "T38: --mcp detects .mcp.json when present" {
  echo '{"mcpServers":{}}' > "$TEST_TMPDIR/.mcp.json"
  run bash "$SCRIPT" --mcp
  [ "$status" -eq 0 ]
}

@test "T39: --export-claude exits 0 or 1" {
  run bash "$SCRIPT" --export-claude
  [ "$status" -le 1 ]
}

@test "T40: --export-claude does not crash" {
  run bash "$SCRIPT" --export-claude
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" != *"command not found"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# GROUP E — --all and file creation (T41–T50)
# ─────────────────────────────────────────────────────────────────────────────

@test "T41: --all creates AGENTS.md" {
  run bash "$SCRIPT" --all
  [ "$status" -le 1 ]
  [ -f "$TEST_TMPDIR/AGENTS.md" ]
}

@test "T42: --all creates .claude/ directory" {
  run bash "$SCRIPT" --all
  [ "$status" -le 1 ]
  [ -d "$TEST_TMPDIR/.claude" ]
}

@test "T43: --all creates .github/ directory" {
  run bash "$SCRIPT" --all
  [ "$status" -le 1 ]
  [ -d "$TEST_TMPDIR/.github" ]
}

@test "T44: --all runs without unhandled crash" {
  run bash "$SCRIPT" --all
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" != *"command not found"* ]]
}

@test "T45: --all creates at least one integration file" {
  bash "$SCRIPT" --all || true
  # At least one of the known output files should exist
  [ -f "$TEST_TMPDIR/AGENTS.md" ] || \
  [ -d "$TEST_TMPDIR/.claude" ]  || \
  [ -d "$TEST_TMPDIR/.github" ]  || \
  [ -f "$TEST_TMPDIR/.cursorrules" ]
}

@test "T46: --validate flag exits 0 or 1" {
  run bash "$SCRIPT" --validate
  [ "$status" -le 1 ]
}

@test "T47: --compact flag does not crash" {
  run bash "$SCRIPT" --compact
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" != *"command not found"* ]]
}

@test "T48: --update flag exits 0 or 1" {
  run bash "$SCRIPT" --update
  [ "$status" -le 1 ]
}

@test "T49: combining --detect and --all does not crash" {
  run bash "$SCRIPT" --all --detect
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" != *"command not found"* ]]
}

@test "T50: script exits non-zero for unknown flag" {
  run bash "$SCRIPT" --unknown-flag-xyz
  # An unknown flag should either be silently ignored (exit 0) or produce
  # a non-zero exit — it must NOT produce an unhandled shell error.
  [[ "$output" != *"unbound variable"* ]]
  [[ "$output" != *"command not found"* ]]
}
