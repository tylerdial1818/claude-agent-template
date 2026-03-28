# claude-agent-template

A multi-agent Claude Code scaffold for building apps fast without sacrificing
engineering quality. Clone it, run two commands, and a coordinated team of AI
agents starts building your project from a structured spec.

---

## What this gives you

- A pre-configured Claude Code agent team (developer, QA, code reviewer, security reviewer)
- Git worktree support for parallel agent execution
- Security hooks that block dangerous operations and scan for secrets on every file write
- A GitHub Actions pipeline wired for lint, secret scanning, and test coverage
- Two custom commands — `/prd` for spec generation and `/dialedspec` for project configuration
- A cross-session memory system (`claude-progress.txt` + `feature_list.json`) so agents
  always know where things stand

---

## Requirements

- [Claude Code](https://claude.ai/code) installed and authenticated
- A Claude Max or Team subscription (Opus model access required for the security agent)
- [GitHub CLI](https://cli.github.com) installed and authenticated
- Git 2.5 or later

---

## Quickstart

### 1. Create your project from this template

```bash
gh repo create my-app-name \
  --template OWNER/claude-agent-template \
  --private \
  --clone

cd my-app-name
```

Replace `OWNER` with the GitHub username or org where this template lives.

### 2. Open Claude Code

```bash
claude
```

### 3. Generate your spec

```
/prd
```

Answer the questions. The skill will interrogate you about your project,
propose a simplified implementation plan, and write a full PRD to
`docs/prds/your-app.md`.

### 4. Configure the project

```
/dialedspec
```

This reads your PRD and configures everything: `CLAUDE.md`, `feature_list.json`,
`init.sh`, and the GitHub Actions pipeline. It also removes agent definitions
that are not needed for your specific project. No manual file editing required.

### 5. Verify the environment

Exit Claude Code and run:

```bash
bash init.sh
```

It should complete without errors. If it fails, fix the issue before starting
any agents.

### 6. Commit the configured scaffold

```bash
git add -A
git commit -m "chore: configure project from PRD"
git push -u origin main
```

### 7. Start building

Back in Claude Code:

```
Start implementing features from feature_list.json, beginning with the
highest priority incomplete feature. Use a worktree for each feature.
```

The agent team handles the rest.

---

## How the agent team works

Each agent has a defined role and tool scope. They cannot exceed their
permissions.

| Agent | Role | Model | Can write code |
|---|---|---|---|
| `backend-dev` | Implements features | Sonnet | Yes |
| `frontend-dev` | Implements UI components | Sonnet | Yes |
| `data-engineer` | Migrations, pipelines, bulk ops | Sonnet | Yes |
| `infra-agent` | Docker, CI/CD configs (plan only) | Sonnet | Configs only |
| `prompt-engineer` | AI prompts and evals | Opus | Prompts only |
| `qa-agent` | Verifies features, updates feature_list.json | Sonnet | Tests only |
| `code-reviewer` | Reviews diffs for quality and correctness | Sonnet | No |
| `security-reviewer` | Audits for vulnerabilities before PRs | Opus | No |

Not every project needs all agents. `/dialedspec` removes irrelevant agents
based on your spec (e.g., no `frontend-dev` for a pure API project).

For each feature the loop runs in this order:

```
backend-dev implements → qa-agent verifies → code-reviewer reviews
→ security-reviewer audits → PR opened → GitHub Actions runs → merge
```

---

## Key files

| File | Purpose |
|---|---|
| `CLAUDE.md` | Agent instructions, conventions, definition of done |
| `feature_list.json` | Structured feature list with pass/fail status |
| `claude-progress.txt` | Cross-session log so agents always know what happened |
| `init.sh` | Environment setup and smoke test — runs at the start of every session |
| `.claude/agents/` | Agent definitions (role, tools, model, system prompt) |
| `.claude/commands/` | Custom slash commands (`/dialedspec`) |
| `.claude/hooks/` | Security hooks that run on every bash command and file write |
| `.claude/settings.json` | Permission allowlist and denylist |

---

## Security model

Two hooks run automatically on every agent action:

**Pre-bash hook** blocks:
- Commands targeting production or staging environments
- Force pushes to any branch (allows `--force-with-lease` with confirmation)
- Direct pushes to main or master
- Recursive deletion (`rm -rf`)
- Output redirection or file copies to `.env`, `secrets/`, or `credentials/`

All bash commands are logged to `.claude/audit.log`.

**Post-write hook** scans every written file for:
- AWS access keys
- API keys and tokens (OpenAI, Stripe, GitHub, Slack)
- Private keys
- Database connection strings with embedded passwords

The hook warns but does not block writes, so agents can recover and fix issues.

The permission system also denies reading or writing `.env` files, secrets
directories, and credential directories by default.

---

## For complex projects: optional Stage 1

For projects with non-obvious architecture decisions, run a strategy
conversation in claude.ai before opening Claude Code. Cover: architecture
shape, data modeling, auth approach, external integrations, and engineering
constraints. At the end, ask:

```
Summarize the decisions we made as a decisions.md file. For each decision
include what we decided, why, and what we are explicitly not doing.
```

Save `decisions.md` to the project root, then paste its contents as context
before running `/prd`. The skill will use your decisions to produce a more
targeted spec without re-litigating settled questions.

---

## Daily workflow for ongoing development

**Starting a session:**
```
Read claude-progress.txt and git log to get up to speed, then run bash init.sh
to verify the environment. Tell me the current status and which features in
feature_list.json are still incomplete.
```

**During a session:**
- Run `/compact` when context reaches approximately 50%
- Review every PR diff before merging — agents produce good code but are not a
  substitute for your judgment
- If an agent goes wrong, use `/rewind` to undo and give clearer instructions
  rather than trying to patch the same session

**Ending a session:**
- Confirm `claude-progress.txt` has an entry for today
- Confirm no uncommitted changes in any worktree: `git worktree list`
- Prune completed worktrees: `git worktree prune`

---

## Troubleshooting

**`/dialedspec` says no spec document found**
Run `/prd` first to generate a spec, then run `/dialedspec` again.

**`bash init.sh` fails**
The error output will tell you what is missing. Common causes: missing virtual
environment, missing dependencies, wrong Python or Node version. Fix the
underlying issue before starting any agents.

**Placeholder tokens still in CLAUDE.md after `/dialedspec`**
Run `grep -n "\[" CLAUDE.md` to find them. Either your PRD was missing those
values or the command skipped a section. Fill them in manually or re-run
`/dialedspec` after adding the missing information to your PRD.

**Agent keeps making the wrong decision**
The agent is working from ambiguous acceptance criteria. Update the relevant
feature entry in `feature_list.json` to be more specific, use `/rewind` to
undo the work, and restart that feature.

**GitHub Actions failing on secret scan**
An agent wrote a credential into a file. Check the trufflehog output for the
file and line number. Remove the credential, rotate it if it was real, and
commit the fix. Review the post-write hook output in `.claude/audit.log` to
see when it was written.

---

## Customizing for your stack

This template ships with Python defaults. For TypeScript projects, `/dialedspec`
will automatically update:

- `.github/workflows/agent-pr-check.yml` — swaps Python setup for Node
- `CLAUDE.md` — adjusts directory structure and commands
- `init.sh` — uses npm instead of pip/venv

For teams, add your organization's specific conventions to `CLAUDE.md` and
your agent definitions. Agents follow whatever is in those files.

---

## License

MIT
