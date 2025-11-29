# Migration Session Template

**Copy this template to start each new AI/work session**

---

## Session Information

**Date:** [YYYY-MM-DD]  
**Session Number:** [X]  
**Estimated Duration:** [X hours]  
**Current Phase:** [Phase X: Name]

---

## Pre-Session Checklist

Before starting work, complete these checks:

- [ ] Read `MIGRATION_LOG.md` - check current phase and last session notes
- [ ] Read `MIGRATION_CHECKLIST.md` - review what's been completed
- [ ] Run `git status` - check for uncommitted changes
- [ ] Run `git branch` - verify on correct branch (should be `nix-migration`)
- [ ] Check current system still works:
  - [ ] Terminal opens
  - [ ] Can run basic commands
  - [ ] No broken configurations

---

## Session Goal

**Today's Objective:**
[Write 1-2 specific tasks you want to accomplish this session]

Example:
- Complete Phase 2.1-2.3: Create packages.nix and shell configs
- Test Home Manager build

**Success Criteria:**
[How will you know this session was successful?]

Example:
- packages.nix created with all packages from Ansible
- zsh.nix created and imports successfully
- `nix build .#homeConfigurations.chris.activationPackage` succeeds

---

## Current Status Summary

**Last Completed Task:**
[What was the last thing finished?]

**Current Task:**
[What are you working on now?]

**Blockers/Issues:**
[Any problems from last session?]

---

## Work Log

### Task 1: [Name]
**Started:** [Time]
**Status:** In Progress / Complete / Blocked

**What I Did:**
- 
- 

**Commands Run:**
```bash
# Paste commands here for reference
```

**Result:**
- 

**Issues Encountered:**
- 

---

### Task 2: [Name]
**Started:** [Time]
**Status:** In Progress / Complete / Blocked

**What I Did:**
- 
- 

**Commands Run:**
```bash
# Paste commands here
```

**Result:**
- 

---

## Testing & Validation

**Tests Run:**
- [ ] `nix flake check` - Syntax validation
- [ ] `nix build .#homeConfigurations.USERNAME.activationPackage` - Build test
- [ ] [Other relevant tests]

**Test Results:**
✅ Passed / ❌ Failed

**Failures:**
[If any tests failed, what was the error?]

---

## Commits Made This Session

```bash
# List commits
git log --oneline -n 5

# Example:
# abc1234 Add zsh configuration
# def5678 Create packages.nix with core packages
```

**Files Changed:**
```bash
git status
git diff --stat HEAD~1
```

---

## Issues & Solutions

### Issue 1: [Brief description]
**Error Message:**
```
[Paste error here]
```

**What I Tried:**
1. 
2. 

**Solution:**
[How it was resolved]

**Lesson Learned:**
[What to remember for next time]

---

### Issue 2: [Description]
[Same format as above]

---

## Decisions Made

### Decision 1: [Date]
**Context:** [Why did this decision come up?]

**Options Considered:**
1. Option A - [pros/cons]
2. Option B - [pros/cons]

**Decision:** [What was chosen and why?]

**Impact:** [How does this affect the migration?]

---

## Session End Checklist

Before ending the session:

- [ ] Update `MIGRATION_LOG.md`:
  - [ ] Fill in "Current Session Notes" section
  - [ ] Update phase progress
  - [ ] Mark completed tasks
  - [ ] Document any issues
- [ ] Update `MIGRATION_CHECKLIST.md`:
  - [ ] Check off completed items
  - [ ] Note any skipped items
- [ ] Commit all changes:
  ```bash
  git status
  git add .
  git commit -m "Session X: [Brief description]"
  ```
- [ ] If phase completed, create tag:
  ```bash
  git tag -a phase-X-complete -m "Phase X description"
  ```
- [ ] Push to remote:
  ```bash
  git push origin nix-migration --tags
  ```
- [ ] Test system still works:
  - [ ] Terminal opens
  - [ ] Basic commands work
  - [ ] No errors on restart

---

## Next Session Planning

**Next Session Should Focus On:**
1. 
2. 

**Estimated Time Needed:** [X hours]

**Prerequisites/Preparation:**
- 
- 

**Potential Challenges:**
- 
- 

**Resources Needed:**
- Links to docs:
- Commands to have ready:

---

## Notes & Observations

**What Went Well:**
- 
- 

**What Was Challenging:**
- 
- 

**Surprises/Learnings:**
- 
- 

**Questions for Next Session:**
1. 
2. 

---

## Quick Reference for This Session

**Key Commands Used:**
```bash
# Build test
nix build .#homeConfigurations.USERNAME.activationPackage

# Flake check
nix flake check

# Home Manager switch (when ready)
home-manager switch --flake .#USERNAME

# Rebuild NixOS (later phases)
sudo nixos-rebuild switch --flake .#desktop
```

**Important File Paths:**
- Flake: `~/dotfiles/flake.nix`
- Home config: `~/dotfiles/home/default.nix`
- Programs: `~/dotfiles/home/programs/`
- Logs: `MIGRATION_LOG.md`

**Useful Nix Commands:**
```bash
# Search for packages
nix search nixpkgs PACKAGE_NAME

# Show flake outputs
nix flake show

# Show detailed error trace
nix build --show-trace

# List Home Manager generations
home-manager generations

# Rollback Home Manager
/nix/store/PREVIOUS-GENERATION/activate
```

---

## AI Assistant Resume Context

**For AI assistants resuming this work:**

**Current State:**
- Branch: nix-migration
- Phase: [X]
- Last Completed: [Task]
- Current Working On: [Task]

**What Works:**
- [List what's confirmed working]

**What Doesn't Work Yet:**
- [List known issues]

**Next Steps:**
1. [Specific next action]
2. [Then this]
3. [Then that]

**Important Context:**
- Username: [your username]
- Home directory: [/Users/username or /home/username]
- Platform: [macOS / NixOS / WSL]
- Special considerations: [any unique setup details]

---

## Session Summary

**Duration:** [Actual time spent]

**Accomplishments:**
1. 
2. 
3. 

**Tasks Completed:** [X/Y]

**Phase Progress:** [X%]

**Overall Migration Progress:** [X/7 phases complete]

**Mood:** 😊 Great / 😐 Okay / 😓 Challenging

**Energy Level for Next Session:** High / Medium / Low

---

**Session End Time:** [Time]  
**Next Session Planned:** [Date/Time]

---

## Archive

Once session is complete, copy these notes to `MIGRATION_LOG.md` under "Session History" section, then archive or delete this file.
