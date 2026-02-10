# Git Sync

Synchronize a git repository: pull, commit, push workflow.

---

/git-sync [direction]

---

Streamlined git synchronization workflow with safety checks.

## Directions

- `pull` - Pull latest changes with rebase
- `push` - Stage, commit, and push changes
- `full` - Pull, then push any local changes

## Workflow: Pull

1. Check for uncommitted local changes (warn if present)
2. `git fetch` to check for remote changes
3. `git pull --rebase` to apply updates
4. Report what changed

## Workflow: Push

1. Show `git status` for review
2. Show `git diff --staged` for staged changes
3. Ask user for commit message (or suggest one based on changes)
4. `git add` relevant files
5. `git commit`
6. `git push`

## Workflow: Full

Combines pull and push workflows in sequence.

## Safety Checks

- Warn about uncommitted changes before pull
- Never force push
- Show diff before committing
- Confirm before pushing to protected branches (main/master)

## Usage Examples

```
/git-sync pull    # Get latest changes
/git-sync push    # Commit and push local changes
/git-sync full    # Complete sync cycle
```

## Output Format

```
=== Git Sync: Pull ===

Fetched from origin/main
Applied 3 commits:
  - abc1234 Fix typo in config
  - def5678 Add new feature
  - ghi9012 Update dependencies

No conflicts. Working tree clean.
```
