# Scripts

Utility scripts for development workflow automation.

## Archive Session Script

### Purpose
Automate the process of archiving completed session documents after knowledge extraction.

### Usage

```bash
./scripts/archive-session.sh
```

### What it does

1. **Lists current sessions** in `docs/sessions/current/`
2. **Validates extraction checklist** exists in selected session
3. **Displays knowledge extraction status**
4. **Guides archive decision**:
   - Option 1: Delete immediately (most sessions)
   - Option 2: Cancel to extract knowledge first
   - Option 3: Move to notable/ (rare, <5%)
5. **Creates git commit** with appropriate message

### Interactive Flow

```
=== Session Archive Tool ===

Current sessions:
  [0] 15-offline-sync.md
  [1] 16-analytics-dashboard.md

Select session number to archive (or 'q' to quit): 0

Selected: 15-offline-sync.md

Checking knowledge extraction...

Knowledge Extraction Status:
[Displays extraction checklist from session]

Has all knowledge been extracted?
1) Yes - Delete immediately (knowledge fully extracted)
2) No - Need to extract first (cancel)
3) Yes - Move to notable/ (major architectural significance)
4) Cancel

Choice: 1

Preparing to delete session...

Knowledge preserved in:
- docs/ADR/006-offline-sync-queue.md
- docs/architecture/offline-sync.md

Commit message (or press Enter for default):

✅ Session deleted and committed
```

### Requirements

- Git repository
- Bash shell
- `docs/sessions/current/` directory exists
- Session files follow template format with "Extraction Checklist"

### Safety Features

- ✅ Validates session selection
- ✅ Checks for extraction checklist
- ✅ Shows knowledge preservation locations
- ✅ Confirms before deletion
- ✅ Creates git commit (can be undone)

### Recovery

If you accidentally delete a session:

```bash
# Find the deletion commit
git log --all --oneline | grep "remove session"

# View the session content
git show <commit-hash>:docs/sessions/current/15-feature.md

# Restore if needed
git show <commit-hash>:docs/sessions/current/15-feature.md > restored-session.md
```

## Future Scripts

Potential additions:

- `create-session.sh` - Interactive session creation
- `validate-session.sh` - Check session completeness
- `sync-todos.sh` - Sync session checklist with GitHub issues
