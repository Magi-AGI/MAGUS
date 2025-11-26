#!/usr/bin/env python3
"""
MAGUS Test Runner - Execute MeTTa tests and capture results
"""

from hyperon import MeTTa
import sys

def run_metta_file(filepath):
    """Run a MeTTa file and return results"""
    print(f"\n{'='*70}")
    print(f"Running: {filepath}")
    print('='*70)

    metta = MeTTa()

    try:
        with open(filepath, 'r') as f:
            code = f.read()

        results = metta.run(code)

        for result in results:
            print(result)

        return True
    except Exception as e:
        print(f"ERROR: {e}")
        return False

def main():
    # M2 Measurability Test
    print("\n🧪 MILESTONE 2 - MEASURABILITY TESTS")

    metta = MeTTa()

    # Load measurability code
    print("\nLoading measurability module...")
    with open('Milestone_2/goal-fitness-metrics/measurability/initial_measurability_calculation.metta') as f:
        metta.run(f.read())

    # Test individual functions
    print("\n--- Test 1: Energy Measurability ---")
    result = metta.run('!(get-measurability energy)')
    for r in result:
        print(f"Energy: {r}")

    print("\n--- Test 2: Exploration Measurability ---")
    result = metta.run('!(get-measurability exploration)')
    for r in result:
        print(f"Exploration: {r}")

    print("\n--- Test 3: Affinity Measurability ---")
    result = metta.run('!(get-measurability affinity)')
    for r in result:
        print(f"Affinity: {r}")

    print("\n--- Test 4: Average Measurability ---")
    result = metta.run('!(calculate-average-measurability)')
    for r in result:
        print(f"Average: {r}")

    # M2 Correlation Test
    print("\n\n🧪 MILESTONE 2 - CORRELATION TESTS")

    metta2 = MeTTa()

    print("\nLoading correlation module...")
    with open('Milestone_2/goal-fitness-metrics/correlation/initial_correlation_calculation.metta') as f:
        metta2.run(f.read())

    print("\n--- Test 5: Energy-Exploration Correlation ---")
    result = metta2.run('!(get-correlation energy exploration)')
    for r in result:
        print(f"Energy-Exploration: {r}")

    print("\n--- Test 6: Energy-Affinity Correlation ---")
    result = metta2.run('!(get-correlation energy affinity)')
    for r in result:
        print(f"Energy-Affinity: {r}")

    print("\n--- Test 7: Exploration-Affinity Correlation ---")
    result = metta2.run('!(get-correlation exploration affinity)')
    for r in result:
        print(f"Exploration-Affinity: {r}")

    print("\n" + "="*70)
    print("✅ M2 TESTS COMPLETE")
    print("="*70)

if __name__ == '__main__':
    main()
