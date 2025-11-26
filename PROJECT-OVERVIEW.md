# MAGUS Project Overview

**Modular Autonomous Goal-based Utility System**
A neurosymbolic AI framework combining MeTTa (Meta Type Talk) with measurable goal fitness metrics, metagoals, and ethical constraints.

---

## Purpose

MAGUS demonstrates how symbolic reasoning (MeTTa) can integrate with quantitative goal evaluation to create explainable, ethically-constrained AI decision-making. The system evaluates goals through:

- **Measurability**: Confidence and clarity of goal state measurement
- **Correlations**: Relationships between goals (synergies/conflicts)
- **Metagoals**: Higher-order objectives (coherence, exploration, safety)
- **Modulators**: Emotional/cognitive states (Bach's 6-modulator framework)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     MAGUS Framework                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Milestone 2: Goal Fitness Metrics                           │
│  ├─ Measurability (confidence × clarity)                     │
│  └─ MIC Correlations (weighted by geometric mean)            │
│                                                               │
│  Milestone 3: Metagoals & Integration                        │
│  ├─ Metagoals (coherence, exploration, safety)              │
│  ├─ Anti-goals (energy-efficiency)                           │
│  ├─ Overgoal (0.3 × avg weighted correlation)               │
│  └─ Bach's 6 Modulators (PAD + attentional)                 │
│                                                               │
│  Milestone 4: Ethical Scenarios & Validation                 │
│  ├─ Scenario runner with ethical logging                     │
│  ├─ Ablation framework                                        │
│  └─ Reproducibility archive                                   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Major Deliverables

### M2: Goal Fitness Metrics
- Measurability calculations for goal observability
- MIC correlation framework with geometric mean weighting
- 19 validation tests (12 measurability + 7 correlation)

### M3: Metagoals & Integration
- Metagoal/anti-goal/overgoal system
- Bach's 6-modulator framework implementation
- Integration with M2 metrics
- End-to-end scoring pipeline

### M4: Ethical Scenarios & Research
- Scenario runner with ethical constraint logging
- Ablation framework for component testing
- Research paper draft
- Reproducibility archive with 24 Python tests

---

## Testing & Validation

**Total**: 24 Python tests (100% pass rate)
- 12 M2 measurability tests
- 7 M2 correlation tests
- 5 M4 pipeline tests

**Platform Requirements**:
- WSL Ubuntu (required for Hyperon 0.2.1 on Windows)
- Python 3.8+
- Hyperon MeTTa interpreter

**Running Tests**:
```bash
cd Milestone_4/reproducibility-archive/tests
./run_all_tests_wsl.sh
```

Expected: `24/24 Python tests PASSED`

---

## Key Implementation Details

### Geometric Mean Weighting
Weighted correlations use geometric mean rather than arithmetic mean:
```python
geometric_mean = sqrt(measurability1 × measurability2)
weighted_correlation = base_correlation × geometric_mean
```

**Rationale**: Better represents mutual synergy between goals.

### Bach's 6 Modulators
**PAD (Emotional)**:
1. Pleasure: `0.9 + (0.2 × pleasure)` → [0.9-1.1]
2. Arousal: `0.8 + (0.4 × arousal)` → [0.8-1.2]
3. Dominance: `0.85 + (0.3 × dominance)` → [0.85-1.15]

**Attentional (Cognitive)**:
4. Focus: `0.7 + (0.6 × focus)` → [0.7-1.3]
5. Resolution: `0.75 + (0.5 × resolution)` → [0.75-1.25]
6. Exteroception: `0.8 + (0.4 × exteroception)` → [0.8-1.2]

### Overgoal Integration
```python
overgoal_score = average(weighted_correlations)
overgoal_bonus = 0.3 × overgoal_score
```

Integrated into M3 scoring pipeline with M2 data.

### Grounded Python Functions
All MeTTa math operations require initialization:
```python
from magus_init import initialize_magus
metta = initialize_magus()
```

Registers: `sqrt`, `pow`, `abs`, `floor`, `ceil`, `sin`, `cos`, `log`, `exp`

---

## Known Limitations

### M3 Metagoals
- `estimate-cost` uses placeholder (returns 0.0)
- **Impact**: Low - cost estimation not critical for milestone validation
- **Status**: Documented, acceptable for milestone completion

### M4 Scenario Runner
- Penalty extraction TODOs (three locations)
- Timestamp placeholder
- JSON export stub
- **Impact**: Low - ethical logging functional, export is enhancement
- **Status**: Documented in code comments

### M4 Integration Mocks
- AIRIS/HERMES integration uses mock floor implementation
- **Impact**: Low - demonstrates integration pattern
- **Status**: Real integration deferred to future work

### Hyperon Limitations
- Some complex patterns return symbolic forms (not evaluated)
- **Workaround**: Validation via Python tests
- **Status**: Documented in research paper §5.3.3

**Full details**: See `KNOWN-LIMITATIONS.md`

---

## Documentation Structure

**Live Documentation** (4 docs):
- `PROJECT-OVERVIEW.md` (this file)
- `MILESTONE-2-SUMMARY.md` - Goal fitness metrics
- `MILESTONE-3-SUMMARY.md` - Metagoals & integration
- `MILESTONE-4-SUMMARY.md` - Ethical scenarios & research

**Required Documentation**:
- `Milestone_4/docs/MAGUS-Research-Paper-Draft.md` - Research paper
- `Milestone_4/reproducibility-archive/README.md` - Reproducibility guide

**Root Documentation**:
- `README.md` - Quick start guide
- `TEST_SUMMARY.md` - Test breakdown
- `BACH-MODULATORS-FRAMEWORK.md` - Modulator details
- `KNOWN-LIMITATIONS.md` - TODOs and limitations

**Archived Documentation**: See `docs/archive/` for historical context

---

## Knowledge Repository

Detailed design documentation, lessons learned, and cross-project context:
- **Location**: `magi-knowledge-repo/docs/neoterics/MAGUS/`
- **Key Docs**:
  - Core Framework Design Document
  - MAGUS Best Practices
  - MeTTa Lessons Learned

---

## Quick Start

### 1. Setup Environment
```bash
# WSL Ubuntu required on Windows
cd Milestone_4/reproducibility-archive/environment
./setup.sh
source .venv/bin/activate
```

### 2. Run Tests
```bash
cd ../tests
./run_all_tests_wsl.sh
```

### 3. Run Example Scenario
```python
from hyperon import MeTTa
from magus_init import initialize_magus

metta = initialize_magus()
metta.run(open('Milestone_4/scenarios/example.metta').read())
```

---

## Research Paper

**Draft**: `Milestone_4/docs/MAGUS-Research-Paper-Draft.md`

**Key Contributions**:
1. Measurability framework for goal fitness
2. Geometric mean weighting for correlations
3. Metagoal/anti-goal/overgoal system
4. Bach's 6-modulator integration
5. Ethical scenario validation framework
6. Neurosymbolic integration patterns

---

## Project Status

**Current**: Milestone 4 complete, ready for merge
**Branch**: `LLM_Tutorial`
**Tests**: 24/24 passing (100%)
**Documentation**: Consolidated and consistent

**Next Steps**: Merge to main, publish research paper

---

**Version**: 1.0
**Last Updated**: October 2025
**Repository**: https://gitlab.com/the-smithy1/magi/Neoterics/metta-magus
