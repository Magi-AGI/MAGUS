#!/usr/bin/env python3
"""
Simple test to diagnose overgoal evaluation issue
"""

from hyperon import MeTTa
from pathlib import Path

def test_overgoal_evaluation():
    """Test overgoal function evaluation"""
    print("="*70)
    print("  OVERGOAL EVALUATION DIAGNOSTIC")
    print("="*70)

    metta = MeTTa()
    base_dir = Path(__file__).parent

    # Load overgoal module
    overgoal_path = base_dir / 'Milestone_3/core/overgoal.metta'
    print(f"\nLoading {overgoal_path}...")
    with open(overgoal_path, 'r', encoding='utf-8') as f:
        metta.run(f.read())

    # Test 1: Direct calculation
    print("\n--- Test 1: Direct Weighted Correlation ---")
    result = metta.run('!(get-weighted-correlation-for-overgoal energy exploration 0.7 0.72 0.56)')
    print(f"Input: energy-exploration, base=0.7, meas=(0.72, 0.56)")
    print(f"Expected: 0.7 × sqrt(0.72 × 0.56) = 0.7 × 0.635 = 0.445")
    print(f"Result: {result}")

    # Try to parse result
    if result:
        result_str = str(result[0])
        print(f"Result string: {result_str}")
        if '[' in result_str:
            import re
            numbers = re.findall(r'\d+\.?\d*', result_str)
            if numbers:
                actual = float(numbers[0])
                print(f"Parsed value: {actual:.3f}")

    # Test 2: Arithmetic control
    print("\n--- Test 2: Control - Direct Arithmetic ---")
    result = metta.run('!(* 0.7 (sqrt (* 0.72 0.56)))')
    print(f"Input: (* 0.7 (sqrt (* 0.72 0.56)))")
    print(f"Result: {result}")

    # Test 3: Step by step
    print("\n--- Test 3: Step by Step ---")
    result1 = metta.run('!(* 0.72 0.56)')
    print(f"Step 1: (* 0.72 0.56) = {result1}")

    result2 = metta.run('!(sqrt 0.4032)')
    print(f"Step 2: (sqrt 0.4032) = {result2}")

    result3 = metta.run('!(* 0.7 0.635)')
    print(f"Step 3: (* 0.7 0.635) = {result3}")

if __name__ == '__main__':
    test_overgoal_evaluation()
