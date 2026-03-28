#!/bin/bash
# Pre-bash guardrail hook
# Receives tool input via CLAUDE_TOOL_INPUT env var
# Exit 2 = block the command and show message to Claude
# Exit 0 = allow

COMMAND="${CLAUDE_TOOL_INPUT}"

# Block production-targeting operations
if echo "$COMMAND" | grep -qiE "(prod|production|staging)"; then
  echo "BLOCKED: Command targets a production or staging environment. Require explicit human confirmation before proceeding." >&2
  exit 2
fi

# Block force pushes
if echo "$COMMAND" | grep -qE "git push.*--force|git push.*-f"; then
  echo "BLOCKED: Force push is not allowed. Use --force-with-lease if necessary and confirm with the user." >&2
  exit 2
fi

# Block direct pushes to main or master
if echo "$COMMAND" | grep -qE "git push.*origin (main|master)"; then
  echo "BLOCKED: Direct push to main/master is not allowed. Open a PR instead." >&2
  exit 2
fi

# Block recursive deletion
if echo "$COMMAND" | grep -qE "rm -rf|rm -fr"; then
  echo "BLOCKED: Recursive deletion is not permitted. Remove files individually or ask the user to perform deletion." >&2
  exit 2
fi

# Log all bash commands for audit trail
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] CMD: $COMMAND" >> .claude/audit.log

exit 0
