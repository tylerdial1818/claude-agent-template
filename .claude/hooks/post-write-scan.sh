#!/bin/bash
# Post-write secret scanner hook
# Runs after every file write or edit
# Scans the written file for accidental secrets
# Warns but does NOT block writes (exit 0) so agents can recover

FILE_PATH="${CLAUDE_TOOL_RESULT_FILE:-}"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip binary files, lock files, and the audit log itself
if echo "$FILE_PATH" | grep -qE "\.(png|jpg|jpeg|gif|ico|woff|woff2|ttf|eot|pdf|lock)$|audit\.log$"; then
  exit 0
fi

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Secret pattern scan
# Uses grep -E (POSIX extended regex) for portability instead of grep -P
PATTERNS=(
  "AKIA[0-9A-Z]{16}"
  "sk-[a-zA-Z0-9]{32,}"
  "sk_live_[a-zA-Z0-9]{24,}"
  "sk_test_[a-zA-Z0-9]{24,}"
  "ghp_[a-zA-Z0-9]{36}"
  "gho_[a-zA-Z0-9]{36}"
  "github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}"
  "xox[baprs]-[a-zA-Z0-9]"
  "-----BEGIN (RSA|EC|OPENSSH|DSA|PGP) PRIVATE KEY-----"
  "mongodb(\+srv)?://[^[:space:]]+"
  "postgres(ql)?://[^[:space:]]*:[^[:space:]]*@"
  "mysql://[^[:space:]]*:[^[:space:]]*@"
)

FOUND=0
for PATTERN in "${PATTERNS[@]}"; do
  if grep -qiE "$PATTERN" "$FILE_PATH" 2>/dev/null; then
    echo "WARNING: Potential secret detected in $FILE_PATH matching pattern: $PATTERN" >&2
    echo "Review this file before committing. Do not commit credentials." >&2
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SECRET_SCAN_WARNING: $FILE_PATH pattern=$PATTERN" >> .claude/audit.log
    FOUND=1
  fi
done

if [ "$FOUND" -eq 1 ]; then
  echo "SECRET SCAN: One or more potential secrets detected. Review the warnings above." >&2
fi

# Always exit 0 — warn, never block. Blocking breaks agent recovery.
exit 0
