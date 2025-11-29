# NixOS Migration - Getting Started

Welcome to the NixOS migration! This directory contains all the documentation you need to successfully migrate your dotfiles from Ansible to Nix.

---

## 📋 Quick Start

### For First-Time Users

**Start here:**

1. Read this file completely
2. Open `MIGRATION_LOG.md` - This is your progress tracker
3. Open `MIGRATION_CHECKLIST.md` - This is your task list
4. Begin with **Phase 0** in the checklist

### For Returning Users (Resuming Work)

**When starting a new session:**

1. Copy `SESSION_TEMPLATE.md` to `current-session.md`
2. Fill out the pre-session checklist
3. Review `MIGRATION_LOG.md` to see where you left off
4. Continue with your current phase in `MIGRATION_CHECKLIST.md`

---

## 📚 Document Overview

### Core Documents (Read These)

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **MIGRATION_LOG.md** | Track overall progress, document sessions, record decisions | Update after every session |
| **MIGRATION_CHECKLIST.md** | Detailed task-by-task checklist for all 7 phases | Reference during work, check off tasks |
| **docs/NIX_MIGRATION_GUIDE.md** | Step-by-step instructions with commands | Follow when executing tasks |

### Support Documents (Reference When Needed)

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **SESSION_TEMPLATE.md** | Template for tracking individual work sessions | Copy at start of each session |
| **docs/EMERGENCY_PROCEDURES.md** | Troubleshooting and recovery procedures | When things go wrong |
| **scripts/validate-nix.sh** | Validation script to check your setup | Run after each phase |

---

## 🗺️ Migration Overview

### The 7 Phases

```
Phase 0: Preparation (2 hours)
   └─> Install Nix, create backups, set up tracking

Phase 1: Foundation (4 hours)
   └─> Create flake.nix and directory structure

Phase 2: Core Configuration (8 hours) ⚠️ CRITICAL PHASE
   └─> Migrate all configs, activate Home Manager

Phase 3: NixOS VM Testing (6 hours)
   └─> Test NixOS configuration in virtual machine

Phase 4: NixOS Production (3 hours) ⚠️ SYSTEM WIPE
   └─> Install NixOS on real hardware

Phase 5: WSL2 Setup (3 hours)
   └─> Set up NixOS in WSL2 on Windows

Phase 6: Validation & Cleanup (3 hours)
   └─> Validate all platforms, archive Ansible

Phase 7: Documentation & Polish (3 hours)
   └─> Final docs, optimization, merge to main
```

**Total Estimated Time:** 6-8 weeks (2-4 hours per week)

---

## 🎯 Your Current Status

**Check these locations to understand where you are:**

1. **MIGRATION_LOG.md** - Look at the "Quick Status Overview" table
2. **Git branch** - Run `git branch` (should be on `nix-migration` after Phase 0)
3. **Completed phases** - Check tags: `git tag | grep phase`

### Haven't Started Yet?

✅ You're in the right place! Begin with:

1. Read `MIGRATION_LOG.md` introduction
2. Start **Phase 0** in `MIGRATION_CHECKLIST.md`
3. Follow detailed steps in `docs/NIX_MIGRATION_GUIDE.md`

### Already Started?

✅ Find where you left off:

1. Open `MIGRATION_LOG.md`
2. Read "Current Session Notes"
3. Check "Next Session Focus"
4. Resume at that point in `MIGRATION_CHECKLIST.md`

---

## 🔄 Workflow for Each Session

### Before Starting Work

```
1. Copy SESSION_TEMPLATE.md → current-session.md
2. Fill out "Pre-Session Checklist"
3. Read MIGRATION_LOG.md "Current Session Notes"
4. Review current phase in MIGRATION_CHECKLIST.md
5. Set clear goal for this session
```

### During Work

```
1. Follow MIGRATION_CHECKLIST.md tasks
2. Reference NIX_MIGRATION_GUIDE.md for commands
3. Document in current-session.md as you go
4. Test frequently (validate-nix.sh)
5. Commit after each major milestone
```

### After Work

```
1. Complete "Session End Checklist" in current-session.md
2. Update MIGRATION_LOG.md with session notes
3. Check off completed tasks in MIGRATION_CHECKLIST.md
4. Commit all changes
5. If phase complete, create git tag
6. Push to GitHub
```

---

## 🚨 Important Warnings

### Phase 2: Home Manager Activation
- **What:** This will modify your shell and PATH
- **When:** After creating all configuration files
- **Backup:** Commit everything before running activation
- **Rollback:** Can revert using `home-manager generations`

### Phase 4: NixOS Production
- **What:** This will WIPE your target machine
- **When:** After successfully testing in VM (Phase 3)
- **Backup:** ALL DATA must be backed up before starting
- **Point of no return:** Once you start partitioning, old system is gone

---

## 📖 How to Use Each Document

### MIGRATION_LOG.md
**Purpose:** Your comprehensive progress journal

**Update when:**
- Starting a new session (fill in "Current Session Notes")
- Completing a phase (mark complete, add completion date)
- Making important decisions (add to "Decisions & Rationale Log")
- Encountering issues (document in phase notes)

