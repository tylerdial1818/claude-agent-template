#!/bin/bash
# Project initialization and smoke test script
# Run at the start of each agent session to verify the environment is healthy

set -e

echo "=== Initializing [PROJECT_NAME] ==="

if [ ! -f "CLAUDE.md" ]; then
  echo "ERROR: Not in project root. CLAUDE.md not found."
  exit 1
fi

# [STACK-SPECIFIC SETUP — populated by /dialedspec]

# [DEV SERVER START — populated by /dialedspec]

echo "=== Running smoke test ==="
# [TEST_COMMAND]

echo "=== Environment ready ==="
