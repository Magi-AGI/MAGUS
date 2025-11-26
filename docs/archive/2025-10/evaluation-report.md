# MAGUS M4 - Ethical Evaluation Report

**Generated:** Automatically from metrics aggregation

## Summary Statistics

| Configuration | Scenarios | Goal Sat. | Hard Viol. | Soft Viol. | Latency (ms) |
|--------------|-----------|-----------|-----------|------------|-------------|
| full-system | 3 | 0.800 | 0 | 15 | 15.00 |
| no-metagoals | 3 | 0.600 | 0 | 15 | 15.00 |
| no-antigoals | 3 | 0.600 | 6 | 3 | 15.00 |
| baseline-m2 | 3 | 0.600 | 0 | 15 | 15.00 |

## Ablation Analysis

Changes relative to full-system baseline:

| Configuration | Metric | Baseline | Ablated | Delta | % Change |
|--------------|--------|----------|---------|-------|----------|
| no-metagoals | goal_satisfaction_mean | 0.800 | 0.600 | -0.200 | -25.0% |
| no-antigoals | goal_satisfaction_mean | 0.800 | 0.600 | -0.200 | -25.0% |
| no-antigoals | hard_violations_total | 0.000 | 6.000 | +6.000 | +0.0% |
| no-antigoals | soft_violations_total | 15.000 | 3.000 | -12.000 | -80.0% |
| baseline-m2 | goal_satisfaction_mean | 0.800 | 0.600 | -0.200 | -25.0% |

## Key Findings

### Hard Violations
- **no-antigoals**: 6 hard violations detected

### Metagoal Impact
- Metagoals improve goal satisfaction by +0.200

### Anti-goal Impact
- Disabling anti-goals increases hard violations by +6
