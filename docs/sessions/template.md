# Session: [Feature Name]

**Date**: YYYY-MM-DD
**Status**: 🔄 In Progress | ✅ Completed | ⏸️ Paused | ❌ Cancelled
**Duration**: [Estimated/Actual] hours
**Contributors**: @username, Claude AI

---

## 📋 Overview

### Goal
[One sentence: What are we trying to achieve?]

### Related Documents
- **PRD**: [Link to docs/product/PRD.md or features/]
- **Feature Spec**: [Link if exists]
- **Related Sessions**: [Links to related sessions]

### Commits
- `commit message` (hash) - [Will be filled during development]

---

## 🎯 Context

### Problem
[What problem are we solving? What pain point does this address?]

### User Story
> As a [user type], I want to [action] so that [benefit].

### Current State
[How does the system work today? What exists? What doesn't?]

**Gap**: [What's missing that we need to add?]

---

## 💡 Planning

### Approach Analysis

#### Option A: [Name] [✅ CHOSEN | ❌ REJECTED]
[Brief description or code sketch]

**Pros**:
- [Advantage 1]
- [Advantage 2]

**Cons**:
- [Disadvantage 1]
- [Disadvantage 2]

#### Option B: [Name] [✅ CHOSEN | ❌ REJECTED]
[Brief description]

**Pros**:
- [Advantage 1]

**Cons**:
- [Disadvantage 1]

**Decision Rationale**: [Why we chose what we chose]

### Design Decisions

#### D1: [Decision Title]
- **Options**: A, B, C
- **Chosen**: B
- **Reason**: [Why]
- **Trade-offs**: [What we gave up]
- **Will document in**: ADR-XXX (to be created)

#### D2: [Another Decision]
- **Options**: ...
- **Chosen**: ...
- **Reason**: ...

---

## ✅ Implementation Checklist

### Phase 1: [Phase Name] [✅ Completed | 🔄 In Progress | ⏳ Pending]
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Phase 2: [Phase Name] [✅ | 🔄 | ⏳]
- [ ] Task 4
- [ ] Task 5

### Phase 3: [Phase Name] [✅ | 🔄 | ⏳]
- [ ] Task 6
- [ ] Task 7

### Phase 4: Testing [✅ | 🔄 | ⏳]
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Manual testing

---

## 🚧 Blockers & Solutions

### Blocker 1: [Title] [✅ RESOLVED | 🔄 IN PROGRESS | ⏸️ BLOCKED]
- **Issue**: [What's blocking progress]
- **Impact**: [How it affects the work]
- **Solution**: [How it was/will be resolved]
- **Resolved**: [Date/Time if resolved]

### Blocker 2: [Title]
- **Issue**: ...
- **Solution**: ...

---

## 📊 Outcome

### What Was Built
[List of deliverables - fill after completion]

### Files Created/Modified
```
lib/
├── path/to/file.dart (new|modified)
├── another/file.dart (modified)

test/
├── test_file.dart (new)
```

### Metrics
- **Code Coverage**: XX%
- **Lines Added**: ~XXX
- **Lines Modified**: ~XXX
- **Test Files**: X new, Y modified

---

## 🎓 Lessons Learned

### 1. [Lesson Title]
**Learning**: [What did we discover?]

**Solution/Pattern**: [How we addressed it]

**Documented in**: [Link to pattern/guide where this is captured]

### 2. [Another Lesson]
**Learning**: ...

**Future Application**: ...

---

## 📚 Knowledge Extraction

> ⚠️ **IMPORTANT**: Complete this section before archiving/deleting the session

### Extraction Checklist

#### Decisions
- [ ] Created ADR for important technical decisions
  - **File**: `docs/ADR/XXX-decision-name.md`
  - **What**: [Brief summary of decision documented]

#### Architecture
- [ ] Updated or created architecture documentation
  - **File**: `docs/architecture/YYY.md`
  - **What**: [Architecture changes documented]

#### Patterns
- [ ] Documented reusable code patterns
  - **File**: `docs/architecture/ZZZ-patterns.md`
  - **What**: [Patterns added]

#### API Changes
- [ ] Updated API documentation (if applicable)
  - **File**: `docs/api/endpoints.md`
  - **What**: [API changes]

#### Product Status
- [ ] Updated feature status in PRD/features
  - **File**: `docs/product/features/AAA.md`
  - **What**: [Status update]

#### Changelog
- [ ] Updated CHANGELOG.md
  - **Version**: [X.Y.Z]
  - **Entry**: [Changelog entry]

#### Tests
- [ ] Updated testing guide with new patterns (if applicable)
  - **File**: `docs/guides/testing-guide.md`
  - **What**: [Testing patterns added]

### Extraction Quality Check

**Ask yourself before deleting:**

- ❓ If this session is deleted, will future developers understand:
  - **Why** we made this decision? → Should be in ADR
  - **How** to implement similar features? → Should be in architecture/
  - **What** trade-offs were considered? → Should be in ADR

- ❓ Is there any unique insight in this session not captured in permanent docs?
  - If YES → Extract it first
  - If NO → Safe to delete

### Archive Decision

Choose one:

- [ ] **Delete immediately** - All knowledge extracted, standard implementation
- [ ] **Move to notable/** - Major architectural significance (< 5% of sessions)
  - **Reason**: [Why this is notable]

---

## 🔮 Future Improvements

### Not Implemented (Intentional)
- ⏳ [What we decided not to do yet and why]
- ⏳ [Another feature postponed]

### Potential Enhancements
- 📌 [Ideas for future iteration]
- 📌 [Nice-to-have features]

### Technical Debt
- 🔧 [Known issues we're accepting for now]
- 🔧 [Workarounds that should be fixed later]

---

## 🔗 References

### Related Work
- [Link to similar implementations]
- [Link to related sessions]

### External Resources
- [Articles, documentation, packages used]
- [Stack Overflow threads, blog posts]

### Team Discussions
- [Links to Slack/Discord conversations]
- [Meeting notes]

---

**Session Completed**: YYYY-MM-DD HH:MM
**Next Session**: [Link to related next session if planned]
**Archive using**: `./scripts/archive-session.sh`
