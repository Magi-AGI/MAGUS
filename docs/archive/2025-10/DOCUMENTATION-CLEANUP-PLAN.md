# Documentation Cleanup Plan

**Date**: 2025-10-09
**Status**: Proposed
**Goal**: Consolidate 28 markdown files into organized, non-redundant documentation

---

## Current State

**Root directory has 28 markdown files** - many redundant or superseded

### Categories:

**Core Documentation (KEEP in root)**:
- ✅ README.md - Main project documentation
- ✅ CLAUDE.md - Claude Code context
- ✅ BACH-MODULATORS-FRAMEWORK.md - Active framework documentation
- ✅ TEST_SUMMARY.md - Current test status

**Superseded Status Documents (ARCHIVE)**:
- SESSION-SUMMARY.md → Superseded by SESSION-SUMMARY-2025-10-08-P3/P4
- M2-M3-COMPLETION-REPORT.md → Superseded by current status
- VERIFICATION_STATUS.md → Old status tracking
- DELIVERABLES-REVIEW.md → Old deliverables tracking
- DELIVERABLES-FINAL-STATUS.md → Old deliverables tracking
- TEST-EXECUTION-RESULTS.md → Old test results

**Codex Review Documents (ARCHIVE - keep most recent only)**:
- CODEX-REVIEW-COMPLETE-FINAL.md → ✅ KEEP (most comprehensive)
- CODEX-FEEDBACK-FIXES-2025-10-09.md → ✅ KEEP (most recent fixes)
- CODEX-REVIEW-COMPLETE.md → Archive (superseded by FINAL)
- CODEX-REVIEW-IMPLEMENTATION-STATUS.md → Archive (superseded)
- CODEX-REVIEW-RESPONSE-2025-10-08.md → Archive (superseded)
- CODEX-ACTION-ITEMS-STATUS.md → Archive (superseded)
- CODEX-FIXES-STATUS.md → Archive (superseded)
- CLAUDE_REVIEW_2025-10-08.md → Archive (original review document)
- CLAUDE_REVIEW_NOTES.md → Archive (old notes)

**Anna Feedback Documents (ARCHIVE - keep most recent only)**:
- ANNA-IMPLEMENTATION-COMPLETE.md → ✅ KEEP (most comprehensive)
- ANNA-FEEDBACK-ASSESSMENT.md → Archive (superseded)

**Session Documents (ARCHIVE)**:
- SESSION-SUMMARY-2025-10-08-P3.md → Archive (historical)
- SESSION-SUMMARY-2025-10-08-P4.md → Archive (historical)
- SESSION-SUMMARY.md → Archive (superseded)

**Reference/Notes (ARCHIVE or REMOVE)**:
- CLAUDE_ANNA_NOTES.md → Archive (old notes)
- CLAUDE_REFERENCE.md → Archive (old reference)
- HYPERON-LIMITATIONS-RESOLVED.md → Archive (historical context)
- MAGUS-Arousal-Modulator-Specification.md → Remove (superseded by BACH-MODULATORS-FRAMEWORK.md)
- Village_of_Grit_Testing_Specs.md → Archive (old test specs)
- Lake's Notes for future incorporation.md → Archive (reference notes)

---

## Proposed Structure

```
metta-magus/
├── README.md                              # Main documentation
├── CLAUDE.md                              # Claude Code context
├── BACH-MODULATORS-FRAMEWORK.md           # Modulator framework
├── TEST_SUMMARY.md                        # Current test status
├── CODEX-REVIEW-COMPLETE-FINAL.md         # Final Codex review summary
├── CODEX-FEEDBACK-FIXES-2025-10-09.md     # Latest fixes
├── ANNA-IMPLEMENTATION-COMPLETE.md        # Anna's implementation summary
│
├── docs/
│   ├── archive/
│   │   ├── README.md                      # Archive index
│   │   ├── codex-review/                  # All Codex review iterations
│   │   ├── anna-feedback/                 # Anna feedback iterations
│   │   ├── session-summaries/             # Session-by-session progress
│   │   ├── deliverables/                  # Old deliverable tracking
│   │   └── historical/                    # Historical context docs
│   │
│   └── current/
│       └── (future active documentation)
```

---

## Files to Archive

### docs/archive/codex-review/
- CODEX-REVIEW-COMPLETE.md
- CODEX-REVIEW-IMPLEMENTATION-STATUS.md
- CODEX-REVIEW-RESPONSE-2025-10-08.md
- CODEX-ACTION-ITEMS-STATUS.md
- CODEX-FIXES-STATUS.md
- CLAUDE_REVIEW_2025-10-08.md
- CLAUDE_REVIEW_NOTES.md

### docs/archive/anna-feedback/
- ANNA-FEEDBACK-ASSESSMENT.md

### docs/archive/session-summaries/
- SESSION-SUMMARY.md
- SESSION-SUMMARY-2025-10-08-P3.md
- SESSION-SUMMARY-2025-10-08-P4.md

### docs/archive/deliverables/
- DELIVERABLES-REVIEW.md
- DELIVERABLES-FINAL-STATUS.md
- TEST-EXECUTION-RESULTS.md
- VERIFICATION_STATUS.md
- M2-M3-COMPLETION-REPORT.md

### docs/archive/historical/
- CLAUDE_ANNA_NOTES.md
- CLAUDE_REFERENCE.md
- HYPERON-LIMITATIONS-RESOLVED.md
- Village_of_Grit_Testing_Specs.md
- Lake's Notes for future incorporation.md

---

## Files to Remove (Superseded)

- MAGUS-Arousal-Modulator-Specification.md (superseded by BACH-MODULATORS-FRAMEWORK.md)

---

## Archive Index to Create

Create `docs/archive/README.md`:

```markdown
# Archived Documentation

This directory contains historical documentation for reference purposes.

## Organization

- **codex-review/**: Iterations of Codex code review feedback and responses
- **anna-feedback/**: Iterations of Anna's architectural feedback
- **session-summaries/**: Session-by-session development progress
- **deliverables/**: Old deliverable tracking documents
- **historical/**: Historical context, limitations, and reference notes

## Current Documentation

For current project documentation, see the root directory:
- README.md - Main project overview
- BACH-MODULATORS-FRAMEWORK.md - Modulator system
- TEST_SUMMARY.md - Test results
- CODEX-REVIEW-COMPLETE-FINAL.md - Latest code review summary
- CODEX-FEEDBACK-FIXES-2025-10-09.md - Most recent fixes
- ANNA-IMPLEMENTATION-COMPLETE.md - Architecture implementation summary
```

---

## Implementation Steps

1. ✅ Create archive directory structure
2. Move files to appropriate archive locations
3. Create archive README.md
4. Remove superseded files
5. Update root README.md to reference archive if needed
6. Commit with message: "Clean up documentation - archive historical docs"

---

## Benefits

- **Root directory**: 7 files (down from 28)
- **Clear current state**: Only active/relevant docs in root
- **Preserved history**: All historical context archived, not lost
- **Better organization**: Easy to find both current and historical information
- **Reduced confusion**: No more wondering which status doc is current

---

**Next Action**: Execute cleanup plan
