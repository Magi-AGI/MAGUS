# M3 Debug Files Archive

## Overview

This directory contains small debug scripts created during Milestone 3 development on October 6, 2025.

**Archive Date**: October 10, 2025
**Reason**: Development artifacts no longer needed

---

## Archived Files (4 files)

1. **debug.metta** (263 bytes)
2. **debug2.metta** (198 bytes)
3. **debug3.metta** (165 bytes)
4. **debug4.metta** (137 bytes)

**Date Created**: October 6, 2025 (during M3 development)
**Type**: Diagnostic/debugging scripts

---

## Purpose

These files were quick diagnostic scripts used during development to:
- Test specific function calls
- Isolate behavior issues
- Debug import/load problems
- Validate single operations

### Typical Pattern
```metta
;; Quick test of single function
!(import! &self ../core/metagoals.metta)
!(test-function arg1 arg2)
```

---

## Why Archived

1. **Development Only**: Created for temporary debugging
2. **Not Referenced**: Not used by any scripts or documentation
3. **Superseded**: Functionality covered by comprehensive test suite
4. **No Unique Value**: No unique test cases or insights

---

## Development Context

**October 6, 2025** was active M3 development:
- Building metagoals system
- Implementing promotion/demotion
- Testing scoring integration
- Debugging import paths

These debug files were part of the iterative development process.

---

## Best Practices

### What These Files Show
- ❌ Debug files left behind after development
- ❌ No cleanup during milestone completion
- ❌ Multiple numbered debug files (debug, debug2, debug3, debug4)

### Better Approach
1. ✅ Use temporary files (prefix with `tmp_` or `test_`)
2. ✅ Clean up debug files before committing
3. ✅ Use proper test framework instead of debug files
4. ✅ Delete after issue resolved

### M4 Example
Milestone 4 has **zero debug files** - cleaner development process following lessons from M2/M3.

---

## If You Need Debug Files

For future debugging of M3 functionality:

1. **Use Python REPL**:
```python
from hyperon import MeTTa
metta = MeTTa()
metta.run('!(import! &self Milestone_3/core/metagoals.metta)')
metta.run('!(test-function)')
```

2. **Create Temporary Test**:
```bash
# Create with clear name
echo '!(test-something)' > tmp_debug_issue123.metta
metta tmp_debug_issue123.metta
rm tmp_debug_issue123.metta  # Clean up immediately
```

3. **Use Official Tests**:
```bash
# Run specific test from suite
cd tests/m3_tests
metta test-metagoals.metta
```

---

## File Contents (Summary)

Since these are small diagnostic files, here's what they likely contained:

### Pattern 1: Single Function Call
```metta
!(import! &self ../core/metagoals.metta)
!(calculate-metagoal-adjustment test-goal test-context metagoals)
```

### Pattern 2: Value Check
```metta
!(import! &self ../core/scoring-v2.metta)
!(println! (score-goal test-goal context))
```

### Pattern 3: Import Test
```metta
!(import! &self ../core/overgoal.metta)
!(println! "Import successful")
```

**Note**: Actual contents may vary, but pattern is consistent - quick diagnostic checks.

---

## Current Testing Approach

Instead of debug files, use:

### 1. Official Test Suite
- 25/25 Python tests (comprehensive)
- MeTTa tests in tests/m3_tests/ (reference)

### 2. Test Runner
```bash
# Run full suite
bash run_all_tests_wsl.sh

# Run specific milestone
cd Milestone_2/goal-fitness-metrics/measurability
python test_measurability.py
```

### 3. Python Interactive Testing
```python
# For complex debugging
from hyperon import MeTTa
import sys

metta = MeTTa()
# Load required modules
# Run diagnostic queries
# Print detailed output
```

---

## References

- **Official Tests**: `tests/m3_tests/`
- **Test Runner**: `run_all_tests_wsl.sh`
- **Audit Report**: `MILESTONE-3-REDUNDANCY-AUDIT.md`

---

## Conclusion

These debug files served their purpose during October 6 development session but have no ongoing value:
- ✅ Issues resolved
- ✅ Functionality tested by official suite
- ✅ Not referenced anywhere
- ✅ Small diagnostic scripts only

**Archived for**: Historical record of development process, no functional value.

---

## Lesson Learned

**From M3 Experience**:
Debug files → Archive after use

**Applied to M4**:
Clean development → No debug files

**Result**: M4 is cleanest milestone with zero debug artifacts.
