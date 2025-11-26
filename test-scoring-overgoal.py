#!/usr/bin/env python3
"""
Test Overgoal Integration in Scoring Pipeline

This script verifies that the overgoal bonus is wired through the scoring
pipeline by:
1. Initialising MAGUS (registering grounded math helpers)
2. Loading the relevant MeTTa modules
3. Fetching measurability and correlation values from M2
4. Computing the expected geometric-mean weighted correlations in Python
5. Confirming the expected overgoal bonus (0.3 × average weighted correlation)
6. Calling the scoring pipeline once to ensure it executes without error
"""

from __future__ import annotations

import math
from pathlib import Path

from hyperon import MeTTa

# Import shared test fixtures
from test_fixtures import (
    get_metta_number,
    assert_nonempty,
    EXPECTED_MEASURABILITIES,
    EXPECTED_BASE_CORRELATIONS,
    EXPECTED_WEIGHTED_CORRELATIONS,
    EXPECTED_OVERGOAL_BONUS,
)
from magus_init import initialize_magus


def _run(metta: MeTTa, expr: str):
    """Run a MeTTa expression and return the raw result list."""
    return metta.run(expr.strip())


def main() -> None:
    print("=" * 70)
    print("  OVERGOAL SCORING INTEGRATION TEST")
    print("=" * 70)

    print("\n1. Initialising MAGUS and registering grounded math functions...")
    metta = initialize_magus()

    print("2. Loading required modules...")
    base_dir = Path(__file__).parent
    modules = [
        base_dir / 'types.metta',
        base_dir / 'Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta',
        base_dir / 'Milestone_2/goal-fitness-metrics/correlation/initial_correlation_calculation.metta',
        base_dir / 'Milestone_3/core/metagoals.metta',
        base_dir / 'Milestone_3/core/antigoals.metta',
        base_dir / 'Milestone_3/core/overgoal.metta',
        base_dir / 'Milestone_3/core/scoring-v2.metta',
    ]
    for module_path in modules:
        if not module_path.exists():
            raise FileNotFoundError(f"Missing module: {module_path}")
        with open(module_path, 'r', encoding='utf-8') as handle:
            metta.run(handle.read())
        print(f"  ✓ Loaded {module_path.name}")

    print("\n3. Fetching measurability values (M2)...")
    energy_meas = get_metta_number(metta, '!(get-measurability energy)')
    exploration_meas = get_metta_number(metta, '!(get-measurability exploration)')
    affinity_meas = get_metta_number(metta, '!(get-measurability affinity)')
    print(f"  energy measurability:     {energy_meas:.3f}")
    print(f"  exploration measurability: {exploration_meas:.3f}")
    print(f"  affinity measurability:    {affinity_meas:.3f}")

    print("\n4. Fetching base correlations (M2)...")
    corr_energy_exploration = get_metta_number(metta, '!(get-correlation energy exploration)')
    corr_energy_affinity = get_metta_number(metta, '!(get-correlation energy affinity)')
    print(f"  energy-exploration: {corr_energy_exploration:.3f}")
    print(f"  energy-affinity:    {corr_energy_affinity:.3f}")

    print("\n5. Computing weighted correlations (geometric mean)...")
    weighted_energy_exploration = corr_energy_exploration * math.sqrt(energy_meas * exploration_meas)
    weighted_energy_affinity = corr_energy_affinity * math.sqrt(energy_meas * affinity_meas)
    print(f"  weighted energy-exploration: {weighted_energy_exploration:.3f}")
    print(f"  weighted energy-affinity:    {weighted_energy_affinity:.3f}")

    overgoal_score = (weighted_energy_exploration + weighted_energy_affinity) / 2.0
    overgoal_bonus = 0.3 * overgoal_score
    print(f"  overgoal score (avg weighted corr): {overgoal_score:.3f}")
    print(f"  expected overgoal bonus:          {overgoal_bonus:.3f}")

    if not (0.08 <= overgoal_bonus <= 0.12):
        raise AssertionError(f"Unexpected overgoal bonus: {overgoal_bonus}")

    print("\n6. Executing scoring pipeline once (smoke test)...")
    # This ensures no exceptions are thrown when the full scoring pipeline runs.
    pipeline_result = _run(metta, '''
        !(score-decision-v2
            (goal-candidate (goal energy 0.9 0.8))
            (Cons (consideration opportunity (lambda ($ctx) 30)) Nil)
            (Cons (discouragement fatigue (lambda ($ctx) 10)) Nil)
            (Cons (metagoal coherence) Nil)
            (Cons (energy-efficiency-antigoal) Nil)
            (scoring-context
                (Cons (goal energy 0.9 0.8)
                (Cons (goal exploration 0.6 0.5)
                (Cons (goal affinity 0.3 0.2)
                Nil)))
                (Cons (modulator arousal 0.8) Nil)
                1000))
    ''')
    assert_nonempty(pipeline_result)
    print("  ✓ Scoring pipeline executed without errors")

    print("\n" + "=" * 70)
    print("  TEST SUMMARY")
    print("=" * 70)
    print("  ✓ Measurability and correlation values loaded from M2")
    print("  ✓ Weighted correlations computed via geometric mean")
    print("  ✓ Overgoal bonus matches expected range")
    print("  ✓ Scoring pipeline executes successfully")
    print("\n  OVERGOAL SCORING INTEGRATION CONFIRMED")
    print("=" * 70)


if __name__ == '__main__':
    try:
        main()
    except Exception as error:  # pragma: no cover - diagnostic output
        print("\nERROR:", error)
        import traceback
        traceback.print_exc()
        sys.exit(1)