**Don't:**
- Delete old notes (they're valuable history)
- Skip updating (you'll forget details)

### MIGRATION_CHECKLIST.md
**Purpose:** Granular task tracking

**Use as:**
- Your primary todo list
- A way to see exactly what's left
- A guide for what to do next

**Tips:**
- Check off items as you complete them
- Don't skip items (each is important)
- If you skip something, document WHY in MIGRATION_LOG.md

### docs/NIX_MIGRATION_GUIDE.md
**Purpose:** Detailed how-to instructions

**Use for:**
- Exact commands to run
- Explanations of what each step does
- Code examples to copy
- Troubleshooting specific issues

**Organization:**
- Organized by phase
- Each phase has step-by-step instructions
- Includes validation steps
- Has troubleshooting sections

### SESSION_TEMPLATE.md
**Purpose:** Structure for individual work sessions

**How to use:**
1. Copy to `current-session.md` at start of session
2. Fill out as you work
3. Move notes to MIGRATION_LOG.md at end
4. Delete or archive current-session.md
5. Repeat next session

### scripts/validate-nix.sh
**Purpose:** Automated validation

**Run after:**
- Completing Phase 0 (verify Nix installed)
- Completing Phase 2 (verify Home Manager working)
- Any major change (verify nothing broke)
- Each phase completion (final validation)

**Usage:**
```bash
cd ~/dotfiles
./scripts/validate-nix.sh
```

### docs/EMERGENCY_PROCEDURES.md
**Purpose:** What to do when things break

**Use when:**
- Terminal won't start
- System won't boot
- Config breaks something
- Need to rollback
- Panic mode

**Keep accessible:**
- Print it out, OR
- Keep on phone/tablet, OR
- Bookmark on another computer

---

## ⚙️ Git Workflow

### Branches

```
main              <- Production, working Ansible setup
  └─ ansible-backup  <- Safe backup of Ansible (Phase 0)
  └─ nix-migration   <- Where all work happens (Phase 1-7)
```

### Tags

After each phase completion:
```bash
git tag -a phase-0-complete -m "Phase 0: Preparation complete"
git tag -a phase-1-complete -m "Phase 1: Foundation complete"
# ... etc
```

Final tag:
```bash
git tag -a v2.0.0 -m "Complete Nix migration"
```

### When to Commit

**After each major task:**
```bash
git add .
git commit -m "Phase 2.3: Add zsh configuration"
```

**Before risky operations:**
```bash
git add .
git commit -m "Before activating Home Manager"
```

**At end of session:**
```bash
git add .
git commit -m "Session 5: Completed Phase 2.1-2.5"
git push origin nix-migration
```

---

## 🎓 Key Concepts

### What is Nix?
A package manager and configuration language that allows you to declaratively define your entire system.

### What is Home Manager?
A tool that uses Nix to manage user-level configuration (dotfiles, packages, programs).

### What are Flakes?
The modern way to structure Nix projects. Your `flake.nix` is the entry point.

### What is NixOS?
A Linux distribution built entirely on Nix principles. Your entire OS is defined in configuration files.

### What is nix-darwin?
Like NixOS but for macOS. System-level configuration for Mac.

### Why is this better than Ansible?
- **Declarative:** Describe what you want, not how to get there
- **Reproducible:** Same config = same result, every time
- **Atomic:** Changes are all-or-nothing
- **Rollback:** Can revert to any previous generation
- **Cross-platform:** Same config works on NixOS, macOS, WSL

---

## 🆘 Getting Help

### When Stuck

1. **Check EMERGENCY_PROCEDURES.md** - Common issues are documented
2. **Review MIGRATION_LOG.md** - Did you encounter this before?
3. **Check git history** - What changed recently?
4. **Run validation** - `./scripts/validate-nix.sh`
5. **Ask for help** - NixOS Discourse, Reddit r/NixOS

### Before Asking for Help Online

Gather this info:
- What phase are you on?
- What command did you run?
- What was the error message? (full output)
- What does `nix --version` show?
- What platform? (macOS, NixOS, WSL)
- Can you reproduce with a minimal example?

### Resources

- **NixOS Manual:** https://nixos.org/manual/nixos/stable/
- **Home Manager Manual:** https://nix-community.github.io/home-manager/
- **Nix Package Search:** https://search.nixos.org/
- **NixOS Discourse:** https://discourse.nixos.org/
- **NixOS Wiki:** https://nixos.wiki/

---

## ✅ Success Criteria

**You'll know the migration is complete when:**

- [ ] All 7 phases marked complete in MIGRATION_LOG.md
- [ ] `./scripts/validate-nix.sh` passes on all platforms
- [ ] Can rebuild any platform with one command
- [ ] Can add packages by editing one file
- [ ] Can rollback any change
- [ ] Documentation is complete
- [ ] Ansible is archived in `legacy/`
- [ ] Tagged v2.0.0 and merged to `main`

---

## 🎉 Ready to Begin?

**Your next steps:**

1. ✅ You just read this file
2. ⏭️ Open `MIGRATION_LOG.md` and read the introduction
3. ⏭️ Open `MIGRATION_CHECKLIST.md` and start Phase 0
4. ⏭️ Follow `docs/NIX_MIGRATION_GUIDE.md` for detailed steps

**Remember:**
- Take your time - this is a 6-8 week project
- Document everything in MIGRATION_LOG.md
- Commit frequently
- Don't skip validation steps
- Ask for help when stuck

**Good luck! You've got this! 🚀**

---

## Document Status

**Created:** [Date this was created]  
**Last Updated:** [Update when making changes]  
**Version:** 1.0  
**Maintained By:** You!

Keep this README updated as you discover better workflows or encounter new issues.
