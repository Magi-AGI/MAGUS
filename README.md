# MAGUS - Modular Adaptive Goal and Utility System

**Experimental MeTTa implementation of goal-driven decision making for AGI systems**

> **Provenance:** This repository was migrated from an internal GitLab source on 2026-04-17. The `main` branch contains the M2/M3/M4 development history (previously on the `LLM_Tutorial` branch upstream). The `legacy-main` branch preserves the original three-commit prototype for historical reference. Licensed GPL-3.0.

## Project Status: ✅ M2/M3/M4 Complete (October 2025)

All milestones implemented and validated:
- **M2**: Goal Fitness Metrics (Measurability, Correlation) - 19/19 tests passing
- **M3**: Metagoals, Anti-goals, Scoring v2, Planner - Fully integrated with M2
- **M4**: Ethical Evaluation Framework - 5/5 pipeline tests passing

**Total: 24/24 Python tests passing (100%)** | **Validated in WSL Ubuntu environment**

## Overview

MAGUS is a modular goal and utility system implementing:
- **Goal Fitness Metrics** - Measurability and correlation tracking for goal evaluation
- **Metagoals** - Strategic value adjustments (coherence, exploration, safety)
- **Anti-goals** - Constraint enforcement with penalties
- **Ethical Framework** - Scenario validation with ethical logging
- **Scoring v2** - Integrated pipeline with modulators and overgoal

Built in MeTTa language (Hyperon 0.2.1) with comprehensive test coverage.

---

## Quick Start

### Prerequisites
- Python 3.8+ with MeTTa/Hyperon installed
- **WSL Ubuntu environment required on Windows** - Hyperon 0.2.1 uses Linux binaries

### Installation
```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install hyperon
```

### Initialization (REQUIRED)

**⚠️ Critical**: All MAGUS code requires grounded Python math functions:

```python
from hyperon import MeTTa
from magus_init import initialize_magus

metta = MeTTa()
initialize_magus(metta)  # Registers sqrt, pow, abs, floor, ceil, sin, cos, log, exp

# Now load MAGUS modules
metta.run("!(import! &self Milestone_3/core/scoring-v2.metta)")
```

**Why**: Geometric mean calculations require `sqrt` and `pow`. Without initialization, math operations fail with "unbound symbol" errors.

### Running Tests

**All tests must run in WSL on Windows**:

```bash
# Quick run
wsl bash run_all_tests_wsl.sh

# Or individually in WSL:
cd /mnt/e/GitLab/the-smithy1/magi/neoterics/metta-magus
source .venv/bin/activate

python Milestone_2/goal-fitness-metrics/measurability/test_measurability.py  # 12 tests
python Milestone_2/goal-fitness-metrics/correlation/test_correlations.py     # 7 tests
python Milestone_4/tests/test_m4_pipeline.py                                  # 5 tests

# Expected: 24/24 tests passing
```

---

## Documentation

### Consolidated Documentation (Start Here)

**Project Overview & Milestones**:
- **[PROJECT-OVERVIEW.md](PROJECT-OVERVIEW.md)** - Comprehensive project overview, architecture, testing
- **[MILESTONE-2-SUMMARY.md](MILESTONE-2-SUMMARY.md)** - Goal Fitness Metrics (Measurability, Correlations)
- **[MILESTONE-3-SUMMARY.md](MILESTONE-3-SUMMARY.md)** - Metagoals, Anti-goals, Modulators, Integration
- **[MILESTONE-4-SUMMARY.md](MILESTONE-4-SUMMARY.md)** - Ethical Scenarios, Reproducibility, Research Paper

**Research Paper**:
- **[Milestone_4/docs/MAGUS-Research-Paper-Draft.md](Milestone_4/docs/MAGUS-Research-Paper-Draft.md)** - Complete research paper draft

**Reproducibility**:
- **[Milestone_4/reproducibility-archive/README.md](Milestone_4/reproducibility-archive/README.md)** - Setup and validation guide

### Knowledge Repository

**Deep Dives** (in magi-knowledge-repo):
- **Core Framework Design Document** - Full architectural details
- **MAGUS Best Practices** - Consolidated best practices & anti-patterns
- **MeTTa Lessons Learned** - Implementation insights

### Historical Documentation

- **[docs/archive/2025-10/README.md](docs/archive/2025-10/README.md)** - Archived documentation (historical context)

---

## Milestones Summary

### Milestone 2: Goal Fitness Metrics ✅

