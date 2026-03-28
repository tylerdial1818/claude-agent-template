# [PROJECT_NAME]

[PROJECT_DESCRIPTION]

## Quick Start

Clone and enter the project, open Claude Code, then run /dialedspec to
configure the project for your stack before any development begins.

## Agent System

This project uses a multi-agent Claude Code setup.

Agent roles:
- backend-dev: Feature implementation (Sonnet)
- qa-agent: Testing and verification (Sonnet)
- code-reviewer: Quality review, read-only (Sonnet)
- security-reviewer: Security audit, read-only (Opus)

## Daily Workflow

1. Open Claude Code in project root
2. Run bash init.sh to verify environment health
3. Ask the orchestrator to work on the next feature in feature_list.json
4. Orchestrator delegates to developer agent, using a worktree for parallel work
5. QA agent verifies and updates feature_list.json
6. Code reviewer and security reviewer run before any PR is opened
7. Append a summary to claude-progress.txt at the end of each session

## Key Files

- CLAUDE.md — agent instructions and project conventions
- feature_list.json — structured feature list with pass/fail status
- claude-progress.txt — cross-session progress log
- .claude/agents/ — specialized agent definitions
- .claude/hooks/ — security and audit hooks
- .claude/commands/dialedspec.md — project configuration command
