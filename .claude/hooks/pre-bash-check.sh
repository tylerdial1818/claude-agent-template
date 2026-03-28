#!/bin/bash
# Pre-bash guardrail hook
# Receives tool input via CLAUDE_TOOL_INPUT env var
# Exit 2 = block the command and show message to Claude
# Exit 0 = allow

COMMAND="${CLAUDE_TOOL_INPUT}"

# Block output redirection to sensitive paths
if echo "$COMMAND" | grep -qE ">\s*\.env|>\s*secrets/|>\s*credentials/"; then
  echo "BLOCKED: Output redirection to a sensitive path is not allowed." >&2
  exit 2
fi

# Block cp/mv targeting sensitive paths
if echo "$COMMAND" | grep -qE "(cp|mv)\s+.*\s+\.env|( cp| mv)\s+.*\s+secrets/|( cp| mv)\s+.*\s+credentials/"; then
  echo "BLOCKED: Copying or moving files to sensitive paths is not allowed." >&2
  exit 2
fi

# Block production-targeting operations (word boundaries to avoid false positives)
if echo "$COMMAND" | grep -qE "\b(prod|production|staging)\b"; then
  echo "BLOCKED: Command targets a production or staging environment. Require explicit human confirmation before proceeding." >&2
  exit 2
fi

# Allow --force-with-lease explicitly, block all other force pushes
if echo "$COMMAND" | grep -qE "git push.*--force-with-lease"; then
  : # allowed, fall through to logging
elif echo "$COMMAND" | grep -qE "git push.*--force|git push.*\s-[a-zA-Z]*f"; then
  echo "BLOCKED: Force push is not allowed. Use --force-with-lease if necessary and confirm with the user." >&2
  exit 2
fi

# Block direct pushes to main or master (anchored to end of command or followed by space)
if echo "$COMMAND" | grep -qE "git push\s+\S+\s+(main|master)(\s|$)"; then
  echo "BLOCKED: Direct push to main/master is not allowed. Open a PR instead." >&2
  exit 2
fi

# Block recursive deletion
if echo "$COMMAND" | grep -qE "rm\s+-[a-zA-Z]*r[a-zA-Z]*f|rm\s+-[a-zA-Z]*f[a-zA-Z]*r"; then
  echo "BLOCKED: Recursive deletion is not permitted. Remove files individually or ask the user to perform deletion." >&2
  exit 2
fi

# Log all bash commands for audit trail
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] CMD: $COMMAND" >> .claude/audit.log

exit 0
