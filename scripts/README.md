# Scripts

Utility scripts for development workflow automation.

## Create Session Script

### Purpose
Create a new session document from GitHub Issue or manually.

### Usage

```bash
./scripts/create-session.sh
```

### What it does

**Option 1: From GitHub Issue**
1. **Lists open GitHub issues** using `gh` CLI
2. **Fetches issue details** (title, body, labels)
3. **Creates session file** with auto-filled information
4. **Names file** based on issue title (slugified)

**Option 2: Manual Creation**
1. **Prompts for feature name**
2. **Creates session** from template
3. **Auto-fills date**

### Interactive Flow

```
=== Create Session from GitHub Issue ===

How do you want to create the session?
1) From GitHub Issue (fetch issue details)
2) Manual (just create empty session)
Choice: 1

Fetching open issues...

Open Issues:
  #123 - Implement offline sync [feature, priority-high]
  #124 - Fix token refresh bug [bug]
  #125 - Add Google login [feature]

Enter issue number (or 'q' to quit): 123

Fetching issue #123...

✅ Session created: docs/sessions/2025-11/15-implement-offline-sync.md

Issue Details:
  Number: #123
  Title: Implement offline sync
  Labels: feature, priority-high

Open in editor? (y/n): y

Next steps:
1. Fill in Plan section (approach, decisions)
2. Fill in Implementation section (phases, tasks)
3. Start coding!
```

### Requirements

- **GitHub CLI** (`gh`) installed and authenticated
  - Install: https://cli.github.com/
  - Auth: `gh auth login`
- Bash shell
- `docs/sessions/template.md` exists

### Features

- ✅ Auto-fetch issue details from GitHub
- ✅ Auto-fill issue number, title, labels
- ✅ Include issue body in Context section
- ✅ Auto-generate filename from issue title
- ✅ Organize by month (YYYY-MM/)
- ✅ Optional editor opening

### Example Workflow

```bash
# 1. Create session from issue
./scripts/create-session.sh
# Select option 1, choose issue #123

# 2. Fill in Plan and Implementation sections
vim docs/sessions/2025-11/15-offline-sync.md

# 3. Start coding
git commit -m "feat: start offline sync

Part of docs/sessions/2025-11/15-offline-sync.md"

# 4. When done, archive
./scripts/archive-session.sh
```

---

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
