# MAGUS Source Code

This directory should contain copies of the M2, M3, and M4 source code for reproducibility.

## Required Structure

```
source/
├── Milestone_2/
│   └── goal-fitness-metrics/
│       ├── measurability/
│       │   ├── measurability.metta
│       │   └── test_measurability.py
│       └── correlation/
│           ├── correlation.metta
│           └── test_correlations.py
├── Milestone_3/
│   └── core/
│       ├── types.metta
│       ├── metagoals.metta
│       ├── antigoals.metta
│       ├── antigoal-costs.metta
│       ├── scoring-v2.metta
│       └── planner-bt.metta
└── Milestone_4/
    ├── ethical/
    │   ├── scenarios.metta
    │   └── scenario-runner.metta
    ├── evaluation/
    │   ├── benchmarks.metta
    │   └── ablations.metta
    └── tests/
        └── test_m4_pipeline.py
```

## To Package Source Code

From the repository root:

```bash
# Copy M2 source
cp -r ../../Milestone_2/goal-fitness-metrics ./Milestone_2/

# Copy M3 source
cp -r ../../Milestone_3/core ./Milestone_3/

# Copy M4 source
cp -r ../../Milestone_4/ethical ./Milestone_4/
cp -r ../../Milestone_4/evaluation ./Milestone_4/
cp -r ../../Milestone_4/tests ./Milestone_4/
```

## Verification

After copying, verify all files are present:

```bash
find . -name "*.metta" | wc -l  # Should find ~15-20 MeTTa files
find . -name "test_*.py" | wc -l  # Should find 3 test files
```

## License

All source code is licensed under [LICENSE TO BE DETERMINED].

See individual files for authorship and copyright information.

---

**Note**: This is a template. The actual source code should be copied from the main repository before packaging the reproducibility archive for distribution.
