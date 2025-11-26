#!/usr/bin/env python3
"""
Simple test to diagnose modulator-effect evaluation issue
"""

from hyperon import MeTTa
from pathlib import Path

def test_modulator_evaluation():
    """Test different ways of calling modulator-effect"""
    print("="*70)
    print("  MODULATOR EVALUATION DIAGNOSTIC")
    print("="*70)

    metta = MeTTa()
    base_dir = Path(__file__).parent

    # Load scoring module
    scoring_path = base_dir / 'Milestone_3/core/scoring-v2.metta'
    print(f"\nLoading {scoring_path}...")
    with open(scoring_path, 'r', encoding='utf-8') as f:
        metta.run(f.read())

    # Test 1: Direct literal call
    print("\n--- Test 1: Direct Literal Call ---")
    result = metta.run('!(modulator-effect arousal 0.8)')
    print(f"Input: !(modulator-effect arousal 0.8)")
    print(f"Result: {result}")

    # Test 2: With variable
    print("\n--- Test 2: With Variable ---")
    result = metta.run('!(let $v 0.8 (modulator-effect arousal $v))')
    print(f"Input: !(let $v 0.8 (modulator-effect arousal $v))")
    print(f"Result: {result}")

    # Test 3: Simple arithmetic (control)
    print("\n--- Test 3: Control - Simple Arithmetic ---")
    result = metta.run('!(+ 0.8 (* 0.4 0.8))')
    print(f"Input: !(+ 0.8 (* 0.4 0.8))")
    print(f"Result: {result}")

    # Test 4: Test if pattern matching works
    print("\n--- Test 4: Pattern Matching Test ---")
    test_code = '''
    (= (test-pattern arousal) "matched-arousal")
    (= (test-pattern pleasure) "matched-pleasure")
    (= (test-pattern $other) "matched-other")
    '''
    metta.run(test_code)
    result = metta.run('!(test-pattern arousal)')
    print(f"Input: !(test-pattern arousal)")
    print(f"Result: {result}")

    # Test 5: Inline modulator function
    print("\n--- Test 5: Inline Modulator Function ---")
    inline_code = '''
    (= (inline-mod arousal $val) (+ 0.8 (* 0.4 $val)))
    '''
    metta.run(inline_code)
    result = metta.run('!(inline-mod arousal 0.8)')
    print(f"Input: !(inline-mod arousal 0.8)")
    print(f"Result: {result}")

    # Test 6: Check what's in the space
    print("\n--- Test 6: Query modulator-effect definitions ---")
    result = metta.run('!(match &self (= (modulator-effect $name $_) $_) $name)')
    print(f"Modulators found: {result}")

if __name__ == '__main__':
    test_modulator_evaluation()
