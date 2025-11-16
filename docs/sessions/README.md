# Development Sessions

## Purpose

Sessions are **temporary working documents** for tracking development progress.

**Lifecycle**: Create → Complete → Extract Knowledge → Delete

## Philosophy

### Why Sessions?
- 📝 Track development process and decisions
- 🧠 Capture thinking and trade-offs
- 📚 Source material for permanent documentation

### Why Delete After Completion?
- 🎯 Forces thorough knowledge extraction
- 🧹 Keeps documentation clean
- 📖 Single source of truth (ADR + architecture)
- 💾 Git history preserves everything (can recover)

## Structure

```
sessions/
├── README.md           # This file
├── template.md         # Session template
├── current/            # 🔄 Active sessions (delete after completion)
└── notable/            # 🌟 Exceptional cases (<5% of sessions)
```

## Quick Start

### Create New Session
```bash
cp docs/sessions/template.md docs/sessions/current/$(date +%d)-feature-name.md
```

### Archive Completed Session
```bash
./scripts/archive-session.sh
```

Or see detailed workflow: `.claude/templates/archive-session.md`

## Workflow

### 1. Start Session

```bash
# Copy template
cp docs/sessions/template.md docs/sessions/current/15-offline-sync.md

# Edit and fill:
# - Overview (goal, related docs)
# - Context (problem, current state)
# - Planning (approach, decisions)
# - Implementation Checklist
```

### 2. During Development

- ✅ Check off completed tasks
- 📝 Document blockers and solutions
- 💡 Record design decisions
- 🔗 Reference in commits

**Example commit:**
```
feat(sync): implement offline queue

Part of docs/sessions/current/15-offline-sync.md
Phase 2: State Management Integration
```

### 3. Complete Session

Fill remaining sections:
- ✅ Outcome (what was built, metrics)
- 🎓 Lessons Learned
- 📚 Knowledge Extraction checklist

### 4. Extract Knowledge

**Before deleting, extract ALL knowledge to permanent docs:**

#### Must Extract:
- **Decisions** → `docs/ADR/XXX-decision.md`
- **Architecture** → `docs/architecture/YYY.md`
- **Patterns** → `docs/architecture/ZZZ.md`
- **API Changes** → `docs/api/endpoints.md`
- **Product Status** → `docs/product/features/AAA.md`

#### Extraction Quality Check:
Ask yourself: "If I delete this session, will future developers understand?"
- Why we made this decision? → ADR
- How to implement similar features? → architecture/
- What trade-offs were considered? → ADR

### 5. Archive Decision

#### Option A: Delete Immediately (95% of sessions)

**Criteria:**
- ✅ All knowledge extracted
- ✅ Standard implementation
- ✅ No unique insights beyond ADR/architecture

**Method:**
```bash
# Automated (recommended)
./scripts/archive-session.sh

# Manual
git rm docs/sessions/current/15-feature.md
git commit -m "chore: remove session after knowledge extraction

Knowledge preserved in:
- ADR-006: [Decision]
- architecture/offline-sync.md: [Implementation]"
```

#### Option B: Move to Notable (<5% of sessions)

**Criteria (STRICT):**
- 🌟 Major architectural change
- 🌟 Unique insights hard to capture in ADR
- 🌟 Complex decision process worth preserving
- 🌟 Future similar work needs full context

**Method:**
```bash
# Automated (recommended)
./scripts/archive-session.sh

# Manual
git mv docs/sessions/current/15-feature.md \
       docs/sessions/notable/2025-11-15-feature.md
git commit -m "docs: preserve session in notable/

Reason: Major architectural refactor with complex migration strategy"
```

## Archive Automation

### Interactive Script

```bash
./scripts/archive-session.sh
```

**Features:**
- 📋 Lists current sessions
- ✅ Validates extraction checklist
- 🤖 Guided workflow
- 📝 Auto-generates commit messages
- 🛡️ Safety checks before deletion

### Manual Workflow

See detailed guide: `.claude/templates/archive-session.md`

## Guidelines

### When to Create a Session

**DO create for:**
- ✅ New features
- ✅ Significant refactoring
- ✅ Complex bug fixes
- ✅ Architecture changes
- ✅ Third-party integrations

**DON'T create for:**
- ❌ Trivial fixes (typos, one-liners)
- ❌ Documentation-only changes
- ❌ Dependency updates
- ❌ Simple formatting

**Rule of thumb:** If it needs planning or will teach you something, create a session.

### Extraction Quality Standards

**Good extraction:**
```
ADR-006: Offline Sync Queue
- Context: Need offline support
- Options: A) Sync Queue, B) CRDT
- Decision: Sync Queue
- Rationale: Simpler, adequate for our use case
- Trade-offs: Manual conflict resolution vs. CRDT's automatic
- Consequences: Need idempotency keys
```

**Poor extraction:**
```
ADR-006: Offline Sync
- We chose sync queue
```

### Notable Session Examples

**Should be notable:**
- Complete state management refactor (Provider → Riverpod)
- Database migration strategy with data transformation
- Complex authentication flow redesign

**Should NOT be notable:**
- Standard CRUD feature
- Bug fix (even complex)
- Dependency upgrade
- Performance optimization

## Recovery

### Recover Deleted Session

```bash
# Find the commit that deleted the session
git log --all --full-history -- "docs/sessions/current/15-feature.md"

# View the session content
git show <commit-hash>:docs/sessions/current/15-feature.md

# Restore if needed
git show <commit-hash>:docs/sessions/current/15-feature.md > recovered-session.md
```

### Why You Might Need Recovery

1. **Incomplete extraction** - Realized ADR is missing details
2. **Related bug** - Need to understand original context
3. **Similar feature** - Want to reference implementation approach

**Prevention:** Extract knowledge thoroughly the first time!

## Statistics

Track your extraction quality:

```bash
# Count deleted sessions (good!)
git log --all --oneline | grep "remove session" | wc -l

# Count notable sessions (should be low)
ls -1 docs/sessions/notable/ | wc -l

# Ratio should be ~20:1 (95% deleted, 5% notable)
```

## FAQ

### Q: Should I keep sessions for recent completed features?

**A:** No. Extract knowledge immediately and delete. Git history preserves everything.

### Q: What if I'm unsure if extraction is complete?

**A:** Run through the extraction checklist. If you're hesitant to delete, the extraction is incomplete.

### Q: Can I batch archive multiple sessions?

**A:** Yes, but extract knowledge for each one individually to maintain quality.

### Q: What if the session has unique implementation details?

**A:** Add them to `architecture/*.md` as code examples and patterns.

## Templates & Tools

- **Session Template**: `docs/sessions/template.md`
- **Archive Workflow**: `.claude/templates/archive-session.md`
- **Archive Script**: `scripts/archive-session.sh`

---

**Remember:** Sessions are working documents, not permanent documentation. Be ruthless about extraction and deletion. Your future self will thank you for clean, well-organized permanent docs.
