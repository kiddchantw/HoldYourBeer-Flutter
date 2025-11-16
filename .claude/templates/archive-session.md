# Session Archive Workflow

This template guides you through archiving a completed session.

## Before Archiving

### 1. Complete the Session

Ensure the session file has:
- [x] ✅ Planning section filled
- [x] ✅ Implementation checklist complete
- [x] ✅ Outcome section filled
- [x] ✅ Lessons learned documented

### 2. Extract ALL Knowledge

**Knowledge Extraction Checklist:**

#### Decisions
- [ ] Created ADR for important technical decisions
  - File: `docs/ADR/XXX-decision-name.md`
  - What: [Decision summary]

#### Architecture
- [ ] Updated or created architecture documentation
  - File: `docs/architecture/YYY.md`
  - What: [Architecture changes]

#### Patterns
- [ ] Documented reusable code patterns
  - File: `docs/architecture/ZZZ.md`
  - What: [Patterns added]

#### API Changes
- [ ] Updated API documentation
  - File: `docs/api/endpoints.md`
  - What: [API changes]

#### Product Status
- [ ] Updated feature status in PRD/features
  - File: `docs/product/features/AAA.md`
  - What: [Status update]

#### Changelog
- [ ] Updated CHANGELOG.md
  - Version: [X.Y.Z]
  - Entry: [Changelog entry]

### 3. Verify Extraction Quality

**Ask yourself:**

- ❓ If this session is deleted, will future developers understand:
  - Why we made this decision? (→ Should be in ADR)
  - How to implement similar features? (→ Should be in architecture/)
  - What trade-offs were considered? (→ Should be in ADR)

- ❓ Is there any unique insight in this session not captured elsewhere?
  - If YES → Either extract it or move session to notable/
  - If NO → Safe to delete

## Archive Decision

### Option 1: Delete Immediately ✅

**Choose this if:**
- ✅ All knowledge extracted to permanent docs
- ✅ Standard implementation, no unique insights
- ✅ Unlikely to need session details in future

**Action:**
```bash
./scripts/archive-session.sh
# Select session
# Choose option 1: Delete
```

**Or manually:**
```bash
git rm docs/sessions/current/XX-feature.md
git commit -m "chore: remove session after knowledge extraction

Session: XX-feature
Knowledge preserved in:
- ADR-XXX: [Decision]
- architecture/YYY.md: [Implementation]"
```

### Option 2: Move to Notable 🌟

**Choose this if:**
- 🌟 Major architectural change
- 🌟 Unique insights difficult to capture in ADR
- 🌟 Complex decision-making process worth preserving
- 🌟 Future similar work will benefit from full context

**⚠️ Rare:** < 5% of sessions should be notable

**Action:**
```bash
./scripts/archive-session.sh
# Select session
# Choose option 3: Move to notable
# Provide reason
```

**Or manually:**
```bash
git mv docs/sessions/current/15-feature.md \
       docs/sessions/notable/2025-11-15-feature.md

git commit -m "docs: preserve session in notable/

Reason: [Why this is notable]"
```

### Option 3: Need More Extraction ⏸️

**If extraction is incomplete:**
1. Go back and extract missing knowledge
2. Update extraction checklist
3. Return to this workflow

## Post-Archive

### Verify
- [ ] Session removed from `docs/sessions/current/`
- [ ] Changes committed to git
- [ ] Referenced permanent docs exist and are complete

### If You Made a Mistake

**Recover deleted session:**
```bash
# Find the commit
git log --all --full-history -- "docs/sessions/current/XX-feature.md"

# Restore from specific commit
git show <commit-hash>:docs/sessions/current/XX-feature.md > recovered-session.md
```

---

## Examples

### Example 1: Standard Feature (Delete)

**Session:** `15-offline-sync.md`

**Extraction:**
- ✅ Created ADR-006: Offline sync queue decision
- ✅ Created architecture/offline-sync.md
- ✅ Updated api/endpoints.md (idempotency)
- ✅ Updated CHANGELOG.md

**Decision:** Delete immediately

**Commit:**
```
chore: remove session after knowledge extraction

Session: 15-offline-sync.md
Knowledge preserved in:
- ADR-006: Why sync queue over CRDT
- architecture/offline-sync.md: Implementation guide
- api/endpoints.md: Idempotency requirements
```

### Example 2: Major Refactor (Notable)

**Session:** `20-state-management-refactor.md`

**Why notable:**
- Complete state management system overhaul
- Migration path from old to new system
- Complex trade-offs and experimentation process
- Future refactors will benefit from full context

**Decision:** Move to notable/

**Commit:**
```
docs: preserve session in notable/

Session: 20-state-management-refactor.md
Reason: Major architectural change with complex migration path

This session documents the complete state management refactor,
including migration strategy, trade-offs, and lessons learned.
Valuable reference for future architectural changes.
```

---

## Automation

**Use the script:**
```bash
./scripts/archive-session.sh
```

**Features:**
- Lists current sessions
- Checks for extraction checklist
- Guided workflow
- Auto-generates commit messages
- Validates before deleting
