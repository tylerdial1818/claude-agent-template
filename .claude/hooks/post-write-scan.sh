#!/bin/bash
# Post-write secret scanner hook
# Runs after every file write or edit
# Scans the written file for accidental secrets

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
PATTERNS=(
  "AKIA[0-9A-Z]{16}"
  "sk-[a-zA-Z0-9]{32,}"
  "ghp_[a-zA-Z0-9]{36}"
  "xox[baprs]-[a-zA-Z0-9]"
  "-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----"
  "password\s*=\s*['\"][^'\"]{6,}"
  "api_key\s*=\s*['\"][^'\"]{8,}"
  "secret\s*=\s*['\"][^'\"]{8,}"
)

for PATTERN in "${PATTERNS[@]}"; do
  if grep -qiP "$PATTERN" "$FILE_PATH" 2>/dev/null; then
    echo "WARNING: Potential secret detected in $FILE_PATH matching pattern: $PATTERN" >&2
    echo "Review this file before committing. Do not commit credentials." >&2
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SECRET_SCAN_WARNING: $FILE_PATH pattern=$PATTERN" >> .claude/audit.log
    exit 1
  fi
done

exit 0
