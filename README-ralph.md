# Ralph - Autonomous AI Coding Loop

Ralph is a technique for running AI coding agents in a loop. The AI reads a PRD (Product Requirements Document), picks tasks autonomously, implements them one at a time, and commits after each feature. You can run it in human-in-the-loop mode or go fully AFK (away from keyboard) while it works.

## What is Ralph?

Ralph automates incremental development by:
1. Reading a PRD and progress file
2. Selecting the next uncompleted task
3. Implementing the task
4. Running tests and type checks
5. Committing changes
6. Updating progress
7. Repeating until the PRD is complete

## Prerequisites

Before using Ralph, you need to install:

1. **Claude Code** - Anthropic's CLI for agentic coding
   - Install via native binary: `curl -fsSL https://claude.ai/install.sh | bash`
   - Or via npm: `npm i -g @anthropic-ai/claude-code`
   - Run `claude` to authenticate with your Anthropic account

2. **Docker Desktop 4.50+** - For running Claude Code in isolated sandboxes
   - Install from: https://docs.docker.com/desktop/install
   - Run `docker sandbox run claude` to authenticate

## Files in This Directory

- **PRD.md** - Product Requirements Document containing all tasks
- **progress.txt** - Log of completed tasks (auto-updated by Ralph)
- **ralph-once.sh** - Human-in-the-loop mode (run one iteration at a time)
- **afk-ralph.sh** - Autonomous mode (run multiple iterations unattended)

## Getting Started

### 1. Create Your PRD

Edit `PRD.md` to define your project requirements. You can:
- Write it manually, or
- Use Claude's plan mode: run `claude` and press `shift-tab`, then ask Claude to save the plan to `PRD.md`

The PRD can be in any format (markdown checklist, JSON, plain prose). What matters is:
- The scope is clear
- Individual tasks can be identified by the agent
- Tasks are small enough to implement incrementally

### 2. Make Scripts Executable

```bash
chmod +x ralph-once.sh
chmod +x afk-ralph.sh
```

### 3. Start with Human-in-the-Loop

Run Ralph once to see what it does:

```bash
./ralph-once.sh
```

This runs a single iteration. Watch what Claude does, check the commit, review progress.txt, then run it again when ready.

Benefits:
- Builds intuition for how the loop works
- Lets you catch issues early
- Helps you refine your PRD

### 4. Go AFK (Autonomous Mode)

When you're comfortable with how Ralph works, run multiple iterations unattended:

```bash
./afk-ralph.sh 20
```

This runs up to 20 iterations or until the PRD is complete. Claude will:
- Automatically pick tasks
- Implement them one by one
- Run tests and type checks
- Commit changes
- Update progress
- Stop when done (outputs `<promise>COMPLETE</promise>`)

## How It Works

### Human-in-the-Loop Mode (`ralph-once.sh`)

- Uses `--permission-mode acceptEdits` to auto-accept file edits
- References `@PRD.md` and `@progress.txt` for context
- Runs interactively (you see the chat interface)
- Enforces "ONLY DO ONE TASK AT A TIME" for small commits

### Autonomous Mode (`afk-ralph.sh`)

- Uses `docker sandbox run claude` for isolation
- Runs in print mode (`-p`) for non-interactive output
- Captures output to check for completion sigil
- Exits early if PRD is complete
- Caps iterations to prevent runaway costs

## Key Script Elements

| Element | Purpose |
|---------|---------|
| `--permission-mode acceptEdits` | Auto-accepts file edits so the loop doesn't stall |
| `@PRD.md` | Points Claude at your requirements doc |
| `@progress.txt` | Tracks completed work between runs |
| `ONLY DO ONE TASK` | Forces small, incremental commits |
| `set -e` | Exit on any error |
| `$1` (iterations) | Caps the loop to prevent runaway costs |
| `-p` | Print mode - non-interactive output |
| `<promise>COMPLETE</promise>` | Completion sigil Claude outputs when done |

## Tips for Success

### Writing Good PRDs

1. **Be specific** - "Add user authentication with JWT" is better than "Add login"
2. **Break it down** - Smaller tasks = smaller commits = easier to review
3. **Prioritize** - Put high-priority items first
4. **Include testing** - Mention test requirements in the PRD
5. **Define success** - Be clear about what "done" looks like

### Running Ralph

1. **Start small** - Begin with human-in-the-loop mode
2. **Monitor progress** - Check commits and progress.txt regularly
3. **Cap iterations** - Start with 5-10 iterations, increase as you gain confidence
4. **Review commits** - Check what Claude did before merging
5. **Iterate on the PRD** - Refine based on what works and what doesn't

## Customization Ideas

Ralph is just a loop - you can customize it for different workflows:

### Different Task Sources
- Pull from GitHub Issues instead of local PRD
- Use Linear API for task management
- Read from a Jira board

### Different Outputs
- Create a branch + PR for each task instead of committing to main
- Post updates to Slack or Discord
- Generate documentation automatically

### Different Loop Types

| Loop Type | What It Does |
|-----------|--------------|
| Test Coverage | Finds uncovered lines, writes tests until coverage hits target |
| Linting | Fixes lint errors one by one |
| Duplication | Detects code duplication, refactors into shared utilities |
| Entropy | Scans for code smells, cleans them up |

Any task that fits "look at repo, improve something, commit" works with Ralph.

## Troubleshooting

### "command not found: claude"
Add Claude to your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Docker sandbox authentication
Run `docker sandbox run claude` to authenticate. Your credentials are stored in a Docker volume.

### Ralph keeps doing the wrong task
- Refine your PRD to be more specific
- Update progress.txt to clearly mark completed tasks
- Reduce task scope (smaller is better)

### Tests keep failing
- Add "ensure tests pass" as a requirement in the PRD
- Run human-in-the-loop mode to debug
- Fix the test infrastructure first, then let Ralph continue

## Resources

- [Original Ralph concept by Geoffrey Huntley](https://ghuntley.com/ralph/)
- [11 Tips for AI Coding with Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Docker Sandboxes Documentation](https://docs.docker.com/ai/sandboxes/)

## License

These scripts are provided as examples. Adapt them for your own projects as needed.