Measurability framework (confidence × clarity) and MIC correlations. See **[MILESTONE-2-SUMMARY.md](MILESTONE-2-SUMMARY.md)** for full details.

**Key Metrics**:
- Energy measurability: 0.72
- Exploration measurability: 0.56
- Energy-Exploration correlation: 0.70

**Status**: 19/19 tests passing

### Milestone 3: Metagoals & Integration ✅

Higher-order objectives, Bach's 6-modulator framework, and M2-M3 integration. See **[MILESTONE-3-SUMMARY.md](MILESTONE-3-SUMMARY.md)** for full details.

**Key Components**:
- Metagoals (coherence, exploration, safety)
- Anti-goals (energy-efficiency)
- Overgoal (0.3 × avg weighted correlation)
- Bach's 6 modulators (PAD + attentional)

**Status**: E2E integration verified, 24/24 Python tests passing

### Milestone 4: Ethical Scenarios & Research ✅

Scenario validation, ablation framework, and reproducibility archive. See **[MILESTONE-4-SUMMARY.md](MILESTONE-4-SUMMARY.md)** for full details.

**Deliverables**:
- Scenario runner with ethical logging
- Ablation framework (6 configurations)
- Integration modules (AIRIS/HERMES patterns)
- Reproducibility archive (24 Python tests)
- Research paper draft

**Status**: 5/5 pipeline tests passing, research paper complete

---

## Architecture

### System Flow

```
M2 Metrics (Measurability, Correlation)
         ↓
M3 Metagoals (Strategic Adjustments)
         ↓
M3 Overgoal (Goal Set Coherence)
         ↓
M3 Modulators (Bach's 6-modulator framework)
         ↓
M3 Anti-goals (Constraints)
         ↓
M3 Scoring v2 (Integrated Pipeline)
         ↓
M4 Ethical Scenarios (Validation)
```

### Core Types

**Goal**: `(goal name priority weight)` - Basic goal structure
**Metagoal**: `(metagoal type)` - Strategic value adjustments
**AntiGoal**: `(anti-goal name severity penalty-fn)` - Constraints
**Candidate**: `(goal-candidate goal)` or `(action-candidate action)`
**DecisionScore**: `(decision-score base meta anti final)` - Score breakdown

### Key Modules

**M2:**
- `Milestone_2/goal-fitness-metrics/measurability/` - Measurability calculations
- `Milestone_2/goal-fitness-metrics/correlation/` - MIC correlation

**M3:**
- `Milestone_3/core/metagoals.metta` - Metagoal system (connected to M2)
- `Milestone_3/core/antigoals.metta` - Anti-goal constraints
- `Milestone_3/core/overgoal.metta` - Overgoal calculation
- `Milestone_3/core/scoring-v2.metta` - Integrated scoring pipeline

**M4:**
- `Milestone_4/scenarios/scenario-runner.metta` - Scenario execution
- `Milestone_4/ablations/ablation-runner.metta` - Ablation framework
- `Milestone_4/integration/` - AIRIS/HERMES integration patterns

---

## Code Quality

**Best Practices Compliance**:
- ✅ No inline lambdas (use named functions)
- ✅ No `let` with `match` (use equality-based dispatch)
- ✅ No atomspace mutation in lambdas
- ✅ Type signatures for all functions
- ✅ Data-driven (M2 metrics connected to M3 metagoals)

**Test Coverage**: 24/24 Python tests (100% pass rate)
- M2 Measurability: 12/12
- M2 Correlation: 7/7
- M4 Pipeline: 5/5

**Performance**: Within 25% regression budget

---

## Known Limitations

- **Hyperon 0.2.1**: Some evaluation issues with complex patterns
  - Workaround: Equality-based dispatch, Python tests
- **M3 estimate-cost**: Placeholder returns 0.0
  - Impact: Low - cost estimation not critical for milestone validation
- **M4 Integration**: AIRIS/HERMES use mock implementations
  - Impact: Low - demonstrates integration patterns

See milestone summaries for detailed limitations and workarounds.

---

## Research Context

This work contributes to AGI motivational architecture by:
- Implementing data-driven goal fitness metrics
- Demonstrating practical metagoal/anti-goal integration
- Validating ethical decision-making through scenario testing
- Exploring MeTTa language for symbolic AGI development

Built on OpenPsi motivational frameworks with modern ethical AI considerations.

---

## Contributors

Anna (primary developer)
Claude Code (AI assistant)

---

**Last Updated**: October 2025
**Status**: Production-ready, all milestones complete
**Next**: Research paper finalization and publication
