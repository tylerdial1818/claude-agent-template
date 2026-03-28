# [PROJECT_NAME]

## Project Overview
[PROJECT_DESCRIPTION]

## Tech Stack
- Language: [LANGUAGE_VERSION]
- Framework: [FRAMEWORK_VERSION]
- Database: [DATABASE]
- Testing: [TEST_FRAMEWORK]
- Linting: [LINTER]

## Directory Structure
[PROJECT_NAME]/
- src/       application code (agents CAN write here)
- tests/     test files (agents CAN write here)
- docs/      documentation (agents CAN write here)
- infra/     infrastructure configs (REQUIRE human review before applying)
- .claude/   agent configuration (DO NOT modify during development sessions)

## Commands
- Run tests:       [TEST_COMMAND]
- Run linter:      [LINT_COMMAND]
- Start dev server: bash init.sh
- Check coverage:  [COVERAGE_COMMAND]

## Agent Domain Routing
When implementing features that span multiple domains, spawn parallel agents:
- backend-dev agent: API routes, business logic, database models, server-side code
- qa-agent: Test writing, test execution, feature verification
- code-reviewer: Post-implementation quality review (read-only)
- security-reviewer: Security audit before PRs (read-only, uses Opus)

## Parallelism Rules
Run agents in parallel when tasks are in independent domains.
Run agents sequentially when:
- Task B depends on output from Task A
- Tasks touch the same files
- One task is a review of another's output

## Definition of Done
A feature is complete ONLY when ALL of the following are true:
1. All tests pass: [TEST_COMMAND]
2. Linter passes with zero warnings: [LINT_COMMAND]
3. No secrets or credentials appear in any diff
4. feature_list.json shows "passes": true for the feature
5. A descriptive commit has been written
6. claude-progress.txt has been updated

## Forbidden Operations (all agents)
- rm -rf on any path
- Direct commits to main branch
- Writing to .env files or any secrets directory
- curl or wget to external URLs
- Any operation targeting production or staging environments

## Context Management
- Run /compact when context reaches approximately 50 percent
- Each agent session must end with a claude-progress.txt update
- Run /clear before switching to an unrelated task mid-session
