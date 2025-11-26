# Milestone 2 – Goal Fitness Metrics

This milestone implements the measurability and correlation foundations for MAGUS.
The code lives in `Milestone_2/goal-fitness-metrics/` and is exercised by the
Python test suites.

**Highlights**

- Measurability: confidence × clarity calculations for all goals
- Correlation: Maximum Information Coefficient with 3-bin discretisation
- Weighted metrics feed directly into the overgoal bonus

**How to Reproduce**

```bash
# From repo root (WSL)
source .venv/bin/activate
python Milestone_2/goal-fitness-metrics/measurability/test_measurability.py
python Milestone_2/goal-fitness-metrics/correlation/test_correlations.py
```

Detailed design notes, historical reports, and test logs are archived in the
knowledge base:
- `magi-knowledge-repo/docs/neoterics/MAGUS/milestones/M2/`
